import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/database/app_database.dart';
import '../../core/database/daos/sync_dao.dart';
import 'auth_repository.dart';

enum SyncStatus { idle, syncing, success, offline, error }

class SyncRepository {
  final AppDatabase db;
  final AuthRepository authRepository;
  late final SyncDao syncDao;

  String baseUrl = 'https://myschool-api.pages.dev';

  SyncRepository(this.db, this.authRepository) {
    syncDao = db.syncDao;
  }

  // Live count of pending unsynced changes
  Stream<int> watchPendingCount() => syncDao.watchPendingCount();

  // Get outbox items for Sync Inspector
  Future<List<SyncQueueData>> getAllQueueItems({int limit = 100}) => syncDao.getAllQueueItems(limit: limit);

  // Get unresolved conflicts
  Future<List<SyncConflictModel>> getUnresolvedConflicts() => syncDao.getUnresolvedConflicts();

  // Resolve conflict
  Future<void> resolveConflict(String conflictId, String resolution) => syncDao.resolveConflict(conflictId, resolution);

  // Reset failed items for retry
  Future<void> resetFailedItems() => syncDao.resetFailedItems();

  DateTime? _lastHealthCheckTime;
  bool _isLastOnline = false;

  /// Lightweight reachability check against Cloudflare backend health endpoint
  Future<bool> isOnline({bool force = false}) async {
    final now = DateTime.now();
    if (!force && _lastHealthCheckTime != null && now.difference(_lastHealthCheckTime!).inSeconds < 5) {
      return _isLastOnline;
    }
    try {
      final res = await http.get(Uri.parse('$baseUrl/health')).timeout(const Duration(seconds: 2));
      _isLastOnline = (res.statusCode == 200);
      _lastHealthCheckTime = now;
      return _isLastOnline;
    } catch (_) {
      _isLastOnline = false;
      _lastHealthCheckTime = now;
      return false;
    }
  }

  /// Transparent write-through callback (wired to reactive SyncController in app runtime)
  void Function()? onMutationEnqueued;

  /// Transparent Write-Through Trigger:
  /// Dispatches the mutation to the reactive SyncController debounce pipeline if wired,
  /// or directly attempts online push with safe offline fallback in tests.
  void triggerMutation() {
    if (onMutationEnqueued != null) {
      onMutationEnqueued!();
    } else {
      pushPendingIfOnline().catchError((_) => 0);
    }
  }

  /// Dual-Mode Helper:
  /// Attempts to push pending items immediately if online and authenticated.
  /// If offline or if the network is unreachable, it gracefully returns 0 without throwing,
  /// safely retaining local mutations inside the SQLite outbox.
  Future<int> pushPendingIfOnline() async {
    try {
      final token = await authRepository.getAuthToken();
      if (token == null) return 0;

      final online = await isOnline();
      if (!online) return 0;

      return await pushPending();
    } catch (_) {
      return 0;
    }
  }

