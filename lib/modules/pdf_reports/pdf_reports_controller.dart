import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/kpk_register_helper.dart';
import '../../data/repositories/attendance_repository.dart';
import '../../data/repositories/student_repository.dart';
import '../attendance/attendance_controller.dart';
import '../auth/auth_controller.dart';
import 'pdf_generator_service.dart';

/// Payload container for offloading heavy PDF rendering to a background isolate via compute()
class PdfGenerationPayload {
  final ReportType type;
  final School school;
  final ClassesData schoolClass;
  final Section section;
  final List<Student> students;
  final List<Student>? allSectionStudents;
  final List<AttendanceRecord> attendanceRecords;
  final List<SchoolCalendarHoliday> holidays;
  final DateTime startDate;
  final DateTime endDate;
  final Student? specificStudent;
  final StudentExtendedInfoModel? studentExtendedInfo;
  final SchoolSettingsModel? schoolSettings;
  final String? teacherName;
  final String? headTeacherName;
  final List<ClassSummaryRow>? adminClassSummaries;
  final String? customSlcNumber;
  final String? customFileNumber;
  final String? customLeavingDate;
  final String? customLeavingReason;
  final String? customPromotedStatus;
  final String? customConduct;
  final String? customDob;
  final String? customNationality;
  final bool isDuplicateSlc;
  final List<Map<String, dynamic>>? goshwaraTeachers;
  final Uint8List? regularFontBytes;
  final Uint8List? boldFontBytes;
  final Uint8List? kpesedLogoBytes;
  final Uint8List? kpkGovtLogoBytes;

  const PdfGenerationPayload({
    required this.type,
    required this.school,
    required this.schoolClass,
    required this.section,
    required this.students,
    this.allSectionStudents,
    required this.attendanceRecords,
    required this.holidays,
    required this.startDate,
    required this.endDate,
    this.specificStudent,
    this.studentExtendedInfo,
    this.schoolSettings,
    this.teacherName,
    this.headTeacherName,
    this.adminClassSummaries,
    this.customSlcNumber,
    this.customFileNumber,
    this.customLeavingDate,
    this.customLeavingReason,
    this.customPromotedStatus,
    this.customConduct,
    this.customDob,
    this.customNationality,
    this.isDuplicateSlc = false,
    this.goshwaraTeachers,
    this.regularFontBytes,
    this.boldFontBytes,
    this.kpesedLogoBytes,
    this.kpkGovtLogoBytes,
  });
}

/// Top-level worker executed on background isolate via compute()
Future<Uint8List> _pdfGenerationWorker(PdfGenerationPayload payload) async {
  return PdfGeneratorService.generateReport(
    type: payload.type,
    school: payload.school,
    schoolClass: payload.schoolClass,
    section: payload.section,
    students: payload.students,
    allSectionStudents: payload.allSectionStudents,
    attendanceRecords: payload.attendanceRecords,
    holidays: payload.holidays,
    startDate: payload.startDate,
    endDate: payload.endDate,
    specificStudent: payload.specificStudent,
    studentExtendedInfo: payload.studentExtendedInfo,
    schoolSettings: payload.schoolSettings,
    teacherName: payload.teacherName,
    headTeacherName: payload.headTeacherName,
    adminClassSummaries: payload.adminClassSummaries,
    customSlcNumber: payload.customSlcNumber,
    customFileNumber: payload.customFileNumber,
    customLeavingDate: payload.customLeavingDate,
    customLeavingReason: payload.customLeavingReason,
    customPromotedStatus: payload.customPromotedStatus,
    customConduct: payload.customConduct,
    customDob: payload.customDob,
    customNationality: payload.customNationality,
    isDuplicateSlc: payload.isDuplicateSlc,
    goshwaraTeachers: payload.goshwaraTeachers,
    regularFontBytes: payload.regularFontBytes,
    boldFontBytes: payload.boldFontBytes,
    kpesedLogoBytes: payload.kpesedLogoBytes,
    kpkGovtLogoBytes: payload.kpkGovtLogoBytes,
  );
}

