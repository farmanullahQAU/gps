import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:gps/core/database/app_database.dart';
import 'package:gps/data/repositories/attendance_repository.dart';
import 'package:gps/data/repositories/student_repository.dart';

void main() {
  late AppDatabase db;
  late AttendanceRepository attendanceRepo;
  late StudentRepository studentRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    attendanceRepo = AttendanceRepository(db);
    studentRepo = StudentRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('Complete KPK attendance lifecycle: marking, session finalization, correction requests, QR rotation, and CSV import', () async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final schoolId = 'sch_test';
    final classId = 'cls_1';
    final sectionId = 'sec_1';
    final date = '2026-10-27';

    // 1. Setup KPK school, class, section
    await db.into(db.schools).insert(
          SchoolsCompanion.insert(
            id: schoolId,
            name: 'Govt Primary School Gulbahar No. 1 Peshawar',
            code: 'EMIS-12405',
            academicYearStart: '2026-04-01',
            academicYearEnd: '2027-03-31',
            createdAt: now,
            updatedAt: now,
          ),
        );

    await db.into(db.classes).insert(
          ClassesCompanion.insert(
            id: classId,
            schoolId: schoolId,
            name: 'Class Pakki / 1st',
            createdAt: now,
            updatedAt: now,
          ),
        );

    await db.into(db.sections).insert(
          SectionsCompanion.insert(
            id: sectionId,
            schoolId: schoolId,
            classId: classId,
            name: 'Section A',
            createdAt: now,
            updatedAt: now,
          ),
        );

    // 2. Register 3 students
    final std1 = await studentRepo.createStudent(
      schoolId: schoolId,
      classId: classId,
      sectionId: sectionId,
      admissionNumber: 'KPK-001',
      rollNumber: '1',
      fullName: 'Muhammad Ali Khan',
      fatherOrGuardianName: 'Asif Ullah Khan',
      gender: 'male',
      admissionDate: '2026-04-01',
      parentPhone: '+923331234567',
      studentBForm: '17301-1122334-1',
    );

    final std2 = await studentRepo.createStudent(
      schoolId: schoolId,
      classId: classId,
      sectionId: sectionId,
      admissionNumber: 'KPK-002',
      rollNumber: '2',
      fullName: 'Hamza Shinwari',
      fatherOrGuardianName: 'Zahir Shah',
      gender: 'male',
      admissionDate: '2026-04-01',
      parentPhone: '+923332345678',
    );

    final std3 = await studentRepo.createStudent(
      schoolId: schoolId,
      classId: classId,
      sectionId: sectionId,
      admissionNumber: 'KPK-003',
      rollNumber: '3',
      fullName: 'Ahmed Raza Khattak',
      fatherOrGuardianName: 'Kamran Khattak',
      gender: 'male',
      admissionDate: '2026-04-01',
      parentPhone: '+923333456789',
    );

    // Verify duplicate admission number is rejected
    expect(
      () => studentRepo.createStudent(
        schoolId: schoolId,
        classId: classId,
        sectionId: sectionId,
        admissionNumber: 'KPK-001',
        fullName: 'Duplicate Student',
        fatherOrGuardianName: 'Test Father',
        gender: 'male',
        admissionDate: '2026-04-01',
        parentPhone: '+923330000000',
      ),
      throwsException,
    );

    // Verify opaque QR token does not leak student name or admission number
    expect(std1.qrToken.contains('Muhammad'), false);
    expect(std1.qrToken.contains('KPK-001'), false);
    expect(std1.qrToken.startsWith('KPK_QR_'), true);

    // 3. Test QR Token Rotation & Revocation
    final oldQrToken = std1.qrToken;
    final rotatedStd1 = await studentRepo.rotateStudentQrToken(std1);
    expect(rotatedStd1.qrToken != oldQrToken, true);
    expect(await studentRepo.getStudentByQrToken(oldQrToken), isNull);
    final revokedOwner = await studentRepo.findStudentByRevokedQrToken(oldQrToken);
    expect(revokedOwner?.id, std1.id);

    // 4. Mark Student 1 Present and Student 2 Late (with arrival time)
    await attendanceRepo.markAttendance(
      schoolId: schoolId,
      studentId: std1.id,
      classId: classId,
      sectionId: sectionId,
      date: date,
      status: 'present',
      markedByUserId: 'usr_teacher_1',
      markingMethod: 'manual',
    );

    await attendanceRepo.markAttendance(
      schoolId: schoolId,
      studentId: std2.id,
      classId: classId,
      sectionId: sectionId,
      date: date,
      status: 'late',
      arrivalTime: '08:25:00',
      markedByUserId: 'usr_teacher_1',
      markingMethod: 'qr_scan',
    );

    var currentAttendance = await attendanceRepo.getAttendance(classId: classId, sectionId: sectionId, date: date);
    expect(currentAttendance.length, 2);
    expect(currentAttendance.any((r) => r.studentId == std3.id), false);

    // 5. Verify Sync Outbox Queue has items with deterministic idempotency keys
    final pendingSync = await db.syncDao.getPendingItems();
    expect(pendingSync.any((item) => item.idempotencyKey == 'att_${std1.id}_$date'), true);
    expect(pendingSync.any((item) => item.idempotencyKey == 'att_${std2.id}_$date'), true);

    // 6. Test Status Correction and Audit Log
    await attendanceRepo.markAttendance(
      schoolId: schoolId,
      studentId: std2.id,
      classId: classId,
      sectionId: sectionId,
      date: date,
      status: 'present',
      markedByUserId: 'usr_admin_1',
      markingMethod: 'manual',
      editReason: 'Student was delayed due to school bus puncture',
    );

    final auditLogs = await db.select(db.attendanceAuditLogs).get();
    expect(auditLogs.length, 1);
    expect(auditLogs.first.oldStatus, 'late');
    expect(auditLogs.first.newStatus, 'present');

    // 7. Test Mark All Present with Undo
    final snapshotBefore = await attendanceRepo.markAllPresent(
      schoolId: schoolId,
      classId: classId,
      sectionId: sectionId,
      date: date,
      markedByUserId: 'usr_teacher_1',
      studentIds: [std1.id, std2.id, std3.id],
    );

    currentAttendance = await attendanceRepo.getAttendance(classId: classId, sectionId: sectionId, date: date);
    expect(currentAttendance.length, 3);
    expect(currentAttendance.every((r) => r.status == 'present'), true);

    await attendanceRepo.restoreAttendanceSnapshot(
      previousRecords: snapshotBefore,
      studentIds: [std1.id, std2.id, std3.id],
      date: date,
    );

    currentAttendance = await attendanceRepo.getAttendance(classId: classId, sectionId: sectionId, date: date);
    expect(currentAttendance.length, 2);
    expect(currentAttendance.any((r) => r.studentId == std3.id), false);

    // 8. Test Session Finalization & Correction Request Approval Workflow
    final session = await attendanceRepo.updateSessionStatus(
      schoolId: schoolId,
      classId: classId,
      sectionId: sectionId,
      date: date,
      status: 'finalized',
      userId: 'usr_teacher_1',
    );
    expect(session.isFinalized, true);

    final corReq = await attendanceRepo.submitCorrectionRequest(
      schoolId: schoolId,
      attendanceRecordId: 'att_${std1.id}_$date',
      studentId: std1.id,
      studentName: std1.fullName,
      classId: classId,
      sectionId: sectionId,
      date: date,
      oldStatus: 'present',
      proposedStatus: 'approved_leave',
      reason: 'Medical leave application verified',
      requestedByUserId: 'usr_teacher_1',
      requestedByName: 'Zahid Hussain (PST)',
    );
    expect(corReq.status, 'pending');

    await attendanceRepo.reviewCorrectionRequest(
      request: corReq,
      decision: 'approved',
      reviewedByUserId: 'usr_admin_1',
      reviewRemarks: 'Approved by Head Teacher',
    );

    final updatedStd1Att = await db.attendanceDao.getStudentAttendanceForDate(studentId: std1.id, date: date);
    expect(updatedStd1Att?.status, 'approved_leave');

    // 9. Test Bulk CSV Student Import
    final imported = await studentRepo.bulkImportCsv(
      schoolId: schoolId,
      classId: classId,
      sectionId: sectionId,
      csvContent: 'AdmissionNo,RollNo,FullName,FatherName,Gender,ParentPhone\n'
          'KPK-004,4,Junaid Khan,Rashid Khan,male,+923331112222\n'
          'KPK-005,5,Fawad Afridi,Alamgir Afridi,male,+923333334444',
    );
    expect(imported, 2);
    final allInSec = await studentRepo.getStudentsForSection(classId: classId, sectionId: sectionId);
    expect(allInSec.length, 5);

    // 10. Test Multi-Class CSV Import & Class Isolation
    final class2Id = 'cls_2';
    final sec2Id = 'sec_2_a';
    await db.into(db.classes).insert(
          ClassesCompanion.insert(
            id: class2Id,
            schoolId: schoolId,
            name: 'Class 2nd',
            numericLevel: const Value(2),
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db.into(db.sections).insert(
          SectionsCompanion.insert(
            id: sec2Id,
            schoolId: schoolId,
            classId: class2Id,
            name: 'Section A',
            createdAt: now,
            updatedAt: now,
          ),
        );

    final multiImportCount = await studentRepo.bulkImportCsv(
      schoolId: schoolId,
      csvContent: 'Class,Section,AdmissionNo,RollNo,FullName,FatherName,Gender,ParentPhone,BForm,QrToken\n'
          'Class Pakki / 1st,Section A,KPK-006,6,Student Six,Father Six,male,+923000000001,17301-0000006-1,TOKEN_C1_6\n'
          'Class 2nd,Section A,KPK-201,1,Student Two One,Father Two,male,+923000000002,17301-0000201-1,TOKEN_C2_1',
    );
    expect(multiImportCount, 2);

    final c1Students = await studentRepo.getStudentsForSection(classId: classId, sectionId: sectionId);
    final c2Students = await studentRepo.getStudentsForSection(classId: class2Id, sectionId: sec2Id);
    expect(c1Students.any((s) => s.admissionNumber == 'KPK-006'), true);
    expect(c1Students.any((s) => s.admissionNumber == 'KPK-201'), false); // Class 2 student NOT in Class 1
    expect(c2Students.any((s) => s.admissionNumber == 'KPK-201'), true); // Class 2 student accurately in Class 2

    // 11. Test Custom Header Mapped Import (ADM_NO, ADM_DATE, STD_NAME, STD_FNAME, DOB, GENDER, CNIC, VACCINATED, FIRST_DOSE, SECOND_DOSE, F_CNIC, CLS_ROLL_NO)
    final customHeaderImport = await studentRepo.bulkImportCsv(
      schoolId: schoolId,
      classId: classId,
      sectionId: sectionId,
      csvContent: 'ADM_NO\tADM_DATE\tSTD_NAME\tSTD_FNAME\tDOB\tGENDER\tCNIC\tVACCINATED\tFIRST_DOSE\tSECOND_DOSE\tF_CNIC\tCLS_ROLL_NO\n'
          'KPK-701\t2026-04-10\tZeeshan Khan\tNaveed Khan\t2018-05-15\tmale\t17301-1234567-1\tYes\t2025-01-10\t2025-02-15\t17301-9876543-1\t7\n'
          'KPK-702\t2026-04-11\tAmina Bibi\tKamran Ullah\t2018-08-20\tfemale\t17301-7654321-2\tNo\t\t\t17301-5432109-1\t8',
    );
    expect(customHeaderImport, 2);

    final s701 = (await studentRepo.getStudentsForSection(classId: classId, sectionId: sectionId))
        .firstWhere((s) => s.admissionNumber == 'KPK-701');
    expect(s701.fullName, 'Zeeshan Khan');
    expect(s701.fatherOrGuardianName, 'Naveed Khan');
    expect(s701.admissionDate, '2026-04-10');
    expect(s701.dateOfBirth, '2018-05-15');
    expect(s701.studentCnic, '17301-1234567-1');
    expect(s701.fatherCnic, '17301-9876543-1');
    expect(s701.rollNumber, '7');
    expect(s701.isVaccinated, true);
    expect(s701.vaccineFirstDoseDate, '2025-01-10');
    expect(s701.vaccineSecondDoseDate, '2025-02-15');

    final s702 = (await studentRepo.getStudentsForSection(classId: classId, sectionId: sectionId))
        .firstWhere((s) => s.admissionNumber == 'KPK-702');
    expect(s702.fullName, 'Amina Bibi');
    expect(s702.gender, 'female');
    expect(s702.isVaccinated, false);
  });
}