  // Push local outbox mutations to Cloudflare Workers D1 backend in chunks of up to 100 items
  Future<int> pushPending({int limit = 200}) async {
    final allPending = await syncDao.getPendingItems(limit: limit);
    if (allPending.isEmpty) return 0;

    final token = await authRepository.getAuthToken();
    if (token == null) {
      throw Exception('Authentication token missing. Please log in.');
    }

    int totalSynced = 0;
    const int batchSize = 100;

    for (int offset = 0; offset < allPending.length; offset += batchSize) {
      final end = (offset + batchSize < allPending.length) ? offset + batchSize : allPending.length;
      final pending = allPending.sublist(offset, end);
      final pendingById = {for (final item in pending) item.id: item};
      final items = pending.map((item) {
        return {
          'id': item.id.toString(),
          'tableName': item.targetTable,
          'recordId': item.recordId,
          'operation': item.operation,
          'payload': jsonDecode(item.payloadJson),
          'idempotencyKey': item.idempotencyKey,
          'clientRevision': item.clientRevision,
          'timestamp': item.createdAt,
        };
      }).toList();

      try {
        final response = await http
            .post(
              Uri.parse('$baseUrl/api/v1/sync/push'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode({'items': items}),
            )
            .timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final resData = jsonDecode(response.body);
          final processed = resData['processed'] as List<dynamic>? ?? [];

          final syncedIds = <int>[];
          for (final p in processed) {
            final qId = int.tryParse(p['id'].toString());
            if (qId != null) {
              final status = p['status'] as String? ?? '';
              if (status == 'accepted' || status == 'ignored_duplicate' || status == 'conflict_resolved') {
                syncedIds.add(qId);
                if (status == 'conflict_resolved') {
                  final orig = pendingById[qId];
                  if (orig != null) {
                    final payload = jsonDecode(orig.payloadJson) as Map<String, dynamic>;
                    await syncDao.recordConflict(
                      id: 'conf_${orig.recordId}_${DateTime.now().millisecondsSinceEpoch}',
                      recordId: orig.recordId,
                      tableName: orig.targetTable,
                      studentId: (payload['student_id'] ?? orig.recordId).toString(),
                      date: (payload['date'] ?? '').toString(),
                      localStatus: (payload['status'] ?? 'unknown').toString(),
                      serverStatus: (p['serverStatus'] ?? 'newer_revision').toString(),
                      conflictReason: 'Server had newer revision v${p['serverRevision']}',
                    );
                  }
                }
              } else {
                await syncDao.markFailed(qId, p['error'] ?? 'Unknown sync failure');
              }
            }
          }

          if (syncedIds.isNotEmpty) {
            await syncDao.markSynced(syncedIds);
            totalSynced += syncedIds.length;
          }
        } else {
          throw Exception('Server rejected sync: ${response.statusCode}');
        }
      } catch (e) {
        final errStr = e.toString().toLowerCase();
        final isNetworkError = errStr.contains('socketexception') ||
            errStr.contains('timeoutexception') ||
            errStr.contains('clientexception') ||
            errStr.contains('failed host lookup') ||
            errStr.contains('connection refused') ||
            errStr.contains('network is unreachable');

        if (!isNetworkError) {
          for (final item in pending) {
            await syncDao.markFailed(item.id, e.toString());
          }
        }
        rethrow;
      }
    }

    return totalSynced;
  }

