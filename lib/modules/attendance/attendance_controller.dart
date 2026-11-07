import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/database/app_database.dart';
import '../../core/utils/kpk_register_helper.dart';
import '../../data/repositories/attendance_repository.dart';
import '../../data/repositories/student_repository.dart';
import '../auth/auth_controller.dart';
import '../sync/sync_controller.dart';
import '../../core/services/notification_service.dart';

class AttendanceController extends GetxController {
  final AttendanceRepository attendanceRepository;
  final StudentRepository studentRepository;

  AttendanceController({
    required this.attendanceRepository,
    required this.studentRepository,
  });

  // Selected state
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<ClassesData?> selectedClass = Rx<ClassesData?>(null);
  final Rx<Section?> selectedSection = Rx<Section?>(null);
  final Rx<AttendanceSessionModel?> currentSession = Rx<AttendanceSessionModel?>(null);
  final Rx<SchoolCalendarHoliday?> activeHoliday = Rx<SchoolCalendarHoliday?>(null);

  /// KPK Two-Time Daily Attendance slot:
  /// `1` = 1st Time (Morning / اول وقت `/`), `2` = 2nd Time (After Break / دوم وقت `//`)
  final RxInt selectedTimeSlot = 1.obs;

  /// Reactive KPK Monthly Register Summary (`اوسط حاضری` & `فیصد حاضری`) for the selected class & month
  final Rx<KpkMonthlySummary?> currentMonthKpkSummary = Rx<KpkMonthlySummary?>(null);

  // Data lists
  final RxList<ClassesData> classesList = <ClassesData>[].obs;
  final RxList<Section> sectionsList = <Section>[].obs;
  final RxList<Student> studentsList = <Student>[].obs;
  final RxMap<String, AttendanceRecord> attendanceMap = <String, AttendanceRecord>{}.obs;

  // School-wide Admin KPI & Chart metrics
  final RxInt schoolTotalActiveStudents = 0.obs;
  final RxInt schoolTotalTeachers = 0.obs;
  final RxInt pendingCorrectionsCount = 0.obs;
  final RxMap<String, int> classEnrollmentMap = <String, int>{}.obs;
  final RxMap<String, int> classAttendedMap = <String, int>{}.obs;
  final RxMap<String, String> classFormMasterNameMap = <String, String>{}.obs;
  final RxMap<String, String?> classFormMasterIdMap = <String, String?>{}.obs;

  String get currentClassFormMaster =>
      classFormMasterNameMap[selectedClass.value?.id] ?? 'Unassigned';

  /// Only the assigned Form Master (Class Teacher) or the Head Teacher (Admin) can take attendance.
  /// If a section has an assigned teacher, that teacher is the Form Master for this section.
  bool get canTakeAttendanceForSelectedClass {
    final auth = Get.find<AuthController>();
    final user = auth.currentUser.value;
    if (user == null) return false;
    if (user.isAdmin) return true; // Head Teacher has administrative oversight over all primary classes
    final classId = selectedClass.value?.id;
    if (classId == null) return false;
    // Section-level teacher assignment has highest specificity
    final sectionTeacherId = selectedSection.value?.teacherId;
    if (sectionTeacherId != null && sectionTeacherId.isNotEmpty) {
      return sectionTeacherId == user.id;
    }
    final assignedFmId = classFormMasterIdMap[classId];
    return assignedFmId == user.id;
  }

  bool isCurrentUserFormMasterFor(String classId) {
    final auth = Get.find<AuthController>();
    final user = auth.currentUser.value;
    if (user == null) return false;
    if (user.isAdmin) return true;
    final assignedFmId = classFormMasterIdMap[classId];
    return assignedFmId == user.id;
  }

  /// The class assigned to the logged-in PST teacher (if any)
  ClassesData? get teacherAssignedClass {
    final auth = Get.find<AuthController>();
    final user = auth.currentUser.value;
    if (user == null) return null;
    return classesList.firstWhereOrNull((c) => classFormMasterIdMap[c.id] == user.id);
  }