class PdfReportsController extends GetxController {
  final AttendanceRepository attendanceRepository;
  final StudentRepository studentRepository;

  PdfReportsController({
    required this.attendanceRepository,
    required this.studentRepository,
  });

  final Rx<ReportType> selectedReportType = ReportType.monthlyMatrix.obs;
  final Rx<DateTime> startDate = DateTime(DateTime.now().year, DateTime.now().month, 1).obs;
  final Rx<DateTime> endDate = DateTime.now().obs;
  final Rx<Student?> selectedStudent = Rx<Student?>(null);
  final RxString selectedPreset = 'this_month'.obs;

  final RxBool isGenerating = false.obs;
  final Rx<KpkMonthlySummary?> reportPeriodSummary = Rx<KpkMonthlySummary?>(null);

  // School Leaving Certificate (SLC / Dakhil Kharij) custom parameters
  final RxString customFileNumber = ''.obs;
  final RxString customSlcNumber = ''.obs;
  final RxString customLeavingDate = ''.obs;
  final RxString customLeavingReason = ''.obs;
  final RxString customPromotedStatus = 'Studying / زیرِ تعلیم'.obs;
  final RxString customConduct = 'EXCELLENT / GOOD'.obs;
  final RxString customDob = ''.obs;
  final RxString customNationality = ''.obs;
  final RxBool isDuplicateSlc = false.obs;

  @override
  void onInit() {
    super.onInit();
    ever(startDate, (_) => refreshReportPeriodSummary());
    ever(endDate, (_) => refreshReportPeriodSummary());
    if (Get.isRegistered<AttendanceController>()) {
      final attCtrl = Get.find<AttendanceController>();
      ever(attCtrl.selectedClass, (_) => refreshReportPeriodSummary());
      ever(attCtrl.selectedSection, (_) => refreshReportPeriodSummary());
      ever(attCtrl.attendanceMap, (_) => refreshReportPeriodSummary());
    }
    refreshReportPeriodSummary();
  }

  Future<void> refreshReportPeriodSummary() async {
    if (!Get.isRegistered<AttendanceController>()) return;
    final attendanceCtrl = Get.find<AttendanceController>();
    final schoolClass = attendanceCtrl.selectedClass.value;
    final section = attendanceCtrl.selectedSection.value;
    if (schoolClass == null || section == null) return;

    final authCtrl = Get.find<AuthController>();
    final schoolId = authCtrl.currentUser.value?.schoolId;
    if (schoolId == null || schoolId.isEmpty) return;

    final startStr = DateFormat('yyyy-MM-dd').format(startDate.value);
    final endStr = DateFormat('yyyy-MM-dd').format(endDate.value);

    final students = await studentRepository.getStudentsForSection(
      classId: schoolClass.id,
      sectionId: section.id,
      schoolId: schoolId,
    );
    final allSectionStudents = await studentRepository.getStudentsForSection(
      classId: schoolClass.id,
      sectionId: section.id,
      schoolId: schoolId,
      includeInactive: true,
    );
    final records = await attendanceRepository.getAttendanceForDateRange(
      schoolId: schoolId,
      classId: schoolClass.id,
      sectionId: section.id,
      startDate: startStr,
      endDate: endStr,
    );
    final allHolidays = await studentRepository.getAllHolidaysForSchool(schoolId);
    final holidayKeys = allHolidays.map((h) => h.date).toSet();
    final school = await studentRepository.getSchool(schoolId);

    reportPeriodSummary.value = KpkMonthlySummary.compute(
      students: students,
      allSectionStudents: allSectionStudents,
      records: records,
      holidayDateKeys: holidayKeys,
      startDate: startDate.value,
      endDate: endDate.value,
      academicYearStart: school != null ? DateTime.tryParse(school.academicYearStart) : null,
    );
  }

  void selectMonth(int year, int month) {
    selectedPreset.value = 'pick_month';
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    startDate.value = DateTime(year, month, 1);
    if (year == now.year && month == now.month) {
      endDate.value = DateTime(now.year, now.month, now.day);
    } else {
      // Exact last calendar day of that month (28, 29 in leap years, 30, or 31)
      endDate.value = KpkMonthlySummary.lastDayOfMonth(year, month);
    }
    selectedReportType.value = ReportType.monthlyMatrix;
    refreshReportPeriodSummary();
  }