  // Pull incremental or full updates from Cloudflare Workers and merge into local SQLite
  Future<int> pullLatest(String schoolId, {bool forceFull = false}) async {
    final token = await authRepository.getAuthToken();
    if (token == null) return 0;

    final prefs = await SharedPreferences.getInstance();
    final cursorKey = 'sync_pull_cursor_$schoolId';
    final sinceTimestamp = forceFull ? 0 : (prefs.getInt(cursorKey) ?? 0);

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/v1/sync/pull?school_id=$schoolId&since_timestamp=$sinceTimestamp'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final serverTimestamp = body['serverTimestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch;
        if (body['unchanged'] == true) {
          await prefs.setInt(cursorKey, serverTimestamp);
          return 0;
        }
        final data = body['data'] as Map<String, dynamic>? ?? {};
        if (data.isEmpty) {
          await prefs.setInt(cursorKey, serverTimestamp);
          return 0;
        }

        int mergedCount = 0;

        await db.transaction(() async {
          // 1. Merge Schools
          final schoolsList = data['schools'] as List<dynamic>? ?? [];
          for (final raw in schoolsList) {
            final sc = raw as Map<String, dynamic>;
            await db.into(db.schools).insertOnConflictUpdate(
                  SchoolsCompanion.insert(
                    id: sc['id'].toString(),
                    name: sc['name'].toString(),
                    code: sc['code'].toString(),
                    address: Value(sc['address']?.toString()),
                    phone: Value(sc['phone']?.toString()),
                    logoUrl: Value(sc['logo_url']?.toString()),
                    academicYearStart: (sc['academic_year_start'] ?? '2026-04-01').toString(),
                    academicYearEnd: (sc['academic_year_end'] ?? '2027-03-31').toString(),
                    createdAt: int.tryParse(sc['created_at']?.toString() ?? '0') ?? 0,
                    updatedAt: int.tryParse(sc['updated_at']?.toString() ?? '0') ?? 0,
                    revision: Value(int.tryParse(sc['revision']?.toString() ?? '1') ?? 1),
                  ),
                );
            mergedCount++;
          }

          // 2. Merge School Settings
          final settingsList = data['school_settings'] as List<dynamic>? ?? [];
          for (final raw in settingsList) {
            final st = raw as Map<String, dynamic>;
            await db.customStatement('''
              INSERT INTO school_settings
                (school_id, school_type, district, tehsil, circle_office, union_council, climate_zone, opening_time, closing_time, late_cutoff_time, head_teacher_name, deo_name, working_days_csv, updated_at, revision)
              VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
              ON CONFLICT(school_id) DO UPDATE SET
                school_type = excluded.school_type,
                district = excluded.district,
                tehsil = excluded.tehsil,
                circle_office = excluded.circle_office,
                union_council = excluded.union_council,
                climate_zone = excluded.climate_zone,
                opening_time = excluded.opening_time,
                closing_time = excluded.closing_time,
                late_cutoff_time = excluded.late_cutoff_time,
                head_teacher_name = excluded.head_teacher_name,
                deo_name = excluded.deo_name,
                working_days_csv = excluded.working_days_csv,
                updated_at = excluded.updated_at,
                revision = excluded.revision
            ''', [
              st['school_id'].toString(),
              (st['school_type'] ?? 'GPS').toString(),
              (st['district'] ?? 'Peshawar').toString(),
              (st['tehsil'] ?? 'City Peshawar').toString(),
              (st['circle_office'] ?? 'ASDEO Circle City-I').toString(),
              (st['union_council'] ?? 'UC-12').toString(),
              (st['climate_zone'] ?? 'summer_zone').toString(),
              (st['opening_time'] ?? '08:00').toString(),
              (st['closing_time'] ?? '13:30').toString(),
              (st['late_cutoff_time'] ?? '08:15').toString(),
              (st['head_teacher_name'] ?? 'Head Teacher').toString(),
              (st['deo_name'] ?? 'DEO Peshawar').toString(),
              (st['working_days_csv'] ?? '1,2,3,4,5,6').toString(),
              int.tryParse(st['updated_at']?.toString() ?? '0') ?? 0,
              int.tryParse(st['revision']?.toString() ?? '1') ?? 1,
            ]);
            mergedCount++;
          }

          // 3. Merge Classes
          final classesList = data['classes'] as List<dynamic>? ?? [];
          for (final raw in classesList) {
            final c = raw as Map<String, dynamic>;
            await db.into(db.classes).insertOnConflictUpdate(
                  ClassesCompanion.insert(
                    id: c['id'].toString(),
                    schoolId: c['school_id'].toString(),
                    name: c['name'].toString(),
                    numericLevel: Value(int.tryParse(c['numeric_level']?.toString() ?? '1') ?? 1),
                    createdAt: int.tryParse(c['created_at']?.toString() ?? '0') ?? 0,
                    updatedAt: int.tryParse(c['updated_at']?.toString() ?? '0') ?? 0,
                    revision: Value(int.tryParse(c['revision']?.toString() ?? '1') ?? 1),
                  ),
                );
            mergedCount++;
          }

          // 4. Merge Sections
          final sectionsList = data['sections'] as List<dynamic>? ?? [];
          for (final raw in sectionsList) {
            final s = raw as Map<String, dynamic>;
            await db.into(db.sections).insertOnConflictUpdate(
                  SectionsCompanion.insert(
                    id: s['id'].toString(),
                    schoolId: s['school_id'].toString(),
                    classId: s['class_id'].toString(),
                    name: s['name'].toString(),
                    teacherId: Value(s['teacher_id']?.toString()),
                    createdAt: int.tryParse(s['created_at']?.toString() ?? '0') ?? 0,
                    updatedAt: int.tryParse(s['updated_at']?.toString() ?? '0') ?? 0,
                    revision: Value(int.tryParse(s['revision']?.toString() ?? '1') ?? 1),
                  ),
                );
            mergedCount++;
          }

          // 5. Merge Students (including tombstones is_deleted == 1)
          final studentsList = data['students'] as List<dynamic>? ?? [];
          for (final raw in studentsList) {
            final st = raw as Map<String, dynamic>;
            final isDeleted = (st['is_deleted'] == 1 || st['is_deleted'] == true);
            await db.into(db.students).insertOnConflictUpdate(
                  StudentsCompanion.insert(
                    id: st['id'].toString(),
                    schoolId: st['school_id'].toString(),
                    classId: st['class_id'].toString(),
                    sectionId: st['section_id'].toString(),
                    admissionNumber: st['admission_number'].toString(),
                    rollNumber: Value(st['roll_number']?.toString()),
                    fullName: st['full_name'].toString(),
                    fatherOrGuardianName: st['father_or_guardian_name'].toString(),
                    gender: (st['gender'] ?? 'male').toString(),
                    dateOfBirth: Value(st['date_of_birth']?.toString()),
                    admissionDate: (st['admission_date'] ?? '2026-04-01').toString(),
                    status: Value((st['status'] ?? 'active').toString()),
                    qrToken: st['qr_token'].toString(),
                    photoUrl: Value(st['photo_url']?.toString()),
                    isDeleted: Value(isDeleted),
                    createdAt: int.tryParse(st['created_at']?.toString() ?? '0') ?? 0,
                    updatedAt: int.tryParse(st['updated_at']?.toString() ?? '0') ?? 0,
                    revision: Value(int.tryParse(st['revision']?.toString() ?? '1') ?? 1),
                  ),
                );
            mergedCount++;
          }

          // 6. Merge Parent Contacts
          final parentContactsList = data['parent_contacts'] as List<dynamic>? ?? [];
          for (final raw in parentContactsList) {
            final p = raw as Map<String, dynamic>;
            final serverRev = int.tryParse(p['revision']?.toString() ?? '1') ?? 1;
            await db.into(db.parentContacts).insertOnConflictUpdate(
                  ParentContactsCompanion.insert(
                    id: p['id'].toString(),
                    studentId: p['student_id'].toString(),
                    relation: (p['relation'] ?? 'father').toString(),
                    phoneNumber: p['phone_number'].toString(),
                    whatsappEnabled: Value(p['whatsapp_enabled'] == 1 || p['whatsapp_enabled'] == true),
                    notifyAbsent: Value(p['notify_absent'] == 1 || p['notify_absent'] == true),
                    notifyLate: Value(p['notify_late'] == 1 || p['notify_late'] == true),
                    notifyLeave: Value(p['notify_leave'] == 1 || p['notify_leave'] == true),
                    createdAt: int.tryParse(p['created_at']?.toString() ?? '0') ?? 0,
                    updatedAt: int.tryParse(p['updated_at']?.toString() ?? '0') ?? 0,
                    revision: Value(serverRev),
                  ),
                );
            mergedCount++;
          }

          // 7. Merge Student Extended Info
          final extList = data['student_extended_info'] as List<dynamic>? ?? [];
          for (final raw in extList) {
            final e = raw as Map<String, dynamic>;
            final studentId = e['student_id'].toString();
            final prevTokens = e['previous_qr_tokens_json'] is String
                ? e['previous_qr_tokens_json'].toString()
                : jsonEncode(e['previous_qr_tokens_json'] ?? []);
            await db.customStatement('''
              INSERT INTO student_extended_info
                (student_id, student_b_form, father_cnic, mother_name, domicile_district, leaving_date, leaving_reason, slc_number, free_books_issued, previous_qr_tokens_json, updated_at, revision)
              VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
              ON CONFLICT(student_id) DO UPDATE SET
                student_b_form = excluded.student_b_form,
                father_cnic = excluded.father_cnic,
                mother_name = excluded.mother_name,
                domicile_district = excluded.domicile_district,
                leaving_date = excluded.leaving_date,
                leaving_reason = excluded.leaving_reason,
                slc_number = excluded.slc_number,
                free_books_issued = excluded.free_books_issued,
                previous_qr_tokens_json = excluded.previous_qr_tokens_json,
                updated_at = excluded.updated_at,
                revision = excluded.revision
            ''', [
              studentId,
              e['student_b_form']?.toString(),
              e['father_cnic']?.toString(),
              e['mother_name']?.toString(),
              e['domicile_district']?.toString() ?? 'Peshawar',
              e['leaving_date']?.toString(),
              e['leaving_reason']?.toString(),
              e['slc_number']?.toString(),
              (e['free_books_issued'] == 1 || e['free_books_issued'] == true) ? 1 : 0,
              prevTokens,
              int.tryParse(e['updated_at']?.toString() ?? '0') ?? 0,
              int.tryParse(e['revision']?.toString() ?? '1') ?? 1,
            ]);
            mergedCount++;
          }

          // 8. Merge Holidays
          final holidaysList = data['holidays'] as List<dynamic>? ?? [];
          for (final raw in holidaysList) {
            final h = raw as Map<String, dynamic>;
            await db.into(db.schoolCalendarHolidays).insertOnConflictUpdate(
                  SchoolCalendarHolidaysCompanion.insert(
                    id: h['id'].toString(),
                    schoolId: h['school_id'].toString(),
                    date: h['date'].toString(),
                    description: h['description'].toString(),
                    isInstructionalDay: Value(h['is_instructional_day'] == 1 || h['is_instructional_day'] == true),
                    createdAt: int.tryParse(h['created_at']?.toString() ?? '0') ?? 0,
                    updatedAt: int.tryParse(h['updated_at']?.toString() ?? '0') ?? 0,
                    revision: Value(int.tryParse(h['revision']?.toString() ?? '1') ?? 1),
                  ),
                );
            mergedCount++;
          }

          // Check pending local outbox items so we never overwrite an unpushed offline mutation
          final pendingOutbox = await syncDao.getPendingItems(limit: 500);
          final pendingStudentDates = <String>{};
          final pendingSessionKeys = <String>{};
          for (final item in pendingOutbox) {
            try {
              final p = jsonDecode(item.payloadJson) as Map<String, dynamic>;
              if (item.targetTable == 'attendance_records') {
                pendingStudentDates.add('${p['student_id']}|${p['date']}');
              } else if (item.targetTable == 'attendance_sessions') {
                pendingSessionKeys.add('${p['section_id']}|${p['date']}');
              }
            } catch (_) {}
          }

          // 9. Merge Attendance Records (conflict-free on UNIQUE(student_id, date))
          final attendanceList = data['attendance'] as List<dynamic>? ?? [];
          for (final raw in attendanceList) {
            final a = raw as Map<String, dynamic>;
            final studentId = a['student_id'].toString();
            final date = a['date'].toString();
            if (pendingStudentDates.contains('$studentId|$date')) {
              continue;
            }
            final serverRev = int.tryParse(a['revision']?.toString() ?? '1') ?? 1;

            await db.customStatement('''
              INSERT INTO attendance_records
                (id, school_id, student_id, class_id, section_id, date, status, arrival_time, departure_time, remarks, marked_by_user_id, marking_method, idempotency_key, created_at, updated_at, revision)
              VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
              ON CONFLICT(student_id, date) DO UPDATE SET
                status = excluded.status,
                arrival_time = excluded.arrival_time,
                departure_time = excluded.departure_time,
                remarks = excluded.remarks,
                marked_by_user_id = excluded.marked_by_user_id,
                marking_method = excluded.marking_method,
                updated_at = excluded.updated_at,
                revision = excluded.revision
            ''', [
              a['id'].toString(),
              a['school_id'].toString(),
              studentId,
              a['class_id'].toString(),
              a['section_id'].toString(),
              date,
              a['status'].toString(),
              a['arrival_time']?.toString(),
              a['departure_time']?.toString(),
              a['remarks']?.toString(),
              a['marked_by_user_id'].toString(),
              (a['marking_method'] ?? 'manual').toString(),
              a['idempotency_key'].toString(),
              int.tryParse(a['created_at']?.toString() ?? '0') ?? 0,
              int.tryParse(a['updated_at']?.toString() ?? '0') ?? 0,
              serverRev,
            ]);
            mergedCount++;
          }

          // 10. Merge Users / Staff Members
          final usersList = data['users'] as List<dynamic>? ?? [];
          for (final raw in usersList) {
            final u = raw as Map<String, dynamic>;
            final uId = u['id'].toString();
            final serverRev = int.tryParse(u['revision']?.toString() ?? '1') ?? 1;

            await db.into(db.users).insertOnConflictUpdate(
                  UsersCompanion.insert(
                    id: uId,
                    schoolId: u['school_id'].toString(),
                    name: u['name'].toString(),
                    email: Value(u['email']?.toString()),
                    phone: Value(u['phone']?.toString()),
                    role: (u['role'] ?? 'teacher').toString(),
                    pinCodeHash: Value(u['pin_code_hash']?.toString()),
                    avatarUrl: Value(u['avatar_url']?.toString()),
                    cnic: Value(u['cnic']?.toString()),
                    designation: Value(u['designation']?.toString() ?? 'Primary School Teacher (PST)'),
                    isActive: Value(u['is_active'] == 1 || u['is_active'] == true),
                    createdAt: int.tryParse(u['created_at']?.toString() ?? '0') ?? 0,
                    updatedAt: int.tryParse(u['updated_at']?.toString() ?? '0') ?? 0,
                    revision: Value(serverRev),
                  ),
                );
            mergedCount++;
          }

          // 11. Merge Attendance Sessions (conflict-free on UNIQUE(section_id, date))
          final sessionsList = data['sessions'] as List<dynamic>? ?? [];
          for (final raw in sessionsList) {
            final s = raw as Map<String, dynamic>;
            final sectionId = s['section_id'].toString();
            final date = s['date'].toString();
            if (pendingSessionKeys.contains('$sectionId|$date')) {
              continue;
            }
            final serverRev = int.tryParse(s['revision']?.toString() ?? '1') ?? 1;

            await db.customStatement('''
              INSERT INTO attendance_sessions
                (id, school_id, class_id, section_id, date, status, finalized_by_user_id, finalized_at, notes, updated_at, revision)
              VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
              ON CONFLICT(section_id, date) DO UPDATE SET
                status = excluded.status,
                finalized_by_user_id = excluded.finalized_by_user_id,
                finalized_at = excluded.finalized_at,
                notes = excluded.notes,
                updated_at = excluded.updated_at,
                revision = excluded.revision
            ''', [
              s['id'].toString(),
              s['school_id'].toString(),
              s['class_id'].toString(),
              sectionId,
              date,
              (s['status'] ?? 'draft').toString(),
              s['finalized_by_user_id']?.toString(),
              s['finalized_at'] != null ? int.tryParse(s['finalized_at'].toString()) : null,
              s['notes']?.toString(),
              int.tryParse(s['updated_at']?.toString() ?? '0') ?? DateTime.now().millisecondsSinceEpoch,
              serverRev,
            ]);
            mergedCount++;
          }

          // 12. Merge Correction Requests
          final correctionsList = data['corrections'] as List<dynamic>? ?? [];
          for (final raw in correctionsList) {
            final cr = raw as Map<String, dynamic>;
            await db.customStatement('''
              INSERT INTO correction_requests
                (id, school_id, attendance_record_id, student_id, student_name, class_id, section_id, date, old_status, proposed_status, reason, requested_by_user_id, requested_by_name, status, reviewed_by_user_id, review_remarks, created_at, updated_at)
              VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
              ON CONFLICT(id) DO UPDATE SET
                status = excluded.status,
                reviewed_by_user_id = excluded.reviewed_by_user_id,
                review_remarks = excluded.review_remarks,
                updated_at = excluded.updated_at
            ''', [
              cr['id'].toString(),
              cr['school_id'].toString(),
              cr['attendance_record_id'].toString(),
              cr['student_id'].toString(),
              cr['student_name']?.toString(),
              cr['class_id'].toString(),
              cr['section_id'].toString(),
              cr['date'].toString(),
              cr['old_status'].toString(),
              cr['proposed_status'].toString(),
              cr['reason'].toString(),
              cr['requested_by_user_id'].toString(),
              cr['requested_by_name']?.toString(),
              (cr['status'] ?? 'pending').toString(),
              cr['reviewed_by_user_id']?.toString(),
              cr['review_remarks']?.toString(),
              int.tryParse(cr['created_at']?.toString() ?? '0') ?? 0,
              int.tryParse(cr['updated_at']?.toString() ?? '0') ?? 0,
            ]);
            mergedCount++;
          }
        });

        await prefs.setInt(cursorKey, serverTimestamp);
        return mergedCount;
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  // Purge already synced items
  Future<int> purgeCompleted() => syncDao.purgeSynced();
}
