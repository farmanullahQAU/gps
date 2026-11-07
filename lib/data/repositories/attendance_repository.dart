import 'dart:convert';
import 'package:drift/drift.dart';
import '../../core/database/app_database.dart';
import '../../core/database/daos/attendance_dao.dart';
import '../../core/database/daos/sync_dao.dart';
import '../../core/utils/idempotency.dart';
import 'sync_repository.dart';

class AttendanceRepository {
  final AppDatabase db;
  final SyncRepository? syncRepository;
  late final AttendanceDao attendanceDao;
  late final SyncDao syncDao;

  AttendanceRepository(this.db, {this.syncRepository}) {
    attendanceDao = db.attendanceDao;
    syncDao = db.syncDao;
  }

  /// Write-through trigger: Dispatches to reactive SyncController pipeline (or direct push in tests)
  void _triggerLiveSync() {
    syncRepository?.triggerMutation();
  }

  // Watch attendance for a section and date for real-time GetX reactive UI
  Stream<List<AttendanceRecord>> watchAttendance({
    required String classId,
    required String sectionId,
    required String date,
    String? schoolId,
  }) {
    return attendanceDao.watchAttendanceForSectionAndDate(
      classId: classId,
      sectionId: sectionId,
      date: date,
      schoolId: schoolId,
    );
  }

  // Get attendance for a section and date
  Future<List<AttendanceRecord>> getAttendance({
    required String classId,
    required String sectionId,
    required String date,
    String? schoolId,
  }) {
    return attendanceDao.getAttendanceForSectionAndDate(
      classId: classId,
      sectionId: sectionId,
      date: date,
      schoolId: schoolId,
    );
  }

  // Get session status (draft vs finalized)
  Future<AttendanceSessionModel?> getSession({
    required String sectionId,
    required String date,
    String? schoolId,
  }) {
    return attendanceDao.getSession(
      sectionId: sectionId,
      date: date,
      schoolId: schoolId,
    );
  }

  // Finalize or Reopen a daily attendance session atomically with outbox enqueue
  Future<AttendanceSessionModel> updateSessionStatus({
    required String schoolId,
    required String classId,
    required String sectionId,
    required String date,
    required String status, // 'draft' | 'finalized'
    required String userId,
    String? notes,
  }) async {
    final session = await db.transaction(() async {
      final session = await attendanceDao.upsertSession(
        schoolId: schoolId,
        classId: classId,
        sectionId: sectionId,
        date: date,
        status: status,
        finalizedByUserId: userId,
        notes: notes,
      );

      final idempotencyKey = IdempotencyUtil.forSession(sectionId, date);
      await syncDao.enqueue(
        targetTable: 'attendance_sessions',
        recordId: session.id,
        operation: session.revision > 1 ? 'UPDATE' : 'INSERT',
        payloadJson: jsonEncode({
          'id': session.id,
          'school_id': schoolId,
          'class_id': classId,
          'section_id': sectionId,
          'date': date,
          'status': status,
          'finalized_by_user_id': userId,
          'finalized_at': session.finalizedAt,
          'notes': notes,
          'updated_at': session.updatedAt,
          'revision': session.revision,
        }),
        idempotencyKey: idempotencyKey,
        clientRevision: session.revision,
      );

      return session;
    });

    _triggerLiveSync();
    return session;
  }

  // Mark attendance for a single student inside an atomic transaction with SyncQueue outbox
  Future<AttendanceRecord> markAttendance({
    required String schoolId,
    required String studentId,
    required String classId,
    required String sectionId,
    required String date,
    required String status,
    String? arrivalTime,
    String? departureTime,
    String? remarks,
    required String markedByUserId,
    required String markingMethod,
    String? editReason,
  }) async {
    final recordId = 'att_${studentId}_$date';
    final idempotencyKey = IdempotencyUtil.forAttendance(studentId, date);

    final record = await db.transaction(() async {
      final record = await attendanceDao.recordAttendance(
        id: recordId,
        schoolId: schoolId,
        studentId: studentId,
        classId: classId,
        sectionId: sectionId,
        date: date,
        status: status,
        arrivalTime: arrivalTime,
        departureTime: departureTime,
        remarks: remarks,
        markedByUserId: markedByUserId,
        markingMethod: markingMethod,
        idempotencyKey: idempotencyKey,
        editReason: editReason,
      );

      final payloadJson = jsonEncode({
        'id': record.id,
        'school_id': schoolId,
        'student_id': studentId,
        'class_id': classId,
        'section_id': sectionId,
        'date': date,
        'status': status,
        'arrival_time': record.arrivalTime,
        'departure_time': record.departureTime,
        'remarks': record.remarks,
        'marking_method': markingMethod,
        'idempotency_key': idempotencyKey,
        'created_at': record.createdAt,
        'updated_at': record.updatedAt,
        'revision': record.revision,
      });

      await syncDao.enqueue(
        targetTable: 'attendance_records',
        recordId: record.id,
        operation: record.revision > 1 ? 'UPDATE' : 'INSERT',
        payloadJson: payloadJson,
        idempotencyKey: idempotencyKey,
        clientRevision: record.revision,
      );

      return record;
    });

    _triggerLiveSync();
    return record;
  }

