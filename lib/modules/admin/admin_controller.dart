import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart' show Color;
import 'package:get/get.dart';
import '../../core/database/app_database.dart';
import '../../core/utils/kpk_register_helper.dart';
import '../../data/repositories/attendance_repository.dart';
import '../../data/repositories/student_repository.dart';
import '../attendance/attendance_controller.dart';
import '../auth/auth_controller.dart';
import '../pdf_reports/pdf_reports_controller.dart';
import '../../core/services/notification_service.dart';

class AdminController extends GetxController {
  final StudentRepository studentRepository;
  final AttendanceRepository attendanceRepository;

  AdminController({
    required this.studentRepository,
    required this.attendanceRepository,
  });

  final Rx<School?> school = Rx<School?>(null);
  final Rx<SchoolSettingsModel?> settings = Rx<SchoolSettingsModel?>(null);
  final RxList<SchoolCalendarHoliday> holidays = <SchoolCalendarHoliday>[].obs;
  final RxList<User> teachers = <User>[].obs;
  final RxList<CorrectionRequestModel> correctionRequests = <CorrectionRequestModel>[].obs;
  final RxList<AttendanceAuditLog> auditLogs = <AttendanceAuditLog>[].obs;
  final RxBool isLoading = false.obs;

  String get currentSchoolId =>
      Get.find<AuthController>().currentUser.value?.schoolId ?? '';

  void resetState() {
    school.value = null;
    settings.value = null;
    holidays.clear();
    teachers.clear();
    correctionRequests.clear();
    auditLogs.clear();
  }

  @override
  void onInit() {
    super.onInit();
    loadAllAdminData();
  }