  /// Switch the active class by ClassesData instance
  Future<void> selectClass(ClassesData cls) async {
    await switchClassById(cls.id);
  }

  // Search filter
  final RxString searchQuery = ''.obs;

  // Loading and subscription
  final RxBool isLoading = false.obs;
  StreamSubscription? _attendanceSub;

  // Snapshot for Undo functionality
  List<AttendanceRecord> _undoSnapshot = [];

  String get dateString => DateFormat('yyyy-MM-dd').format(selectedDate.value);
  String get formattedDate => DateFormat('EEEE, dd MMMM yyyy').format(selectedDate.value);
  String get shortFormattedDate => DateFormat('EEE, dd MMM').format(selectedDate.value);

  // Aggregate stats
  int get totalEnrolled => studentsList.length;
  int get presentCount => attendanceMap.values.where((r) => r.status == 'present').length;
  int get absentCount => attendanceMap.values.where((r) => r.status == 'absent').length;
  int get lateCount => attendanceMap.values.where((r) => r.status == 'late').length;
  int get leaveCount => attendanceMap.values.where((r) => r.status == 'approved_leave').length;
  int get halfDayCount => attendanceMap.values.where((r) => r.status == 'half_day').length;
  int get markedCount => attendanceMap.length;
  int get unmarkedCount => (totalEnrolled - attendanceMap.length).clamp(0, totalEnrolled);

  // KPK Two-Time Attendance getters
  KpkDayMark getDayMark(String studentId) => KpkDayMark.fromRecord(attendanceMap[studentId]);
  int get firstTimePresentCount =>
      studentsList.where((s) => getDayMark(s.id).firstTime == 'P').length;
  int get secondTimePresentCount =>
      studentsList.where((s) => getDayMark(s.id).secondTime == 'P').length;
  int get firstTimeMarkedCount =>
      studentsList.where((s) => getDayMark(s.id).isFirstTimeMarked).length;
  int get secondTimeMarkedCount =>
      studentsList.where((s) => getDayMark(s.id).isSecondTimeMarked).length;
  int get todaySessionAttendanceUnits =>
      studentsList.fold(0, (sum, s) => sum + getDayMark(s.id).attendanceUnits);

  bool get isIncompleteSession => unmarkedCount > 0;
  bool get isSessionFinalized => currentSession.value?.isFinalized ?? false;
  bool get isSunday => selectedDate.value.weekday == DateTime.sunday;
  bool get isNonInstructionalDay => isSunday || activeHoliday.value != null;

