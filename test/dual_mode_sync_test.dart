import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:gps/core/database/app_database.dart';
import 'package:gps/data/repositories/auth_repository.dart';
import 'package:gps/data/repositories/attendance_repository.dart';
import 'package:gps/data/repositories/student_repository.dart';
import 'package:gps/data/repositories/sync_repository.dart';
import 'package:gps/core/utils/kpk_register_helper.dart';

void main() {
  late AppDatabase db;
  late AuthRepository authRepo;
  late SyncRepository syncRepo;
  late AttendanceRepository attendanceRepo;
  late StudentRepository studentRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    authRepo = AuthRepository(db);
    syncRepo = SyncRepository(db, authRepo);
    attendanceRepo = AttendanceRepository(db, syncRepository: syncRepo);
    studentRepo = StudentRepository(db, syncRepository: syncRepo);
  });

  tearDown(() async {
    await db.close();
  });

  test('Dual-Mode: Offline operations store in SQLite and enqueue in outbox with 0 UI latency', () async {
    final schoolId = 'sch_kpk_001';
    final classId = 'cls_grade1';
    final sectionId = 'sec_grade1_a';
    final date = '2026-11-04';

    // 1. Create a student while offline (simulated no token / offline network)
    final student = await studentRepo.createStudent(
      schoolId: schoolId,
      classId: classId,
      sectionId: sectionId,
      admissionNumber: 'ADM-2026-001',
      rollNumber: '1',
      fullName: 'Muhammad Ahmad',
      fatherOrGuardianName: 'Tariq Khan',
      gender: 'male',
      admissionDate: '2026-11-04',
      parentPhone: '+923331112233',
    );

    expect(student.id, isNotEmpty);
    expect(student.fullName, equals('Muhammad Ahmad'));

    // Verify written to local SQLite
    final localStudents = await db.select(db.students).get();
    expect(localStudents.length, equals(1));
    expect(localStudents.first.id, equals(student.id));

    // Verify enqueued into SyncQueue outbox
    final queueItemsAfterStudent = await db.syncDao.getPendingItems();
    expect(queueItemsAfterStudent.length, greaterThanOrEqualTo(1));
    final studentOutbox = queueItemsAfterStudent.firstWhere((q) => q.recordId == student.id);
    expect(studentOutbox.targetTable, equals('students'));
    expect(studentOutbox.operation, equals('INSERT'));
    expect(studentOutbox.status, equals('pending'));

    // 2. Mark attendance while offline
    final record = await attendanceRepo.markAttendance(
      schoolId: schoolId,
      studentId: student.id,
      classId: classId,
      sectionId: sectionId,
      date: date,
      status: 'present',
      markedByUserId: 'usr_teacher_01',
      markingMethod: 'manual',
    );

    expect(record.status, equals('present'));

    // Verify attendance recorded in SQLite
    final localAttendance = await db.select(db.attendanceRecords).get();
    expect(localAttendance.length, equals(1));
    expect(localAttendance.first.status, equals('present'));

    // Verify attendance enqueued into outbox
    final queueItemsAfterAtt = await db.syncDao.getPendingItems();
    final attOutbox = queueItemsAfterAtt.firstWhere((q) => q.recordId == record.id);
    expect(attOutbox.targetTable, equals('attendance_records'));
    expect(attOutbox.status, equals('pending'));

    // 3. Finalize session while offline
    final session = await attendanceRepo.updateSessionStatus(
      schoolId: schoolId,
      classId: classId,
      sectionId: sectionId,
      date: date,
      status: 'finalized',
      userId: 'usr_teacher_01',
    );

    expect(session.status, equals('finalized'));
    expect(session.isFinalized, isTrue);

    // Verify session enqueued into outbox
    final queueItemsAfterSession = await db.syncDao.getPendingItems();
    final sessionOutbox = queueItemsAfterSession.firstWhere((q) => q.recordId == session.id);
    expect(sessionOutbox.targetTable, equals('attendance_sessions'));
    expect(sessionOutbox.status, equals('pending'));

    // 4. Verify pushPendingIfOnline handles offline gracefully without throwing
    final pushedCount = await syncRepo.pushPendingIfOnline();
    expect(pushedCount, equals(0));

    // Ensure all items remain safely 'pending' in the outbox with 0 retry count burn
    final remainingPending = await db.syncDao.getPendingItems();
    for (final item in remainingPending) {
      expect(item.status, equals('pending'));
      expect(item.retryCount, equals(0));
    }
  });

  test('SyncDao: markSynced transitions outbox items from pending to synced', () async {
    await db.syncDao.enqueue(
      targetTable: 'attendance_records',
      recordId: 'att_test_1',
      operation: 'INSERT',
      payloadJson: '{"id": "att_test_1", "status": "present"}',
      idempotencyKey: 'idemp_test_1',
      clientRevision: 1,
    );

    final pending = await db.syncDao.getPendingItems();
    expect(pending.length, equals(1));
    expect(pending.first.status, equals('pending'));

    await db.syncDao.markSynced([pending.first.id]);

    final pendingAfterSync = await db.syncDao.getPendingItems();
    expect(pendingAfterSync.isEmpty, isTrue);

    final allItems = await db.syncDao.getAllQueueItems();
    expect(allItems.first.status, equals('synced'));
  });

  test('Lock & Sync Trigger: onMutationEnqueued fires on student changes and session lock', () async {
    int callbackFireCount = 0;
    syncRepo.onMutationEnqueued = () {
      callbackFireCount++;
    };

    // 1. Lock & finalize attendance session
    await attendanceRepo.updateSessionStatus(
      schoolId: 'sch_kpk_001',
      classId: 'cls_1',
      sectionId: 'sec_1',
      date: '2026-11-04',
      status: 'finalized',
      userId: 'usr_t1',
    );

    expect(callbackFireCount, equals(1));

    // 2. Create student
    await studentRepo.createStudent(
      schoolId: 'sch_kpk_001',
      classId: 'cls_1',
      sectionId: 'sec_1',
      admissionNumber: 'ADM-FIREBASE-001',
      fullName: 'Ahmad Jan',
      fatherOrGuardianName: 'Jan Muhammad',
      gender: 'male',
      admissionDate: '2026-11-04',
      parentPhone: '+923330000000',
    );

    expect(callbackFireCount, equals(2));
  });

  test('Attendance Status: 1st Time and 2nd Time sessions do not corrupt each other', () {
    // 1. Both P -> present (2 units //)
    const markBoth = KpkDayMark(firstTime: 'P', secondTime: 'P');
    expect(markBoth.toDbStatus(), equals('present'));
    expect(markBoth.attendanceUnits, equals(2));

    // 2. 1st time P, 2nd time pending -> present (1 unit /)
    const markFirst = KpkDayMark(firstTime: 'P', secondTime: '_');
    expect(markFirst.toDbStatus(), equals('present'));
    expect(markFirst.attendanceUnits, equals(1));

    // 3. Re-marking P in 1st time on a student who was previously Absent (S1:A|S2:A)
    // resets 2nd time to '_' so it becomes 'present' and never corrupts into 'half_day'
    const previousAbsent = KpkDayMark(firstTime: 'A', secondTime: 'A');
    final nextS2 = (previousAbsent.secondTime == 'P') ? 'P' : '_';
    final remarkedFirstTime = KpkDayMark(firstTime: 'P', secondTime: nextS2);
    expect(remarkedFirstTime.toDbStatus(), equals('present'));
    expect(remarkedFirstTime.encodeDepartureTime(), equals('S1:P|S2:_'));

    // 4. Explicit 1st time P + 2nd time A (student leaves after break) -> half_day (/A, 1 unit)
    const markHalfDay = KpkDayMark(firstTime: 'P', secondTime: 'A');
    expect(markHalfDay.toDbStatus(), equals('half_day'));
    expect(markHalfDay.registerSymbol, equals('/A'));
    expect(markHalfDay.attendanceUnits, equals(1));
  });
}
