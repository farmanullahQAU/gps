// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_dao.dart';

// ignore_for_file: type=lint
mixin _$AttendanceDaoMixin on DatabaseAccessor<AppDatabase> {
  $AttendanceRecordsTable get attendanceRecords =>
      attachedDatabase.attendanceRecords;
  $AttendanceAuditLogsTable get attendanceAuditLogs =>
      attachedDatabase.attendanceAuditLogs;
  $StudentsTable get students => attachedDatabase.students;
  $ClassesTable get classes => attachedDatabase.classes;
  $SectionsTable get sections => attachedDatabase.sections;
  $AttendanceSessionsTable get attendanceSessions =>
      attachedDatabase.attendanceSessions;
  $CorrectionRequestsTable get correctionRequests =>
      attachedDatabase.correctionRequests;
  AttendanceDaoManager get managers => AttendanceDaoManager(this);
}

class AttendanceDaoManager {
  final _$AttendanceDaoMixin _db;
  AttendanceDaoManager(this._db);
  $$AttendanceRecordsTableTableManager get attendanceRecords =>
      $$AttendanceRecordsTableTableManager(
        _db.attachedDatabase,
        _db.attendanceRecords,
      );
  $$AttendanceAuditLogsTableTableManager get attendanceAuditLogs =>
      $$AttendanceAuditLogsTableTableManager(
        _db.attachedDatabase,
        _db.attendanceAuditLogs,
      );
  $$StudentsTableTableManager get students =>
      $$StudentsTableTableManager(_db.attachedDatabase, _db.students);
  $$ClassesTableTableManager get classes =>
      $$ClassesTableTableManager(_db.attachedDatabase, _db.classes);
  $$SectionsTableTableManager get sections =>
      $$SectionsTableTableManager(_db.attachedDatabase, _db.sections);
  $$AttendanceSessionsTableTableManager get attendanceSessions =>
      $$AttendanceSessionsTableTableManager(
        _db.attachedDatabase,
        _db.attendanceSessions,
      );
  $$CorrectionRequestsTableTableManager get correctionRequests =>
      $$CorrectionRequestsTableTableManager(
        _db.attachedDatabase,
        _db.correctionRequests,
      );
}