  void stepPreviousDay() {
    HapticFeedback.selectionClick();
    final start = startDate.value;
    final end = endDate.value;
    final isSameDay = start.year == end.year && start.month == end.month && start.day == end.day;
    if (isSameDay) {
      final prev = start.subtract(const Duration(days: 1));
      startDate.value = prev;
      endDate.value = prev;
      selectedPreset.value = 'custom';
    } else {
      startDate.value = start.subtract(const Duration(days: 1));
      endDate.value = end.subtract(const Duration(days: 1));
      selectedPreset.value = 'custom';
    }
    refreshReportPeriodSummary();
  }

  void stepNextDay() {
    HapticFeedback.selectionClick();
    final start = startDate.value;
    final end = endDate.value;
    final isSameDay = start.year == end.year && start.month == end.month && start.day == end.day;
    if (isSameDay) {
      final next = start.add(const Duration(days: 1));
      startDate.value = next;
      endDate.value = next;
      selectedPreset.value = 'custom';
    } else {
      startDate.value = start.add(const Duration(days: 1));
      endDate.value = end.add(const Duration(days: 1));
      selectedPreset.value = 'custom';
    }
    refreshReportPeriodSummary();
  }

  void setPreset(String preset) {
    selectedPreset.value = preset;
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    switch (preset) {
      case 'today':
        startDate.value = DateTime(now.year, now.month, now.day);
        endDate.value = DateTime(now.year, now.month, now.day);
        selectedReportType.value = ReportType.dailySheet;
        break;
      case 'this_month':
        startDate.value = DateTime(now.year, now.month, 1);
        endDate.value = DateTime(now.year, now.month, now.day);
        selectedReportType.value = ReportType.monthlyMatrix;
        break;
      case 'last_month':
        final prev = DateTime(now.year, now.month - 1, 1);
        startDate.value = prev;
        endDate.value = KpkMonthlySummary.lastDayOfMonth(prev.year, prev.month);
        selectedReportType.value = ReportType.monthlyMatrix;
        break;
      case 'full_period':
        startDate.value = DateTime(now.year, 4, 1); // Pakistani academic session start
        endDate.value = DateTime(now.year, now.month, now.day);
        selectedReportType.value = ReportType.classRegister;
        break;
      case 'custom':
        break;
    }
    refreshReportPeriodSummary();
  }

  String get periodFormattedRange {
    final start = startDate.value;
    final end = endDate.value;
    final isSameDay = start.year == end.year && start.month == end.month && start.day == end.day;
    if (isSameDay) {
      return DateFormat('d MMM yyyy').format(start);
    }
    if (start.year == end.year) {
      return '${DateFormat("d MMM").format(start)} – ${DateFormat("d MMM yyyy").format(end)}';
    }
    return '${DateFormat("d MMM yyyy").format(start)} – ${DateFormat("d MMM yyyy").format(end)}';
  }

  String get periodNameLabel {
    switch (selectedPreset.value) {
      case 'today':
        return 'Today';
      case 'this_month':
        return 'This Month';
      case 'last_month':
        return 'Last Month';
      case 'pick_month':
        return DateFormat('MMMM yyyy').format(startDate.value);
      case 'full_period':
        return 'Full Session';
      case 'custom':
        return 'Custom Range';
      default:
        return 'Report Period';
    }
  }

