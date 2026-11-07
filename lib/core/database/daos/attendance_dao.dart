import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'attendance_dao.g.dart';

@DriftAccessor(tables: [AttendanceRecords, AttendanceAuditLogs, Students, Classes, Sections])
class AttendanceDao extends DatabaseAccessor<AppDatabase> with _$AttendanceDaoMixin {
  AttendanceDao(super.db);

  // Get attendance records for a specific class, section, and date
  Future<List<AttendanceRecord>> getAttendanceForSectionAndDate({
    required String classId,
    required String sectionId,
    required String date,
    String? schoolId,
  }) {
    var q = select(attendanceRecords)
      ..where((t) =>
          t.classId.equals(classId) &
          t.sectionId.equals(sectionId) &
          t.date.equals(date));
    if (schoolId != null) {
      q = q..where((t) => t.schoolId.equals(schoolId));
    }
    return q.get();
  }

  // Stream attendance for live reactive UI in GetX
  Stream<List<AttendanceRecord>> watchAttendanceForSectionAndDate({
    required String classId,
    required String sectionId,
    required String date,
    String? schoolId,
  }) {
    var q = select(attendanceRecords)
      ..where((t) =>
          t.classId.equals(classId) &
          t.sectionId.equals(sectionId) &
          t.date.equals(date));
    if (schoolId != null) {
      q = q..where((t) => t.schoolId.equals(schoolId));
    }
    return q.watch();
  }

  // Get single student record for a date
  Future<AttendanceRecord?> getStudentAttendanceForDate({
    required String studentId,
    required String date,
    String? schoolId,
  }) {
    var q = select(attendanceRecords)
      ..where((t) => t.studentId.equals(studentId) & t.date.equals(date));
    if (schoolId != null) {
      q = q..where((t) => t.schoolId.equals(schoolId));
    }
    return q.getSingleOrNull();
  }

