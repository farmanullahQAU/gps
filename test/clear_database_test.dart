import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:gps/core/database/app_database.dart';

void main() {
  test('Verify clearAllData cleanly wipes all database tables', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() => db.close());

    final now = DateTime.now().millisecondsSinceEpoch;

    // 1. Seed school, class, section, student, user
    await db.into(db.schools).insert(
          SchoolsCompanion.insert(
            id: 'sch_test',
            name: 'Test GPS',
            code: 'EMIS-TEST',
            academicYearStart: '2026-04-01',
            academicYearEnd: '2027-03-31',
            createdAt: now,
            updatedAt: now,
          ),
        );

    await db.into(db.users).insert(
          UsersCompanion.insert(
            id: 'usr_test',
            schoolId: 'sch_test',
            name: 'Teacher Test',
            role: 'teacher',
            createdAt: now,
            updatedAt: now,
          ),
        );

    await db.into(db.classes).insert(
          ClassesCompanion.insert(
            id: 'cls_test',
            schoolId: 'sch_test',
            name: 'Class 1',
            createdAt: now,
            updatedAt: now,
          ),
        );

    await db.into(db.sections).insert(
          SectionsCompanion.insert(
            id: 'sec_test',
            schoolId: 'sch_test',
            classId: 'cls_test',
            name: 'Section A',
            createdAt: now,
            updatedAt: now,
          ),
        );

    await db.into(db.students).insert(
          StudentsCompanion.insert(
            id: 'std_test',
            schoolId: 'sch_test',
            classId: 'cls_test',
            sectionId: 'sec_test',
            admissionNumber: '101',
            fullName: 'Ahmad Khan',
            fatherOrGuardianName: 'Khan',
            gender: 'male',
            admissionDate: '2026-04-01',
            qrToken: 'QR_TOK_TEST_001',
            createdAt: now,
            updatedAt: now,
          ),
        );

    // Verify records exist before wipe
    expect((await db.select(db.schools).get()).length, 1);
    expect((await db.select(db.users).get()).length, 1);
    expect((await db.select(db.classes).get()).length, 1);
    expect((await db.select(db.sections).get()).length, 1);
    expect((await db.select(db.students).get()).length, 1);

    // 2. Execute clearAllData()
    await db.clearAllData();

    // 3. Verify ALL tables are completely empty
    expect((await db.select(db.schools).get()).length, 0);
    expect((await db.select(db.users).get()).length, 0);
    expect((await db.select(db.classes).get()).length, 0);
    expect((await db.select(db.sections).get()).length, 0);
    expect((await db.select(db.students).get()).length, 0);
    expect((await db.select(db.attendanceRecords).get()).length, 0);
    expect((await db.select(db.attendanceAuditLogs).get()).length, 0);
    expect((await db.select(db.parentContacts).get()).length, 0);
    expect((await db.select(db.schoolCalendarHolidays).get()).length, 0);
    expect((await db.select(db.syncQueue).get()).length, 0);
  });
}