  Future<({Uint8List bytes, String filename})> buildPdfData() async {
    final attendanceCtrl = Get.find<AttendanceController>();
    final authCtrl = Get.find<AuthController>();

    final schoolId = authCtrl.currentUser.value?.schoolId;
    if (schoolId == null || schoolId.isEmpty) {
      throw Exception('No active authenticated school found.');
    }

    if (attendanceCtrl.classesList.isEmpty || attendanceCtrl.selectedClass.value == null) {
      await attendanceCtrl.loadClasses();
    }

    var schoolClass = attendanceCtrl.selectedClass.value;
    var section = attendanceCtrl.selectedSection.value;

    // For Monthly Goshwara (which is a school-wide summary across all classes),
    // provide an automatic fallback class and section if none is currently selected.
    if ((schoolClass == null || section == null) && selectedReportType.value == ReportType.monthlyGoshwara) {
      final allClasses = await studentRepository.getClasses(schoolId);
      if (allClasses.isNotEmpty) {
        schoolClass = allClasses.first;
        final allSecs = await studentRepository.getSections(schoolClass.id, schoolId: schoolId);
        section = allSecs.isNotEmpty
            ? allSecs.first
            : Section(
                id: 'sec_${schoolClass.id}_default',
                schoolId: schoolId,
                classId: schoolClass.id,
                name: 'Section A',
                createdAt: 0,
                updatedAt: 0,
                revision: 0,
              );
      }
    }

    if (schoolClass == null || section == null) {
      throw Exception('Please select a class and section first.');
    }

    final school = await (attendanceRepository.db.select(attendanceRepository.db.schools)
              ..where((t) => t.id.equals(schoolId)))
            .getSingleOrNull() ??
        School(
          id: schoolId,
          name: 'Govt Primary School Gulbahar No. 1 Peshawar',
          code: 'EMIS-12405',
          academicYearStart: '2026-04-01',
          academicYearEnd: '2027-03-31',
          createdAt: 0,
          updatedAt: 0,
          revision: 1,
        );

    final settings = await studentRepository.getSchoolSettings(schoolId);
    final students = await studentRepository.getStudentsForSection(
      classId: schoolClass.id,
      sectionId: section.id,
      schoolId: schoolId,
    );
    final allSectionStudents = await studentRepository.getStudentsForSection(
      classId: schoolClass.id,
      sectionId: section.id,
      schoolId: schoolId,
      includeInactive: true,
    );

    final startStr = DateFormat('yyyy-MM-dd').format(startDate.value);
    final endStr = DateFormat('yyyy-MM-dd').format(endDate.value);

    final records = await attendanceRepository.getAttendanceForDateRange(
      schoolId: schoolId,
      classId: schoolClass.id,
      sectionId: section.id,
      startDate: startStr,
      endDate: endStr,
    );

    final holidays = await studentRepository.getAllHolidaysForSchool(schoolId);
    final holidayKeys = holidays.map((h) => h.date).toSet();

    List<ClassSummaryRow>? adminSummaries;
    List<Map<String, dynamic>>? goshwaraTeachersList;

    if (selectedReportType.value == ReportType.administrativeSummary ||
        selectedReportType.value == ReportType.monthlyGoshwara) {
      adminSummaries = [];
      final allClasses = await studentRepository.getClasses(schoolId);
      final workDays = PdfGeneratorService.calculateEligibleInstructionalDays(
        startDate: startDate.value,
        endDate: endDate.value,
        holidayDateKeys: holidayKeys,
      );
      for (final cls in allClasses) {
        final secs = await studentRepository.getSections(cls.id, schoolId: schoolId);
        for (final sec in secs) {
          final secStudents = await studentRepository.getStudentsForSection(classId: cls.id, sectionId: sec.id, schoolId: schoolId);
          final secAllStudents = await studentRepository.getStudentsForSection(
            classId: cls.id,
            sectionId: sec.id,
            schoolId: schoolId,
            includeInactive: true,
          );
          final secAtt = await attendanceRepository.getAttendanceForDateRange(
            schoolId: schoolId,
            classId: cls.id,
            sectionId: sec.id,
            startDate: startStr,
            endDate: endStr,
          );
          final kpkSec = KpkMonthlySummary.compute(
            students: secStudents,
            allSectionStudents: secAllStudents,
            records: secAtt,
            holidayDateKeys: holidayKeys,
            startDate: startDate.value,
            endDate: endDate.value,
            academicYearStart: DateTime.tryParse(school.academicYearStart),
          );
          final validSecAtt = secAtt.where((r) {
            final dt = DateTime.tryParse(r.date);
            return dt?.weekday != DateTime.sunday && !holidayKeys.contains(r.date);
          }).toList();
          final p = validSecAtt.where((r) => r.status == 'present' || r.status == 'half_day').length;
          final a = validSecAtt.where((r) => r.status == 'absent').length;
          final l = validSecAtt.where((r) => r.status == 'late').length;
          final lv = validSecAtt.where((r) => r.status == 'approved_leave').length;
          final totalPossibleRecords = secStudents.length * (workDays > 0 ? workDays : 1);
          final u = (totalPossibleRecords - validSecAtt.length).clamp(0, totalPossibleRecords);

          adminSummaries.add(
            ClassSummaryRow(
              className: cls.name,
              sectionName: sec.name,
              enrolledCount: secStudents.length,
              presentCount: p,
              absentCount: a,
              lateCount: l,
              leaveCount: lv,
              unmarkedCount: u,
              attendancePercentage: kpkSec.percentageAttendance,
            ),
          );
        }
      }

      if (selectedReportType.value == ReportType.monthlyGoshwara) {
        final teachers = await studentRepository.getTeachers(schoolId);
        goshwaraTeachersList = [];
        int sno = 1;
        for (final t in teachers) {
          final prof = await studentRepository.getTeacherGoshwaraProfile(t.id);
          goshwaraTeachersList.add({
            'sno': sno++,
            'name': t.name,
            'father': prof.fatherName.isNotEmpty ? prof.fatherName : '-',
            'post': (t.designation != null && t.designation!.isNotEmpty)
                ? (t.designation!.contains('(') ? t.designation!.split('(').last.replaceAll(')', '').trim() : t.designation)
                : 'PST',
            'personal_no': prof.personalNo.isNotEmpty ? prof.personalNo : (t.cnic ?? '-'),
            'cnic': t.cnic ?? '-',
            'dob': prof.dob.isNotEmpty ? prof.dob : '-',
            'acad': prof.academicQualification.isNotEmpty ? prof.academicQualification : 'BA',
            'prof': prof.professionalQualification.isNotEmpty ? prof.professionalQualification : 'PTC/B.Ed',
            'appt': prof.appointmentDate.isNotEmpty ? prof.appointmentDate : '-',
            'school_date': prof.transferInDate.isNotEmpty ? prof.transferInDate : '-',
            'bps': prof.currentBps.isNotEmpty ? prof.currentBps : '14',
            'scale_date': prof.bpsAwardDate.isNotEmpty ? prof.bpsAwardDate : '-',
            'pay': prof.basicPay > 0 ? NumberFormat('#,##0').format(prof.basicPay) : '-',
            'type': prof.isPermanent ? 'Perm (مستقل)' : 'Fixed (عارضی)',
            'village': prof.village.isNotEmpty ? prof.village : '-',
            'tehsil': prof.unionCouncil.isNotEmpty ? prof.unionCouncil : settings.tehsil,
            'district': prof.district.isNotEmpty ? prof.district : settings.district,
            'phone': t.phone ?? '-',
          });
        }
      }
    }

    final teacherName = authCtrl.currentUser.value?.name ?? 'Class Teacher';
    final targetStudent = selectedStudent.value ??
        (students.isNotEmpty
            ? students.first
            : (allSectionStudents.isNotEmpty ? allSectionStudents.first : null));
    final extInfo = targetStudent != null
        ? await studentRepository.getExtendedInfo(targetStudent.id)
        : null;

    final preloadedAssets = await PdfGeneratorService.preloadPdfAssets();

    final payload = PdfGenerationPayload(
      type: selectedReportType.value,
      school: school,
      schoolClass: schoolClass,
      section: section,
      students: students,
      allSectionStudents: allSectionStudents,
      attendanceRecords: records,
      holidays: holidays,
      startDate: startDate.value,
      endDate: endDate.value,
      specificStudent: targetStudent,
      studentExtendedInfo: extInfo,
      schoolSettings: settings,
      teacherName: teacherName,
      headTeacherName: settings.headTeacherName,
      adminClassSummaries: adminSummaries,
      customSlcNumber: customSlcNumber.value.trim().isNotEmpty ? customSlcNumber.value.trim() : null,
      customFileNumber: customFileNumber.value.trim().isNotEmpty ? customFileNumber.value.trim() : null,
      customLeavingDate: customLeavingDate.value.trim().isNotEmpty ? customLeavingDate.value.trim() : null,
      customLeavingReason: customLeavingReason.value.trim(),
      customPromotedStatus: customPromotedStatus.value.trim().isNotEmpty ? customPromotedStatus.value.trim() : null,
      customConduct: customConduct.value.trim().isNotEmpty ? customConduct.value.trim() : null,
      customDob: customDob.value.trim().isNotEmpty ? customDob.value.trim() : null,
      customNationality: customNationality.value.trim(),
      isDuplicateSlc: isDuplicateSlc.value,
      goshwaraTeachers: goshwaraTeachersList,
      regularFontBytes: preloadedAssets.regularFontBytes,
      boldFontBytes: preloadedAssets.boldFontBytes,
      kpesedLogoBytes: preloadedAssets.kpesedLogoBytes,
      kpkGovtLogoBytes: preloadedAssets.kpkGovtLogoBytes,
    );

    final pdfBytes = await compute(_pdfGenerationWorker, payload);

    final sanitizedClass = schoolClass.name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final sanitizedSec = section.name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final filename = selectedReportType.value == ReportType.schoolLeavingCertificate && targetStudent != null
        ? '${school.code}_SLC_${targetStudent.admissionNumber}_${targetStudent.fullName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.pdf'
        : (selectedReportType.value == ReportType.monthlyGoshwara
            ? '${school.code}_Monthly_Goshwara_$startStr.pdf'
            : '${school.code}_${sanitizedClass}_${sanitizedSec}_$startStr.pdf');

    return (bytes: pdfBytes, filename: filename);
  }

