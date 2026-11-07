import 'package:drift/drift.dart';
import 'tables.dart';
import 'connection/native.dart';
import 'daos/attendance_dao.dart';
import 'daos/student_dao.dart';
import 'daos/sync_dao.dart';

export '../../data/models/models.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Schools,
    Users,
    Classes,
    Sections,
    Students,
    ParentContacts,
    SchoolCalendarHolidays,
    AttendanceRecords,
    AttendanceAuditLogs,
    SyncQueue,
  ],
  daos: [
    AttendanceDao,
    StudentDao,
    SyncDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? openConnection());

  @override
  int get schemaVersion => 2;

  Future<void> _createExtendedKpkTables() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS school_settings (
        school_id TEXT PRIMARY KEY,
        school_type TEXT NOT NULL DEFAULT 'GPS',
        district TEXT NOT NULL DEFAULT 'Peshawar',
        tehsil TEXT NOT NULL DEFAULT 'City Peshawar',
        circle_office TEXT NOT NULL DEFAULT 'ASDEO Circle City-I',
        union_council TEXT NOT NULL DEFAULT 'UC-12',
        climate_zone TEXT NOT NULL DEFAULT 'summer_zone',
        opening_time TEXT NOT NULL DEFAULT '08:00',
        closing_time TEXT NOT NULL DEFAULT '13:30',
        late_cutoff_time TEXT NOT NULL DEFAULT '08:15',
        head_teacher_name TEXT NOT NULL DEFAULT 'Head Teacher',
        deo_name TEXT NOT NULL DEFAULT 'DEO Peshawar',
        working_days_csv TEXT NOT NULL DEFAULT '1,2,3,4,5,6',
        updated_at INTEGER NOT NULL DEFAULT 0,
        revision INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await customStatement('''
      CREATE TABLE IF NOT EXISTS student_extended_info (
        student_id TEXT PRIMARY KEY,
        student_b_form TEXT,
        father_cnic TEXT,
        mother_name TEXT,
        domicile_district TEXT,
        leaving_date TEXT,
        leaving_reason TEXT,
        slc_number TEXT,
        free_books_issued INTEGER NOT NULL DEFAULT 1,
        is_vaccinated INTEGER NOT NULL DEFAULT 0,
        vaccine_first_dose_date TEXT,
        vaccine_second_dose_date TEXT,
        previous_qr_tokens_json TEXT NOT NULL DEFAULT '[]',
        updated_at INTEGER NOT NULL DEFAULT 0,
        revision INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await customStatement('''
      CREATE TABLE IF NOT EXISTS attendance_sessions (
        id TEXT PRIMARY KEY,
        school_id TEXT NOT NULL,
        class_id TEXT NOT NULL,
        section_id TEXT NOT NULL,
        date TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'draft',
        finalized_by_user_id TEXT,
        finalized_at INTEGER,
        notes TEXT,
        updated_at INTEGER NOT NULL,
        revision INTEGER NOT NULL DEFAULT 1,
        UNIQUE(section_id, date)
      )
    ''');

    await customStatement('''
      CREATE TABLE IF NOT EXISTS correction_requests (
        id TEXT PRIMARY KEY,
        school_id TEXT NOT NULL,
        attendance_record_id TEXT NOT NULL,
        student_id TEXT NOT NULL,
        student_name TEXT,
        class_id TEXT NOT NULL,
        section_id TEXT NOT NULL,
        date TEXT NOT NULL,
        old_status TEXT NOT NULL,
        proposed_status TEXT NOT NULL,
        reason TEXT NOT NULL,
        requested_by_user_id TEXT NOT NULL,
        requested_by_name TEXT,
        status TEXT NOT NULL DEFAULT 'pending',
        reviewed_by_user_id TEXT,
        review_remarks TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        revision INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await customStatement('''
      CREATE TABLE IF NOT EXISTS sync_conflicts (
        id TEXT PRIMARY KEY,
        school_id TEXT,
        record_id TEXT NOT NULL,
        table_name TEXT NOT NULL,
        student_id TEXT NOT NULL,
        date TEXT NOT NULL,
        local_status TEXT NOT NULL,
        server_status TEXT NOT NULL,
        conflict_reason TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'unresolved',
        created_at INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _migrateUserColumns() async {
    try {
      await customStatement('ALTER TABLE users ADD COLUMN avatar_url TEXT');
    } catch (_) {}
    try {
      await customStatement('ALTER TABLE users ADD COLUMN cnic TEXT');
    } catch (_) {}
    try {
      await customStatement('ALTER TABLE users ADD COLUMN designation TEXT');
    } catch (_) {}
    try {
      await customStatement('ALTER TABLE school_settings ADD COLUMN revision INTEGER NOT NULL DEFAULT 1');
    } catch (_) {}
    try {
      await customStatement('ALTER TABLE student_extended_info ADD COLUMN revision INTEGER NOT NULL DEFAULT 1');
    } catch (_) {}
    try {
      await customStatement('ALTER TABLE correction_requests ADD COLUMN revision INTEGER NOT NULL DEFAULT 1');
    } catch (_) {}
    try {
      await customStatement('ALTER TABLE sync_conflicts ADD COLUMN school_id TEXT');
    } catch (_) {}
    try {
      await customStatement('ALTER TABLE students ADD COLUMN student_cnic TEXT');
    } catch (_) {}
    try {
      await customStatement('ALTER TABLE students ADD COLUMN father_cnic TEXT');
    } catch (_) {}
    try {
      await customStatement('ALTER TABLE students ADD COLUMN is_vaccinated INTEGER NOT NULL DEFAULT 0');
    } catch (_) {}
    try {
      await customStatement('ALTER TABLE students ADD COLUMN vaccine_first_dose_date TEXT');
    } catch (_) {}
    try {
      await customStatement('ALTER TABLE students ADD COLUMN vaccine_second_dose_date TEXT');
    } catch (_) {}
    try {
      await customStatement('ALTER TABLE student_extended_info ADD COLUMN is_vaccinated INTEGER NOT NULL DEFAULT 0');
    } catch (_) {}
    try {
      await customStatement('ALTER TABLE student_extended_info ADD COLUMN vaccine_first_dose_date TEXT');
    } catch (_) {}
    try {
      await customStatement('ALTER TABLE student_extended_info ADD COLUMN vaccine_second_dose_date TEXT');
    } catch (_) {}
  }

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _createExtendedKpkTables();
        await _migrateUserColumns();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await _createExtendedKpkTables();
        }
        await _migrateUserColumns();
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
        try {
          await customStatement('PRAGMA journal_mode = WAL');
          await customStatement('PRAGMA synchronous = NORMAL');
        } catch (_) {}
        await _createExtendedKpkTables();
        await _migrateUserColumns();
      },
    );
  }

  // Clear all data (for testing / account switch)
  Future<void> clearAllData() async {
    await transaction(() async {
      await customStatement('DELETE FROM sync_conflicts');
      await customStatement('DELETE FROM correction_requests');
      await customStatement('DELETE FROM attendance_sessions');
      await customStatement('DELETE FROM student_extended_info');
      await customStatement('DELETE FROM school_settings');
      await delete(syncQueue).go();
      await delete(attendanceAuditLogs).go();
      await delete(attendanceRecords).go();
      await delete(schoolCalendarHolidays).go();
      await delete(parentContacts).go();
      await delete(students).go();
      await delete(sections).go();
      await delete(classes).go();
      await delete(users).go();
      await delete(schools).go();
    });
  }

  /// Enforce strict multi-tenant isolation on the device:
  /// Purges any records that belong to a different school_id so no cross-tenant leakage can occur.
  Future<void> clearDataForOtherSchools(String currentSchoolId) async {
    await transaction(() async {
      try {
        await customStatement('DELETE FROM sync_conflicts');
      } catch (_) {}
      try {
        await customStatement('DELETE FROM correction_requests WHERE school_id != ?', [currentSchoolId]);
      } catch (_) {}
      try {
        await customStatement('DELETE FROM attendance_sessions WHERE school_id != ?', [currentSchoolId]);
      } catch (_) {}
      try {
        await customStatement(
          'DELETE FROM student_extended_info WHERE student_id IN (SELECT id FROM students WHERE school_id != ?)',
          [currentSchoolId],
        );
      } catch (_) {}
      try {
        await customStatement('DELETE FROM school_settings WHERE school_id != ?', [currentSchoolId]);
      } catch (_) {}
      try {
        await customStatement(
          'DELETE FROM parent_contacts WHERE student_id IN (SELECT id FROM students WHERE school_id != ?)',
          [currentSchoolId],
        );
      } catch (_) {}
      try {
        await customStatement(
          'DELETE FROM attendance_audit_logs WHERE attendance_record_id IN (SELECT id FROM attendance_records WHERE school_id != ?)',
          [currentSchoolId],
        );
      } catch (_) {}
      try {
        await (delete(attendanceRecords)..where((t) => t.schoolId.isNotValue(currentSchoolId))).go();
      } catch (_) {}
      try {
        await (delete(schoolCalendarHolidays)..where((t) => t.schoolId.isNotValue(currentSchoolId))).go();
      } catch (_) {}
      try {
        await (delete(students)..where((t) => t.schoolId.isNotValue(currentSchoolId))).go();
      } catch (_) {}
      try {
        await (delete(sections)..where((t) => t.schoolId.isNotValue(currentSchoolId))).go();
      } catch (_) {}
      try {
        await (delete(classes)..where((t) => t.schoolId.isNotValue(currentSchoolId))).go();
      } catch (_) {}
      try {
        await (delete(users)..where((t) => t.schoolId.isNotValue(currentSchoolId))).go();
      } catch (_) {}
      try {
        await (delete(schools)..where((t) => t.id.isNotValue(currentSchoolId))).go();
      } catch (_) {}
    });
  }
}
