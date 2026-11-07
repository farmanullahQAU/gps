import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:gps/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('Database schema initializes and supports student insertion', () async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // Insert School
    await db.into(db.schools).insert(
      SchoolsCompanion.insert(
        id: 'sch_1',
        name: 'Govt Primary School Model Town',
        code: 'GPS-001',
        academicYearStart: '2026-04-01',
        academicYearEnd: '2027-03-31',
        createdAt: now,
        updatedAt: now,
      ),
    );

    // Insert Class & Section
    await db.into(db.classes).insert(
      ClassesCompanion.insert(
        id: 'cls_1',
        schoolId: 'sch_1',
        name: 'Class 1',
        createdAt: now,
        updatedAt: now,
      ),
    );

    await db.into(db.sections).insert(
      SectionsCompanion.insert(
        id: 'sec_1',
        schoolId: 'sch_1',
        classId: 'cls_1',
        name: 'Section A',
        createdAt: now,
        updatedAt: now,
      ),
    );

    // Insert Student
    await db.into(db.students).insert(
      StudentsCompanion.insert(
        id: 'std_1',
        schoolId: 'sch_1',
        classId: 'cls_1',
        sectionId: 'sec_1',
        admissionNumber: 'ADM-001',
        fullName: 'Muhammad Ali',
        fatherOrGuardianName: 'Muhammad Asif',
        gender: 'male',
        admissionDate: '2026-04-01',
        qrToken: 'QR_TOK_12345',
        createdAt: now,
        updatedAt: now,
      ),
    );

    final students = await db.select(db.students).get();
    expect(students.length, 1);
    expect(students.first.fullName, 'Muhammad Ali');
    expect(students.first.admissionNumber, 'ADM-001');

    // Test Attendance uniqueness constraint per student per date
    await db.into(db.attendanceRecords).insert(
      AttendanceRecordsCompanion.insert(
        id: 'att_1',
        schoolId: 'sch_1',
        studentId: 'std_1',
        classId: 'cls_1',
        sectionId: 'sec_1',
        date: '2026-10-27',
        status: 'present',
        markedByUserId: 'usr_teacher_1',
        markingMethod: 'qr_scan',
        idempotencyKey: 'idem_key_1',
        createdAt: now,
        updatedAt: now,
      ),
    );

    final attendance = await db.select(db.attendanceRecords).get();
    expect(attendance.length, 1);
    expect(attendance.first.status, 'present');

    // Duplicate insert for same student & date should throw
    expect(
      () => db.into(db.attendanceRecords).insert(
        AttendanceRecordsCompanion.insert(
          id: 'att_2',
          schoolId: 'sch_1',
          studentId: 'std_1',
          classId: 'cls_1',
          sectionId: 'sec_1',
          date: '2026-10-27',
          status: 'absent',
          markedByUserId: 'usr_teacher_1',
          markingMethod: 'manual',
          idempotencyKey: 'idem_key_2',
          createdAt: now,
          updatedAt: now,
        ),
      ),
      throwsException,
    );
  });
}