  Future<void> previewPdf() async {
    try {
      isGenerating.value = true;
      final res = await buildPdfData();
      Get.to(
        () => Scaffold(
          appBar: AppBar(
            title: Text(res.filename, style: const TextStyle(fontSize: 13)),
            backgroundColor: AppColors.primaryDark,
            foregroundColor: Colors.white,
          ),
          body: PdfPreview(
            build: (format) async => res.bytes,
            pdfFileName: res.filename,
            canChangeOrientation: false,
            canChangePageFormat: false,
          ),
        ),
      );
    } catch (e) {
      Get.snackbar('Preview Failed', 'Error generating PDF preview: $e');
    } finally {
      isGenerating.value = false;
    }
  }

  Future<void> exportPdf() async {
    try {
      isGenerating.value = true;
      final res = await buildPdfData();
      await PdfGeneratorService.shareOrPrintPdf(
        pdfBytes: res.bytes,
        filename: res.filename,
      );
    } catch (e) {
      Get.snackbar('Export Failed', 'Error generating PDF: $e');
    } finally {
      isGenerating.value = false;
    }
  }

  /// Generates and exports an Excel-compatible UTF-8 CSV file for KPK EMIS & ASDEO reporting
  Future<void> exportCsv(BuildContext context) async {
    try {
      isGenerating.value = true;
      final attendanceCtrl = Get.find<AttendanceController>();
      final authCtrl = Get.find<AuthController>();

      final schoolClass = attendanceCtrl.selectedClass.value;
      final section = attendanceCtrl.selectedSection.value;
      final schoolId = authCtrl.currentUser.value?.schoolId;

      if (schoolId == null || schoolId.isEmpty || schoolClass == null || section == null) {
        Get.snackbar('Selection Required', 'Please select a class and section first.');
        return;
      }

      final school = await studentRepository.getSchool(schoolId);
      final students = await studentRepository.getStudentsForSection(
        classId: schoolClass.id,
        sectionId: section.id,
        schoolId: schoolId,
      );

      final startStr = DateFormat('yyyy-MM-dd').format(startDate.value);
      final endStr = DateFormat('yyyy-MM-dd').format(endDate.value);

      final records = await attendanceRepository.getAttendanceForDateRange(
        schoolId: schoolId,
        classId: schoolClass.id,
        sectionId: section.id,
        startDate: startStr,
        endDate: endStr,
      );
      final holidays = await studentRepository.getAllHolidaysForSchool(schoolId);
      final holidayKeys = holidays.map((h) => h.date).toSet();

      final workDays = PdfGeneratorService.calculateEligibleInstructionalDays(
        startDate: startDate.value,
        endDate: endDate.value,
        holidayDateKeys: holidayKeys,
      );

      String esc(String? val) {
        final v = (val ?? '').replaceAll('"', '""');
        return '"$v"';
      }

      final sb = StringBuffer();
      sb.writeln(
        'Roll No,Admission No,Student Name,Father Name,Gender,Form-B / CNIC,Father CNIC,Admission Date,Class,Section,Working Days,Present Days,Absent Days,Late Days,Approved Leave,Attendance Units (2x),Attendance %',
      );

      for (final s in students) {
        final sRecs = records.where((r) {
          if (r.studentId != s.id) return false;
          final dt = DateTime.tryParse(r.date);
          return dt?.weekday != DateTime.sunday && !holidayKeys.contains(r.date);
        }).toList();

        int p = 0, a = 0, l = 0, lv = 0, units = 0;
        for (final r in sRecs) {
          units += KpkDayMark.fromRecord(r).attendanceUnits;
          if (r.status == 'present' || r.status == 'half_day') p++;
          if (r.status == 'absent') a++;
          if (r.status == 'late') l++;
          if (r.status == 'approved_leave') lv++;
        }
        final denom = (workDays * 2) > 0 ? (workDays * 2) : 1;
        final pct = (units / denom * 100).clamp(0.0, 100.0).toStringAsFixed(1);

        sb.writeln([
          esc(s.rollNumber ?? '-'),
          esc(s.admissionNumber),
          esc(s.fullName),
          esc(s.fatherOrGuardianName),
          esc(s.gender),
          esc(s.studentCnic ?? ''),
          esc(s.fatherCnic ?? ''),
          esc(s.admissionDate),
          esc(schoolClass.name),
          esc(section.name),
          workDays,
          p,
          a,
          l,
          lv,
          units,
          '$pct%',
        ].join(','));
      }

      final csvText = sb.toString();
      await Clipboard.setData(ClipboardData(text: csvText));

      final code = school?.code ?? 'EMIS';
      final sanitizedClass = schoolClass.name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final csvFilename = '${code}_${sanitizedClass}_${startStr}_to_$endStr.csv';

      if (context.mounted) {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.white,
          showDragHandle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (ctx) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.table_view_rounded, color: Color(0xFF166534), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Excel / CSV Register Export Ready',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            ),
                            Text(
                              '$csvFilename (${students.length} students)',
                              style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 140,
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        csvText,
                        style: const TextStyle(fontSize: 10.5, fontFamily: 'monospace', color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryDark,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.copy_all_rounded, size: 18),
                          label: const Text('Copy CSV for Excel / WhatsApp', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: csvText));
                            Navigator.pop(ctx);
                            Get.snackbar(
                              'CSV Copied to Clipboard',
                              'Spreadsheet data copied! Paste directly into Excel, Google Sheets, or WhatsApp.',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: const Color(0xFFDCFCE7),
                              colorText: const Color(0xFF166534),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }
    } catch (e) {
      Get.snackbar('CSV Export Failed', 'Error exporting CSV: $e');
    } finally {
      isGenerating.value = false;
    }
  }

  /// Saves updated KPK School Settings & Goshwara profile via GetX Controller
  Future<void> saveSchoolSettings(SchoolSettingsModel settings) async {
    await studentRepository.saveSchoolSettings(settings);
  }

  /// Saves updated Teacher Goshwara Profile via GetX Controller
  Future<void> saveTeacherGoshwaraProfile(TeacherGoshwaraProfile profile) async {
    await studentRepository.saveTeacherGoshwaraProfile(profile);
  }

  /// Saves Student Leaving Certificate metadata via GetX Controller
  Future<void> saveStudentLeavingCertificate(StudentExtendedInfoModel info) async {
    await studentRepository.saveStudentExtendedInfo(info);
  }
}