  // Mark All Present for a class and section inside a single batch transaction
  Future<List<AttendanceRecord>> markAllPresent({
    required String schoolId,
    required String classId,
    required String sectionId,
    required String date,
    required String markedByUserId,
    required List<String> studentIds,
    String? defaultDepartureTime,
    Map<String, ({String status, String? arrivalTime, String? departureTime, String? remarks})>?
        studentOverrides,
  }) async {
    final existingRecords = await getAttendance(
      classId: classId,
      sectionId: sectionId,
      date: date,
    );

    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction(() async {
      for (final studentId in studentIds) {
        final ov = studentOverrides?[studentId];
        final status = ov?.status ?? 'present';
        final arrivalTime = ov?.arrivalTime;
        final departureTime = ov?.departureTime ?? defaultDepartureTime;
        final remarks = ov?.remarks ?? 'Marked all present';
        final recordId = 'att_${studentId}_$date';
        final idempotencyKey = IdempotencyUtil.forAttendance(studentId, date);

        final record = await attendanceDao.recordAttendance(
          id: recordId,
          schoolId: schoolId,
          studentId: studentId,
          classId: classId,
          sectionId: sectionId,
          date: date,
          status: status,
          arrivalTime: arrivalTime,
          departureTime: departureTime,
          remarks: remarks,
          markedByUserId: markedByUserId,
          markingMethod: 'mark_all',
          idempotencyKey: idempotencyKey,
        );

        final payloadJson = jsonEncode({
          'id': record.id,
          'school_id': schoolId,
          'student_id': studentId,
          'class_id': classId,
          'section_id': sectionId,
          'date': date,
          'status': status,
          'arrival_time': record.arrivalTime,
          'departure_time': record.departureTime,
          'remarks': record.remarks,
          'marking_method': 'mark_all',
          'idempotency_key': idempotencyKey,
          'created_at': record.createdAt,
          'updated_at': record.updatedAt > 0 ? record.updatedAt : now,
          'revision': record.revision,
        });

        await syncDao.enqueue(
          targetTable: 'attendance_records',
          recordId: record.id,
          operation: record.revision > 1 ? 'UPDATE' : 'INSERT',
          payloadJson: payloadJson,
          idempotencyKey: idempotencyKey,
          clientRevision: record.revision,
        );
      }
    });

    _triggerLiveSync();
    return existingRecords;
  }

  // Undo Mark All Present atomically (restoring previous records and enqueueing tombstones for unmarked)
  Future<void> restoreAttendanceSnapshot({
    required List<AttendanceRecord> previousRecords,
    required List<String> studentIds,
    required String date,
  }) async {
    final previousMap = {for (final r in previousRecords) r.studentId: r};

    await db.transaction(() async {
      for (final studentId in studentIds) {
        final prev = previousMap[studentId];
        if (prev != null) {
          final recordId = 'att_${prev.studentId}_${prev.date}';
          final idempotencyKey = IdempotencyUtil.forAttendance(prev.studentId, prev.date);
          final record = await attendanceDao.recordAttendance(
            id: recordId,
            schoolId: prev.schoolId,
            studentId: prev.studentId,
            classId: prev.classId,
            sectionId: prev.sectionId,
            date: prev.date,
            status: prev.status,
            arrivalTime: prev.arrivalTime,
            departureTime: prev.departureTime,
            remarks: prev.remarks,
            markedByUserId: prev.markedByUserId,
            markingMethod: 'manual',
            idempotencyKey: idempotencyKey,
            editReason: 'Undo mark all present',
          );

          await syncDao.enqueue(
            targetTable: 'attendance_records',
            recordId: record.id,
            operation: record.revision > 1 ? 'UPDATE' : 'INSERT',
            payloadJson: jsonEncode({
              'id': record.id,
              'school_id': prev.schoolId,
              'student_id': prev.studentId,
              'class_id': prev.classId,
              'section_id': prev.sectionId,
              'date': prev.date,
              'status': prev.status,
              'arrival_time': record.arrivalTime,
              'departure_time': record.departureTime,
              'remarks': record.remarks,
              'marking_method': 'manual',
              'idempotency_key': idempotencyKey,
              'created_at': record.createdAt,
              'updated_at': record.updatedAt,
              'revision': record.revision,
            }),
            idempotencyKey: idempotencyKey,
            clientRevision: record.revision,
          );
        } else {
          final recordId = 'att_${studentId}_$date';
          final idempotencyKey = IdempotencyUtil.forAttendance(studentId, date);
          await (db.delete(db.attendanceRecords)
                ..where((t) => t.studentId.equals(studentId) & t.date.equals(date)))
              .go();

          await syncDao.enqueue(
            targetTable: 'attendance_records',
            recordId: recordId,
            operation: 'DELETE',
            payloadJson: jsonEncode({
              'id': recordId,
              'student_id': studentId,
              'date': date,
            }),
            idempotencyKey: idempotencyKey,
            clientRevision: 1,
          );
        }
      }
    });

    _triggerLiveSync();
  }