  Future<void> loadAllAdminData() async {
    final sid = currentSchoolId;
    if (sid.isEmpty) {
      resetState();
      return;
    }
    isLoading.value = true;
    try {
      await studentRepository.ensureOfficialKpkHolidays(sid);
      school.value = await studentRepository.getSchool(sid);
      settings.value = await studentRepository.getSchoolSettings(sid);
      holidays.assignAll(await studentRepository.getAllHolidaysForSchool(sid));
      teachers.assignAll(await studentRepository.getTeachers(sid));
      correctionRequests.assignAll(await attendanceRepository.getCorrectionRequests(schoolId: sid));
      auditLogs.assignAll(await attendanceRepository.getRecentAuditLogs(limit: 100));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _refreshDependentControllers() async {
    if (Get.isRegistered<AttendanceController>()) {
      await Get.find<AttendanceController>().loadStudentsAndAttendance();
    }
    if (Get.isRegistered<PdfReportsController>()) {
      await Get.find<PdfReportsController>().refreshReportPeriodSummary();
    }
  }

  Future<void> saveSchoolSetup({
    required String name,
    required String code,
    required String address,
    required String phone,
    required String schoolType,
    required String district,
    required String tehsil,
    required String circleOffice,
    required String climateZone,
    required String openingTime,
    required String closingTime,
    required String lateCutoffTime,
    required String headTeacherName,
  }) async {
    final sid = currentSchoolId;
    final curSchool = school.value;
    final newSettings = SchoolSettingsModel(
      schoolId: sid,
      schoolType: schoolType,
      district: district,
      tehsil: tehsil,
      circleOffice: circleOffice,
      climateZone: climateZone,
      openingTime: openingTime,
      closingTime: closingTime,
      lateCutoffTime: lateCutoffTime,
      headTeacherName: headTeacherName,
    );

    await studentRepository.updateSchoolAndSettings(
      schoolId: sid,
      name: name,
      code: code,
      address: address,
      phone: phone,
      academicYearStart: curSchool?.academicYearStart ?? '2026-04-01',
      academicYearEnd: curSchool?.academicYearEnd ?? '2027-03-31',
      settings: newSettings,
    );

    await loadAllAdminData();
    await _refreshDependentControllers();
    Get.snackbar('KPK School Profile Saved', 'Updated school configuration and attendance cutoff rules.');
  }

  Future<void> addHoliday(String date, String description) async {
    await studentRepository.addHoliday(
      schoolId: currentSchoolId,
      date: date,
      description: description,
    );
    await loadAllAdminData();
    await _refreshDependentControllers();
    Get.snackbar('Holiday Added', 'Added "$description" ($date) to non-instructional calendar.');
  }

  Future<void> addHolidayRange({
    required DateTime start,
    required DateTime end,
    required String description,
  }) async {
    final entries = KpkGazettedHolidays.expandDateRange(
      start: start,
      end: end,
      description: description,
    );
    final count = await studentRepository.addHolidaysBatch(
      schoolId: currentSchoolId,
      entries: entries,
    );
    await loadAllAdminData();
    await _refreshDependentControllers();
    Get.snackbar(
      'Vacation / Closure Range Added',
      'Added $count non-Sunday closure dates for "$description" to calendar.',
    );
  }

  Future<void> syncOfficialKpkGazettedHolidays() async {
    final count = await studentRepository.addHolidaysBatch(
      schoolId: currentSchoolId,
      entries: KpkGazettedHolidays.official2026Holidays,
    );
    await loadAllAdminData();
    await _refreshDependentControllers();
    Get.snackbar(
      'Official KP E&SED Holidays Synced',
      'Loaded $count official 2026 KPK & Federal Gazetted Holidays.',
    );
  }

  Future<void> removeHoliday(String id) async {
    await studentRepository.deleteHoliday(id);
    await loadAllAdminData();
    await _refreshDependentControllers();
  }

  Future<void> addClassSection({
    required String className,
    required int numericLevel,
    required String sectionName,
    String? teacherId,
  }) async {
    await studentRepository.createClassWithSection(
      schoolId: currentSchoolId,
      className: className,
      numericLevel: numericLevel,
      sectionName: sectionName,
      teacherId: teacherId,
    );
    await loadAllAdminData();
    if (Get.isRegistered<AttendanceController>()) {
      await Get.find<AttendanceController>().loadClasses();
    }
    Get.snackbar('Class Created', 'Added $className ($sectionName) to school structure.');
  }

  Future<void> assignClassFormMaster({
    required String classId,
    required String className,
    required String? teacherId,
    required String teacherName,
  }) async {
    await studentRepository.assignFormMaster(
      classId: classId,
      teacherId: teacherId,
    );
    await loadAllAdminData();
    if (Get.isRegistered<AttendanceController>()) {
      await Get.find<AttendanceController>().refreshSchoolWideKpis();
      final attCtrl = Get.find<AttendanceController>();
      if (attCtrl.selectedClass.value?.id == classId) {
        await attCtrl.loadSections(classId);
      }
    }
    Get.snackbar(
      'Form Master Assigned',
      '$teacherName is now Form Master for $className.',
    );
  }

  Future<void> addTeacher({
    required String name,
    required String email,
    required String phone,
    required String role,
    required String pinCode,
    String? password,
    String? avatarUrl,
    String? cnic,
    String? designation,
    String? assignedClassId,
  }) async {
    await studentRepository.createTeacher(
      schoolId: currentSchoolId,
      name: name,
      email: email,
      phone: phone,
      role: role,
      pinCode: pinCode,
      password: password,
      avatarUrl: avatarUrl,
      cnic: cnic,
      designation: designation,
      assignedClassId: assignedClassId,
    );
    await loadAllAdminData();
    if (Get.isRegistered<AttendanceController>()) {
      await Get.find<AttendanceController>().refreshSchoolWideKpis();
    }
    Get.snackbar('Staff Registered', 'Created credentials for $name with individual login.');
  }

  /// Bulk import classes & sections from CSV (Format: Class Name, Numeric Level, Section Name)
  Future<int> importClassesFromCsv(String csvContent) async {
    final sid = currentSchoolId;
    if (sid.isEmpty) return 0;

    final lines = csvContent
        .split(RegExp(r'\r?\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    int imported = 0;
    for (int i = 0; i < lines.length; i++) {
      final cols = lines[i].split(',').map((c) => c.trim()).toList();
      if (cols.isEmpty || cols[0].isEmpty) continue;

      final firstLower = cols[0].toLowerCase();
      if (i == 0 && (firstLower.contains('class') && firstLower.contains('name') || firstLower == 'classname')) {
        continue;
      }

      final className = cols[0];
      final level = cols.length > 1 ? (int.tryParse(cols[1]) ?? 0) : 0;
      final sectionName = (cols.length > 2 && cols[2].isNotEmpty) ? cols[2] : 'Section A';

      await studentRepository.createClassWithSection(
        schoolId: sid,
        className: className,
        numericLevel: level,
        sectionName: sectionName,
      );
      imported++;
    }

    await loadAllAdminData();
    if (Get.isRegistered<AttendanceController>()) {
      await Get.find<AttendanceController>().loadClasses();
    }
    Get.snackbar(
      'Classes CSV Import Complete',
      'Successfully imported $imported class/section entries.',
    );
    return imported;
  }

  /// Bulk import staff/teachers from CSV (Format: Full Name, Email, Phone, Role, Designation, CNIC, PIN)
  Future<int> importStaffFromCsv(String csvContent) async {
    final sid = currentSchoolId;
    if (sid.isEmpty) return 0;

    final lines = csvContent
        .split(RegExp(r'\r?\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    int imported = 0;
    for (int i = 0; i < lines.length; i++) {
      final cols = lines[i].split(',').map((c) => c.trim()).toList();
      if (cols.isEmpty || cols[0].isEmpty) continue;

      final firstLower = cols[0].toLowerCase();
      if (i == 0 && (firstLower.contains('name') || firstLower == 'staff')) {
        continue;
      }

      final name = cols[0];
      final email = cols.length > 1 ? cols[1] : '';
      final phone = cols.length > 2 ? cols[2] : '';
      final rawRole = cols.length > 3 ? cols[3].toLowerCase() : 'teacher';
      final role = (rawRole == 'admin' || rawRole == 'head_teacher') ? rawRole : 'teacher';
      final designation = (cols.length > 4 && cols[4].isNotEmpty) ? cols[4] : 'PST';
      final cnic = (cols.length > 5 && cols[5].isNotEmpty) ? cols[5] : null;
      final pinCode = (cols.length > 6 && cols[6].isNotEmpty) ? cols[6] : '1234';

      await studentRepository.createTeacher(
        schoolId: sid,
        name: name,
        email: email,
        phone: phone,
        role: role,
        pinCode: pinCode,
        cnic: cnic,
        designation: designation,
      );
      imported++;
    }

    await loadAllAdminData();
    if (Get.isRegistered<AttendanceController>()) {
      await Get.find<AttendanceController>().refreshSchoolWideKpis();
    }
    Get.snackbar(
      'Staff CSV Import Complete',
      'Successfully imported $imported staff accounts.',
    );
    return imported;
  }

  Future<void> updateTeacherProfile({
    required String teacherId,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? pinCode,
    String? avatarUrl,
    String? cnic,
    String? designation,
    bool? isActive,
    String? assignedClassId,
  }) async {
    await studentRepository.updateTeacher(
      teacherId: teacherId,
      schoolId: currentSchoolId,
      name: name,
      email: email,
      phone: phone,
      role: role,
      pinCode: pinCode,
      avatarUrl: avatarUrl,
      cnic: cnic,
      designation: designation,
      isActive: isActive,
      assignedClassId: assignedClassId,
    );
    await loadAllAdminData();
    if (Get.isRegistered<AttendanceController>()) {
      await Get.find<AttendanceController>().refreshSchoolWideKpis();
    }
    Get.snackbar('Teacher Profile Updated', 'Saved changes to teacher record and assignments.');
  }

  Future<void> updateTeacherAvatar({
    required String teacherId,
    required String avatarUrl,
  }) async {
    await studentRepository.updateTeacherAvatar(
      teacherId: teacherId,
      schoolId: currentSchoolId,
      avatarUrl: avatarUrl,
    );
    await loadAllAdminData();
    if (Get.isRegistered<AttendanceController>()) {
      await Get.find<AttendanceController>().refreshSchoolWideKpis();
    }
  }

  // Admin / Head Teacher In-App Password & PIN Reset for any Teacher (Works 100% Offline)
  Future<void> resetTeacherCredentials({
    required String teacherId,
    required String teacherName,
    required String newPassword,
    String? newPin,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (studentRepository.db.update(studentRepository.db.users)
          ..where((t) => t.id.equals(teacherId)))
        .write(
      UsersCompanion(
        pinCodeHash: (newPin != null && newPin.isNotEmpty) ? drift.Value(newPin) : const drift.Value.absent(),
        updatedAt: drift.Value(now),
      ),
    );

    await studentRepository.syncDao.enqueue(
      targetTable: 'users',
      recordId: teacherId,
      operation: 'UPDATE',
      payloadJson: jsonEncode({
        'id': teacherId,
        'school_id': currentSchoolId,
        'password_hash': newPassword,
        if (newPin != null && newPin.isNotEmpty) 'pin_code_hash': newPin,
        'updated_at': now,
      }),
      idempotencyKey: 'pwd_reset_${teacherId}_$now',
    );

    await loadAllAdminData();
    Get.snackbar(
      'Credentials Reset Successfully',
      'New credentials configured for $teacherName. Teacher can sign in immediately.',
      backgroundColor: const Color(0xFFDCFCE7),
      colorText: const Color(0xFF166534),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> decideCorrectionRequest(CorrectionRequestModel req, String decision) async {
    final userId = Get.find<AuthController>().currentUser.value?.id ?? 'usr_admin_001';
    await attendanceRepository.reviewCorrectionRequest(
      request: req,
      decision: decision,
      reviewedByUserId: userId,
      reviewRemarks: 'Reviewed by Head Teacher',
    );

    // Push cloud notification to requesting teacher
    try {
      final isApproved = decision.toLowerCase() == 'approved';
      NotificationService.instance.sendSchoolAlert(
        targetUserId: req.requestedByUserId,
        type: isApproved ? 'correction_approved' : 'correction_request',
        title: isApproved ? '✅ Attendance Correction Approved' : '❌ Correction Request Rejected',
        bodyText: 'Correction request for ${req.studentName} (${req.date}) was marked as $decision by Head Teacher.',
        data: {
          'requestId': req.id,
          'studentId': req.studentId,
          'decision': decision,
        },
      );
    } catch (_) {}

    await loadAllAdminData();
    if (Get.isRegistered<AttendanceController>()) {
      await Get.find<AttendanceController>().loadStudentsAndAttendance();
    }
    Get.snackbar(
      'Correction ${decision.toUpperCase()}',
      'Correction request for ${req.studentName} (${req.date}) marked as $decision.',
    );
  }
}