  List<Student> get filteredStudents {
    if (searchQuery.value.trim().isEmpty) return studentsList;
    final term = searchQuery.value.toLowerCase().trim();
    return studentsList.where((s) {
      return s.fullName.toLowerCase().contains(term) ||
          s.admissionNumber.toLowerCase().contains(term) ||
          (s.rollNumber ?? '').toLowerCase().contains(term) ||
          s.fatherOrGuardianName.toLowerCase().contains(term);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadClasses();
  }

  void resetState() {
    _attendanceSub?.cancel();
    _attendanceSub = null;
    classesList.clear();
    sectionsList.clear();
    studentsList.clear();
    attendanceMap.clear();
    selectedClass.value = null;
    selectedSection.value = null;
    currentSession.value = null;
    activeHoliday.value = null;
    currentMonthKpkSummary.value = null;
    schoolTotalActiveStudents.value = 0;
    schoolTotalTeachers.value = 0;
    pendingCorrectionsCount.value = 0;
    classEnrollmentMap.clear();
    classAttendedMap.clear();
    classFormMasterNameMap.clear();
    classFormMasterIdMap.clear();
    searchQuery.value = '';
  }

  Future<void> onSchoolChanged() async {
    resetState();
    await loadClasses();
  }

  @override
  void onClose() {
    _attendanceSub?.cancel();
    super.onClose();
  }

  Future<void> loadClasses() async {
    final auth = Get.find<AuthController>();
    final user = auth.currentUser.value;
    final schoolId = user?.schoolId;
    if (schoolId == null || schoolId.isEmpty) {
      resetState();
      return;
    }

    isLoading.value = true;
    try {
      final classes = await studentRepository.getClasses(schoolId);
      classesList.assignAll(classes);
      await refreshSchoolWideKpis();

      if (classesList.isNotEmpty) {
        // If logged-in user is a PST teacher, select their assigned Form Master class by default
        ClassesData? defaultClass;
        if (user != null && !user.isAdmin) {
          defaultClass = classesList.firstWhereOrNull(
            (c) => classFormMasterIdMap[c.id] == user.id,
          );
        }
        defaultClass ??= classesList.firstWhereOrNull((c) => c.numericLevel == 1) ?? classesList.first;
        selectedClass.value = defaultClass;
        await loadSections(defaultClass.id);
      } else {
        selectedClass.value = null;
        selectedSection.value = null;
        sectionsList.clear();
        studentsList.clear();
        attendanceMap.clear();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> switchClassById(String classId) async {
    final target = classesList.firstWhereOrNull((c) => c.id == classId);
    if (target != null && selectedClass.value?.id != target.id) {
      selectedClass.value = target;
      await loadSections(target.id);
    }
  }

  Future<void> refreshSchoolWideKpis() async {
    final auth = Get.find<AuthController>();
    final schoolId = auth.currentUser.value?.schoolId;
    if (schoolId == null || schoolId.isEmpty) return;

    final allStudents = await studentRepository.getAllStudentsForSchool(schoolId, activeOnly: true);
    final teachers = await studentRepository.getTeachers(schoolId);
    final pendingCor = await attendanceRepository.getCorrectionRequests(schoolId: schoolId, status: 'pending');

    schoolTotalActiveStudents.value = allStudents.length;
    schoolTotalTeachers.value = teachers.length;
    pendingCorrectionsCount.value = pendingCor.length;

    final teacherById = <String, String>{
      for (final t in teachers) t.id: t.name,
    };

    // Compute per-class enrollment, today's attended count, and Form Master assignment
    final enrolledByClass = <String, int>{};
    final attendedByClass = <String, int>{};
    final fmNameByClass = <String, String>{};
    final fmIdByClass = <String, String?>{};

    for (final c in classesList) {
      enrolledByClass[c.id] = 0;
      attendedByClass[c.id] = 0;
    }
    for (final s in allStudents) {
      enrolledByClass[s.classId] = (enrolledByClass[s.classId] ?? 0) + 1;
    }

    for (final c in classesList) {
      final secs = await studentRepository.getSections(c.id, schoolId: schoolId);
      int attended = 0;
      String? assignedTeacherId;
      for (final sec in secs) {
        assignedTeacherId ??= sec.teacherId;
        final recs = await attendanceRepository.getAttendance(
          classId: c.id,
          sectionId: sec.id,
          date: dateString,
          schoolId: schoolId,
        );
        attended += recs
            .where((r) => r.status == 'present' || r.status == 'late' || r.status == 'half_day')
            .length;
      }
      attendedByClass[c.id] = attended;
      fmIdByClass[c.id] = assignedTeacherId;
      fmNameByClass[c.id] = assignedTeacherId != null
          ? (teacherById[assignedTeacherId] ?? 'Assigned Teacher')
          : 'Unassigned';
    }

    classEnrollmentMap.assignAll(enrolledByClass);
    classAttendedMap.assignAll(attendedByClass);
    classFormMasterNameMap.assignAll(fmNameByClass);
    classFormMasterIdMap.assignAll(fmIdByClass);
  }

  Future<void> loadSections(String classId) async {
    final auth = Get.find<AuthController>();
    final schoolId = auth.currentUser.value?.schoolId;
    final sections = await studentRepository.getSections(classId, schoolId: schoolId);
    sectionsList.assignAll(sections);
    if (sectionsList.isNotEmpty) {
      selectedSection.value = sectionsList.first;
      await loadStudentsAndAttendance();
    } else {
      selectedSection.value = null;
      studentsList.clear();
      attendanceMap.clear();
    }
  }

  Future<void> selectDate(DateTime newDate) async {
    selectedDate.value = newDate;
    await loadStudentsAndAttendance();
  }

  Future<void> loadStudentsAndAttendance() async {
    if (selectedClass.value == null || selectedSection.value == null) return;
    final auth = Get.find<AuthController>();
    final schoolId = auth.currentUser.value?.schoolId;
    if (schoolId == null || schoolId.isEmpty) return;

    isLoading.value = true;
    try {
      final students = await studentRepository.getStudentsForSection(
        classId: selectedClass.value!.id,
        sectionId: selectedSection.value!.id,
        schoolId: schoolId,
      );
      studentsList.assignAll(students);

      // Load session status
      currentSession.value = await attendanceRepository.getSession(
        sectionId: selectedSection.value!.id,
        date: dateString,
        schoolId: schoolId,
      );

      // Check if selected date is a holiday
      final holidays = await studentRepository.getHolidays(
        schoolId: schoolId,
        startDate: dateString,
        endDate: dateString,
      );
      activeHoliday.value = holidays.isNotEmpty ? holidays.first : null;

      // Listen to attendance updates reactively
      _attendanceSub?.cancel();
      _attendanceSub = attendanceRepository
          .watchAttendance(
            classId: selectedClass.value!.id,
            sectionId: selectedSection.value!.id,
            date: dateString,
            schoolId: schoolId,
          )
          .listen((records) {
        attendanceMap.clear();
        for (final r in records) {
          attendanceMap[r.studentId] = r;
        }
        if (selectedClass.value != null) {
          classAttendedMap[selectedClass.value!.id] =
              presentCount + lateCount + halfDayCount;
        }
        refreshCurrentMonthKpkSummary();
      });

      await refreshSchoolWideKpis();
      await refreshCurrentMonthKpkSummary();
    } finally {
      isLoading.value = false;
    }
  }

  /// Computes the official KPK Monthly Register Summary (`اوسط حاضری ماہ حال` & `فیصد حاضری ماہ حال`)
  /// for the currently selected class, section, and calendar month.
  Future<void> refreshCurrentMonthKpkSummary() async {
    if (selectedClass.value == null || selectedSection.value == null) return;
    final auth = Get.find<AuthController>();
    final schoolId = auth.currentUser.value?.schoolId;
    if (schoolId == null || schoolId.isEmpty) return;
    final selDate = selectedDate.value;
    final monthStart = DateTime(selDate.year, selDate.month, 1);
    final now = DateTime.now();
    // Up to today if viewing current month, or full month if viewing a past month
    final monthEnd = (selDate.year == now.year && selDate.month == now.month)
        ? DateTime(now.year, now.month, now.day)
        : DateTime(selDate.year, selDate.month + 1, 0);

    final startStr = DateFormat('yyyy-MM-dd').format(monthStart);
    final endStr = DateFormat('yyyy-MM-dd').format(monthEnd);

    final allSectionStudents = await studentRepository.getStudentsForSection(
      classId: selectedClass.value!.id,
      sectionId: selectedSection.value!.id,
      schoolId: schoolId,
      includeInactive: true,
    );
    final monthRecords = await attendanceRepository.getAttendanceForDateRange(
      schoolId: schoolId,
      classId: selectedClass.value!.id,
      sectionId: selectedSection.value!.id,
      startDate: startStr,
      endDate: endStr,
    );
    final allHolidays = await studentRepository.getAllHolidaysForSchool(schoolId);
    final holidayKeys = allHolidays.map((h) => h.date).toSet();

    currentMonthKpkSummary.value = KpkMonthlySummary.compute(
      students: studentsList,
      allSectionStudents: allSectionStudents,
      records: monthRecords,
      holidayDateKeys: holidayKeys,
      startDate: monthStart,
      endDate: monthEnd,
    );
  }

  /// Marks 1st Time (`slot == 1`, Morning `/`) or 2nd Time (`slot == 2`, After Break `//`)
  /// for a student using KPK Register notation (`'P'` = `/`, `'A'` = `A`, `'L'` = `L`).
  Future<void> markTimeSlot({
    required Student student,
    required String slotMark,
    int? slot,
  }) async {
    if (isSessionFinalized) {
      Get.snackbar(
        'Register Locked',
        'register_locked_msg'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1E293B),
        colorText: Colors.white,
      );
      return;
    }
    HapticFeedback.selectionClick();
    final activeSlot = slot ?? selectedTimeSlot.value;
    final existingRecord = attendanceMap[student.id];
    final currentMark = KpkDayMark.fromRecord(existingRecord);

    KpkDayMark nextMark;
    if (activeSlot == 1) {
      // In 1st Time (Morning): update firstTime; keep secondTime only if it already matches slotMark, else '_'
      final nextS2 = (currentMark.secondTime == slotMark) ? slotMark : '_';
      nextMark = KpkDayMark(
        firstTime: slotMark,
        secondTime: nextS2,
        isLate: slotMark == 'P' ? currentMark.isLate : false,
        customDepartureTime: currentMark.customDepartureTime,
      );
    } else {
      // In 2nd Time (After Break): preserve 1st Time and update secondTime
      final s1 = currentMark.firstTime == '_' ? slotMark : currentMark.firstTime;
      final keepLate = (s1 == 'P' || slotMark == 'P') ? currentMark.isLate : false;
      nextMark = KpkDayMark(
        firstTime: s1,
        secondTime: slotMark,
        isLate: keepLate,
        customDepartureTime: currentMark.customDepartureTime,
      );
    }

    final dbStatus = nextMark.toDbStatus();
    await markStatus(
      student: student,
      status: dbStatus,
      arrivalTime: nextMark.isLate ? existingRecord?.arrivalTime : null,
      departureTime: nextMark.encodeDepartureTime(),
      remarks: existingRecord?.remarks,
    );
  }

  /// Toggles the Late (`تاخیر`) indicator on a student.
  /// In KPK schools, a late student is Present (`/` in 1st time, `//` in full day)
  /// in the official register count and additionally flagged as Late with arrival time.
  Future<void> toggleLate(Student student) async {
    if (isSessionFinalized) {
      Get.snackbar(
        'Register Locked',
        'register_locked_msg'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1E293B),
        colorText: Colors.white,
      );
      return;
    }
    HapticFeedback.selectionClick();
    final activeSlot = selectedTimeSlot.value;
    final existingRecord = attendanceMap[student.id];
    final currentMark = KpkDayMark.fromRecord(existingRecord);

    final nextLate = !currentMark.isLate;
    final nextMark = activeSlot == 1
        ? KpkDayMark(
            firstTime: 'P',
            secondTime: currentMark.secondTime == 'P' ? 'P' : '_',
            isLate: nextLate,
            customDepartureTime: currentMark.customDepartureTime,
          )
        : KpkDayMark(
            firstTime: currentMark.firstTime == '_' ? 'P' : currentMark.firstTime,
            secondTime: 'P',
            isLate: nextLate,
            customDepartureTime: currentMark.customDepartureTime,
          );

    final dbStatus = nextMark.toDbStatus();
    final nowTime = DateFormat('HH:mm:ss').format(DateTime.now());
    await markStatus(
      student: student,
      status: dbStatus,
      arrivalTime: nextLate ? (existingRecord?.arrivalTime ?? nowTime) : null,
      departureTime: nextMark.encodeDepartureTime(),
      remarks: existingRecord?.remarks,
    );
  }

  /// One-tap register marking with light haptic feedback.
  Future<void> quickMark({
    required Student student,
    required String status,
  }) async {
    HapticFeedback.selectionClick();
    await markStatus(student: student, status: status);
  }

  // Mark single student status
  Future<void> markStatus({
    required Student student,
    required String status,
    String? arrivalTime,
    String? departureTime,
    String? remarks,
    String? correctionReason,
  }) async {
    final auth = Get.find<AuthController>();
    final user = auth.currentUser.value;
    final userId = user?.id ?? 'usr_teacher_001';
    final schoolId = user?.schoolId ?? 'sch_demo_gps_001';

    // Enforce Sunday & Gazetted Holiday non-instructional day rule
    if (isNonInstructionalDay) {
      final reason = isSunday
          ? 'Sunday is a weekly off-day (اتوار تعطیل).'
          : 'Holiday: ${activeHoliday.value?.description ?? "Gazetted Holiday"}.';
      Get.snackbar(
        'Non-Instructional Day (تعطیل)',
        '$reason Attendance cannot be recorded on non-instructional days.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF6B21A8),
        colorText: Colors.white,
      );
      return;
    }

    // Enforce Form Master jurisdiction: only assigned Form Master or Head Teacher can record attendance
    if (!canTakeAttendanceForSelectedClass) {
      Get.snackbar(
        'Permission Restricted',
        'Only the assigned Form Master ($currentClassFormMaster) or Head Teacher can record attendance for ${selectedClass.value?.name ?? "this class"}.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.amber.shade900,
        colorText: Colors.white,
      );
      return;
    }

    // If session is finalized, changing status is blocked unless reopened
    if (isSessionFinalized) {
      Get.snackbar(
        'Register Locked',
        'register_locked_msg'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1E293B),
        colorText: Colors.white,
      );
      return;
    }

    final time = arrivalTime ?? (status == 'late' ? DateFormat('HH:mm:ss').format(DateTime.now()) : null);

    // Ensure departureTime encodes the two-time KPK mark if not already encoded
    String? effectiveDeparture = departureTime;
    if (effectiveDeparture == null || !effectiveDeparture.startsWith('S1:')) {
      final defaultMark = switch (status) {
        'present' || 'late' => KpkDayMark(
            firstTime: 'P',
            secondTime: 'P',
            isLate: status == 'late',
            customDepartureTime: effectiveDeparture,
          ),
        'approved_leave' => KpkDayMark(
            firstTime: 'L',
            secondTime: 'L',
            isLate: false,
            customDepartureTime: effectiveDeparture,
          ),
        _ => KpkDayMark(
            firstTime: 'A',
            secondTime: 'A',
            isLate: false,
            customDepartureTime: effectiveDeparture,
          ),
      };
      effectiveDeparture = defaultMark.encodeDepartureTime();
    }

    await attendanceRepository.markAttendance(
      schoolId: schoolId,
      studentId: student.id,
      classId: selectedClass.value!.id,
      sectionId: selectedSection.value!.id,
      date: dateString,
      status: status,
      arrivalTime: time,
      departureTime: effectiveDeparture,
      remarks: remarks,
      markedByUserId: userId,
      markingMethod: 'manual',
      editReason: correctionReason ?? (isSessionFinalized ? 'Head Teacher override on finalized session' : null),
    );
  }

  // Finalize daily attendance session
  Future<bool> finalizeCurrentSession({String? notes}) async {
    if (selectedClass.value == null || selectedSection.value == null) return false;
    if (isNonInstructionalDay) {
      Get.snackbar(
        'Non-Instructional Day',
        'Sunday and Gazetted Holidays do not require register locking.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    if (!canTakeAttendanceForSelectedClass) {
      Get.snackbar(
        'Permission Restricted',
        'Only the assigned Form Master ($currentClassFormMaster) or Head Teacher can lock this register.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.amber.shade900,
        colorText: Colors.white,
      );
      return false;
    }
    if (unmarkedCount > 0) {
      Get.snackbar(
        'Cannot Finalize Incomplete Register',
        '$unmarkedCount student(s) are still unmarked. Please mark all students before finalizing.',
        backgroundColor: const Color(0xFFFEF3C7),
        colorText: const Color(0xFF92400E),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final auth = Get.find<AuthController>();
    final userId = auth.currentUser.value?.id ?? 'usr_teacher_001';
    final schoolId = auth.currentUser.value?.schoolId ?? 'sch_demo_gps_001';

    // Auto-complete any pending 2nd Time ('_') with 1st Time mark when locking register
    for (final s in studentsList) {
      final rec = attendanceMap[s.id];
      if (rec != null) {
        final mark = KpkDayMark.fromRecord(rec);
        if (mark.firstTime != '_' && mark.secondTime == '_') {
          final completed = mark.copyWith(secondTime: mark.firstTime);
          await attendanceRepository.markAttendance(
            schoolId: schoolId,
            studentId: s.id,
            classId: selectedClass.value!.id,
            sectionId: selectedSection.value!.id,
            date: dateString,
            status: completed.toDbStatus(),
            arrivalTime: rec.arrivalTime,
            departureTime: completed.encodeDepartureTime(),
            remarks: rec.remarks,
            markedByUserId: userId,
            markingMethod: rec.markingMethod,
          );
        }
      }
    }

    final session = await attendanceRepository.updateSessionStatus(
      schoolId: schoolId,
      classId: selectedClass.value!.id,
      sectionId: selectedSection.value!.id,
      date: dateString,
      status: 'finalized',
      userId: userId,
      notes: notes,
    );
    currentSession.value = session;

    Get.snackbar(
      'Attendance Register Finalized',
      'Register for ${selectedClass.value!.name} (${selectedSection.value!.name}) locked for $formattedDate.',
      snackPosition: SnackPosition.BOTTOM,
    );
    return true;
  }

  // Finalize daily attendance register session and immediately sync all records to Cloudflare D1
  Future<bool> finalizeAndSyncCurrentSession({String? notes}) async {
    final ok = await finalizeCurrentSession(notes: notes);
    if (!ok) return false;

    // Send push notification to School staff and Head Teacher
    try {
      final className = selectedClass.value?.name ?? 'Class';
      final secName = selectedSection.value?.name ?? '';
      NotificationService.instance.sendSchoolAlert(
        type: 'attendance_finalized',
        title: '📋 Attendance Register Locked',
        bodyText: '$className ($secName) attendance register was locked and synced for $formattedDate.',
        data: {
          'classId': selectedClass.value?.id ?? '',
          'date': dateString,
        },
      );
    } catch (_) {}

    if (Get.isRegistered<SyncController>()) {
      final syncCtrl = Get.find<SyncController>();
      await syncCtrl.syncNow(silent: false, pushOnly: true);
    }
    return true;
  }

  // Reopen finalized session (Only Head Teacher / Administrator)
  Future<void> reopenCurrentSession({String? reason}) async {
    if (selectedClass.value == null || selectedSection.value == null) return;
    final auth = Get.find<AuthController>();
    final isAdmin = auth.currentUser.value?.isAdmin ?? false;
    if (!isAdmin) {
      Get.snackbar(
        'Permission Restricted',
        'Only the Head Teacher / Administrator can unlock and reopen a finalized register.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.amber.shade900,
        colorText: Colors.white,
      );
      return;
    }

    final userId = auth.currentUser.value?.id ?? 'usr_teacher_001';
    final schoolId = auth.currentUser.value?.schoolId ?? 'sch_demo_gps_001';

    final session = await attendanceRepository.updateSessionStatus(
      schoolId: schoolId,
      classId: selectedClass.value!.id,
      sectionId: selectedSection.value!.id,
      date: dateString,
      status: 'draft',
      userId: userId,
      notes: (reason != null && reason.trim().isNotEmpty)
          ? reason.trim()
          : 'Reopened for attendance editing',
    );
    currentSession.value = session;

    Get.snackbar(
      'Register Reopened',
      'Register reopened for editing. Tap "Lock Register" when finished to save and lock.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1E293B),
      colorText: Colors.white,
    );
  }

  // Mark All Present for active KPK Time Slot (1st Time or 2nd Time) with confirmation and undo
  Future<void> markAllPresent({int? slot}) async {
    if (studentsList.isEmpty) return;
    if (isNonInstructionalDay) {
      Get.snackbar(
        'Non-Instructional Day',
        'Attendance cannot be marked on Sunday or a Gazetted Holiday.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF6B21A8),
        colorText: Colors.white,
      );
      return;
    }
    if (!canTakeAttendanceForSelectedClass) {
      Get.snackbar(
        'Permission Restricted',
        'Only the assigned Form Master ($currentClassFormMaster) or Head Teacher can record attendance for this class.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.amber.shade900,
        colorText: Colors.white,
      );
      return;
    }
    if (isSessionFinalized) {
      Get.snackbar(
        'Register Locked',
        'register_locked_msg'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1E293B),
        colorText: Colors.white,
      );
      return;
    }

    final activeSlot = slot ?? selectedTimeSlot.value;
    final auth = Get.find<AuthController>();
    final userId = auth.currentUser.value?.id ?? 'usr_teacher_001';
    final schoolId = auth.currentUser.value?.schoolId ?? 'sch_demo_gps_001';

    _undoSnapshot = attendanceMap.values.toList();
    final studentIds = studentsList.map((s) => s.id).toList();

    final overrides = <String, ({String status, String? arrivalTime, String? departureTime, String? remarks})>{};
    for (final s in studentsList) {
      final existing = attendanceMap[s.id];
      final currentMark = KpkDayMark.fromRecord(existing);
      KpkDayMark nextMark;
      if (activeSlot == 1) {
        final nextS2 = currentMark.secondTime == 'P' ? 'P' : '_';
        nextMark = KpkDayMark(
          firstTime: 'P',
          secondTime: nextS2,
          isLate: currentMark.isLate,
          customDepartureTime: currentMark.customDepartureTime,
        );
      } else {
        final s1 = currentMark.firstTime == '_' ? 'P' : currentMark.firstTime;
        final s2 = (s1 == 'A' || s1 == 'L') ? s1 : 'P';
        nextMark = KpkDayMark(
          firstTime: s1,
          secondTime: s2,
          isLate: currentMark.isLate,
          customDepartureTime: currentMark.customDepartureTime,
        );
      }
      overrides[s.id] = (
        status: nextMark.toDbStatus(),
        arrivalTime: nextMark.isLate ? existing?.arrivalTime : null,
        departureTime: nextMark.encodeDepartureTime(),
        remarks: existing?.remarks ?? (activeSlot == 1 ? 'Marked 1st Time' : 'Marked 2nd Time'),
      );
    }

    await attendanceRepository.markAllPresent(
      schoolId: schoolId,
      classId: selectedClass.value!.id,
      sectionId: selectedSection.value!.id,
      date: dateString,
      markedByUserId: userId,
      studentIds: studentIds,
      studentOverrides: overrides,
    );

    final slotTitle = activeSlot == 1 ? '1st Time (Morning)' : '2nd Time (After Break)';
    Get.snackbar(
      'Marked $slotTitle',
      'Updated $slotTitle attendance for ${studentsList.length} students ($formattedDate).',
      mainButton: TextButton(
        onPressed: undoMarkAllPresent,
        child: const Text('UNDO', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
      ),
      duration: const Duration(seconds: 5),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Undo Mark All Present
  Future<void> undoMarkAllPresent() async {
    final studentIds = studentsList.map((s) => s.id).toList();

    await attendanceRepository.restoreAttendanceSnapshot(
      previousRecords: _undoSnapshot,
      studentIds: studentIds,
      date: dateString,
    );

    Get.snackbar(
      'Undo Successful',
      'Restored previous attendance state.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