  // Submit a correction request when a teacher needs to amend a finalized session
  Future<CorrectionRequestModel> submitCorrectionRequest({
    required String schoolId,
    required String attendanceRecordId,
    required String studentId,
    required String studentName,
    required String classId,
    required String sectionId,
    required String date,
    required String oldStatus,
    required String proposedStatus,
    required String reason,
    required String requestedByUserId,
    required String requestedByName,
  }) async {
    final req = await db.transaction(() async {
      final req = await attendanceDao.createCorrectionRequest(
        schoolId: schoolId,
        attendanceRecordId: attendanceRecordId,
        studentId: studentId,
        studentName: studentName,
        classId: classId,
        sectionId: sectionId,
        date: date,
        oldStatus: oldStatus,
        proposedStatus: proposedStatus,
        reason: reason,
        requestedByUserId: requestedByUserId,
        requestedByName: requestedByName,
      );

      await syncDao.enqueue(
        targetTable: 'correction_requests',
        recordId: req.id,
        operation: 'INSERT',
        payloadJson: jsonEncode({
          'id': req.id,
          'school_id': schoolId,
          'attendance_record_id': attendanceRecordId,
          'student_id': studentId,
          'student_name': studentName,
          'class_id': classId,
          'section_id': sectionId,
          'date': date,
          'old_status': oldStatus,
          'proposed_status': proposedStatus,
          'reason': reason,
          'requested_by_user_id': requestedByUserId,
          'requested_by_name': requestedByName,
          'status': 'pending',
          'created_at': req.createdAt,
          'updated_at': req.updatedAt,
        }),
        idempotencyKey: req.id,
      );

      return req;
    });

    _triggerLiveSync();
    return req;
  }

  // Head Teacher / Admin approves or rejects a correction request
  Future<void> reviewCorrectionRequest({
    required CorrectionRequestModel request,
    required String decision, // 'approved' | 'rejected'
    required String reviewedByUserId,
    String? reviewRemarks,
  }) async {
    await db.transaction(() async {
      await attendanceDao.reviewCorrectionRequest(
        requestId: request.id,
        decision: decision,
        reviewedByUserId: reviewedByUserId,
        reviewRemarks: reviewRemarks,
      );

      await syncDao.enqueue(
        targetTable: 'correction_requests',
        recordId: request.id,
        operation: 'UPDATE',
        payloadJson: jsonEncode({
          'id': request.id,
          'school_id': request.schoolId,
          'status': decision,
          'reviewed_by_user_id': reviewedByUserId,
          'review_remarks': reviewRemarks,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        }),
        idempotencyKey: 'cr_rev_${request.id}_$decision',
      );

      if (decision == 'approved') {
        await markAttendance(
          schoolId: request.schoolId,
          studentId: request.studentId,
          classId: request.classId,
          sectionId: request.sectionId,
          date: request.date,
          status: request.proposedStatus,
          markedByUserId: reviewedByUserId,
          markingMethod: 'manual',
          remarks: 'Approved Correction: ${request.reason}',
          editReason: 'Head Teacher Approved Correction (${request.reason})',
        );
      }
    });

    _triggerLiveSync();
  }

  // Get correction requests
  Future<List<CorrectionRequestModel>> getCorrectionRequests({
    required String schoolId,
    String? status,
  }) {
    return attendanceDao.getCorrectionRequests(schoolId: schoolId, status: status);
  }

  // Get recent audit logs
  Future<List<AttendanceAuditLog>> getRecentAuditLogs({int limit = 100}) {
    return attendanceDao.getRecentAuditLogs(limit: limit);
  }

  // Get records for reports
  Future<List<AttendanceRecord>> getAttendanceForDateRange({
    required String schoolId,
    String? classId,
    String? sectionId,
    String? studentId,
    required String startDate,
    required String endDate,
  }) {
    return attendanceDao.getAttendanceForDateRange(
      schoolId: schoolId,
      classId: classId,
      sectionId: sectionId,
      studentId: studentId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