  // Upsert attendance record (Insert or Update with audit trail)
  Future<AttendanceRecord> recordAttendance({
    required String id,
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
    required String idempotencyKey,
    String? editReason,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    return await transaction(() async {
      final existing = await getStudentAttendanceForDate(studentId: studentId, date: date);

      if (existing != null) {
        // Record audit if status changed
        if (existing.status != status || editReason != null) {
          await into(attendanceAuditLogs).insert(
            AttendanceAuditLogsCompanion.insert(
              id: 'aud_${DateTime.now().microsecondsSinceEpoch}_${studentId.hashCode.abs()}',
              attendanceRecordId: existing.id,
              changedByUserId: markedByUserId,
              oldStatus: Value(existing.status),
              newStatus: status,
              reason: editReason ?? 'Manual status correction',
              createdAt: now,
            ),
          );
        }

        final updated = existing.copyWith(
          status: status,
          arrivalTime: Value(arrivalTime ?? existing.arrivalTime),
          departureTime: Value(departureTime ?? existing.departureTime),
          remarks: Value(remarks ?? existing.remarks),
          markedByUserId: markedByUserId,
          markingMethod: markingMethod,
          updatedAt: now,
          revision: existing.revision + 1,
        );

        await update(attendanceRecords).replace(updated);
        return updated;
      } else {
        final newRecord = AttendanceRecord(
          id: id,
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
          createdAt: now,
          updatedAt: now,
          revision: 1,
        );

        await into(attendanceRecords).insert(newRecord);
        return newRecord;
      }
    });
  }

  // Get attendance records in a date range for reports
  Future<List<AttendanceRecord>> getAttendanceForDateRange({
    required String schoolId,
    String? classId,
    String? sectionId,
    String? studentId,
    required String startDate,
    required String endDate,
  }) {
    var query = select(attendanceRecords)
      ..where((t) =>
          t.schoolId.equals(schoolId) &
          t.date.isBiggerOrEqualValue(startDate) &
          t.date.isSmallerOrEqualValue(endDate));

    if (classId != null) {
      query = query..where((t) => t.classId.equals(classId));
    }
    if (sectionId != null) {
      query = query..where((t) => t.sectionId.equals(sectionId));
    }
    if (studentId != null) {
      query = query..where((t) => t.studentId.equals(studentId));
    }

    return (query..orderBy([(t) => OrderingTerm(expression: t.date)])).get();
  }

  // Get session for a section and date
  Future<AttendanceSessionModel?> getSession({
    required String sectionId,
    required String date,
    String? schoolId,
  }) async {
    final sql = schoolId != null
        ? 'SELECT * FROM attendance_sessions WHERE school_id = ? AND section_id = ? AND date = ? LIMIT 1'
        : 'SELECT * FROM attendance_sessions WHERE section_id = ? AND date = ? LIMIT 1';
    final vars = schoolId != null
        ? [Variable.withString(schoolId), Variable.withString(sectionId), Variable.withString(date)]
        : [Variable.withString(sectionId), Variable.withString(date)];
    final rows = await customSelect(sql, variables: vars).get();
    if (rows.isEmpty) return null;
    return AttendanceSessionModel.fromRow(rows.first);
  }

  // Upsert attendance session (draft or finalized)
  Future<AttendanceSessionModel> upsertSession({
    required String schoolId,
    required String classId,
    required String sectionId,
    required String date,
    required String status,
    String? finalizedByUserId,
    String? notes,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = 'ses_${sectionId}_$date';
    final existing = await getSession(sectionId: sectionId, date: date);
    final nextRev = (existing?.revision ?? 0) + 1;
    final finalizedAt = status == 'finalized' ? now : null;

    await customStatement(
      '''
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
      ''',
      [
        id,
        schoolId,
        classId,
        sectionId,
        date,
        status,
        finalizedByUserId,
        finalizedAt,
        notes,
        now,
        nextRev,
      ],
    );

    return AttendanceSessionModel(
      id: id,
      schoolId: schoolId,
      classId: classId,
      sectionId: sectionId,
      date: date,
      status: status,
      finalizedByUserId: finalizedByUserId,
      finalizedAt: finalizedAt,
      notes: notes,
      updatedAt: now,
      revision: nextRev,
    );
  }

  // Get all sessions for a school in a date range
  Future<List<AttendanceSessionModel>> getSessionsForRange({
    required String schoolId,
    required String startDate,
    required String endDate,
  }) async {
    final rows = await customSelect(
      'SELECT * FROM attendance_sessions WHERE school_id = ? AND date >= ? AND date <= ?',
      variables: [
        Variable.withString(schoolId),
        Variable.withString(startDate),
        Variable.withString(endDate),
      ],
    ).get();
    return rows.map((r) => AttendanceSessionModel.fromRow(r)).toList();
  }

  // Create a correction request (when teacher requests change on a finalized session)
  Future<CorrectionRequestModel> createCorrectionRequest({
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
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = 'cor_${studentId}_${date}_$now';

    await customStatement(
      '''
      INSERT INTO correction_requests
        (id, school_id, attendance_record_id, student_id, student_name, class_id, section_id, date, old_status, proposed_status, reason, requested_by_user_id, requested_by_name, status, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending', ?, ?)
      ''',
      [
        id,
        schoolId,
        attendanceRecordId,
        studentId,
        studentName,
        classId,
        sectionId,
        date,
        oldStatus,
        proposedStatus,
        reason,
        requestedByUserId,
        requestedByName,
        now,
        now,
      ],
    );

    return CorrectionRequestModel(
      id: id,
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
      status: 'pending',
      createdAt: now,
      updatedAt: now,
    );
  }

  // Get correction requests for a school
  Future<List<CorrectionRequestModel>> getCorrectionRequests({
    required String schoolId,
    String? status,
  }) async {
    if (status != null) {
      final rows = await customSelect(
        'SELECT * FROM correction_requests WHERE school_id = ? AND status = ? ORDER BY created_at DESC',
        variables: [Variable.withString(schoolId), Variable.withString(status)],
      ).get();
      return rows.map((r) => CorrectionRequestModel.fromRow(r)).toList();
    } else {
      final rows = await customSelect(
        'SELECT * FROM correction_requests WHERE school_id = ? ORDER BY created_at DESC',
        variables: [Variable.withString(schoolId)],
      ).get();
      return rows.map((r) => CorrectionRequestModel.fromRow(r)).toList();
    }
  }

  // Approve or Reject a correction request (Head Teacher / Admin)
  Future<void> reviewCorrectionRequest({
    required String requestId,
    required String decision, // 'approved' | 'rejected'
    required String reviewedByUserId,
    String? reviewRemarks,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await customStatement(
      '''
      UPDATE correction_requests
      SET status = ?, reviewed_by_user_id = ?, review_remarks = ?, updated_at = ?
      WHERE id = ?
      ''',
      [decision, reviewedByUserId, reviewRemarks, now, requestId],
    );
  }

  // Get recent audit logs for a school
  Future<List<AttendanceAuditLog>> getRecentAuditLogs({int limit = 100}) {
    return (select(attendanceAuditLogs)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .get();
  }
}
