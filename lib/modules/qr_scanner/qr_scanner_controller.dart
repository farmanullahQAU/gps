import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/database/app_database.dart';
import '../../core/utils/kpk_register_helper.dart';
import '../../data/repositories/attendance_repository.dart';
import '../../data/repositories/student_repository.dart';
import '../attendance/attendance_controller.dart';
import '../auth/auth_controller.dart';
import '../../core/services/sound_effect_service.dart';

/// How long (ms) the scanner stays frozen after any event before resuming.
/// A short pause ensures the teacher can read the result clearly.
const int _kSuccessHoldMs = 2000;   // 2.0 s — green tick + next button, then resume
const int _kWarningHoldMs = 2200;   // 2.2 s — amber "already marked"
const int _kRejectHoldMs  = 3000;   // 3.0 s — red mismatch / invalid

/// Per-student cooldown guard against scanning the same card twice in a row.
const int _kCooldownMs = 5000; // 5 s

class QrScannerController extends GetxController {
  final StudentRepository studentRepository;
  final AttendanceRepository attendanceRepository;

  QrScannerController({
    required this.studentRepository,
    required this.attendanceRepository,
  });

  MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  final RxBool isScanning = true.obs;
  final RxString lastScannedMessage = 'Ready to scan student QR ID cards'.obs;
  final Rx<Student?> lastScannedStudent = Rx<Student?>(null);
  final RxString lastStatus = ''.obs;
  final RxInt sessionScanCount = 0.obs;

  /// Increments on each scan event to trigger the reticle flash / badge pop.
  final RxInt scanFeedbackTrigger = 0.obs;

  /// True while the scanner is frozen in a result-hold period.
  /// During this time, the camera stream is ignored.
  final RxBool isResultHeld = false.obs;

  /// Whether the scanner automatically resumes after a scan.
  /// Defaults to false (pauses on scan; waits for teacher to press "Next Student").
  /// Can be toggled on in settings or the scanner screen header.
  final RxBool autoScanNext = false.obs;
  static const String _kAutoScanPrefKey = 'qr_auto_scan_next_v2';

  // Mismatch routing info exposed to the view
  final RxString mismatchedClassName = ''.obs;
  final RxString mismatchedClassId = ''.obs;

  // Atomic lock — prevents the same frame from entering processQrToken twice.
  bool _isProcessingToken = false;

  // Per-student cooldown map (only for same-class duplicate guard)
  final Map<String, int> _scanCooldownMap = {};

  @override
  void onInit() {
    super.onInit();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      autoScanNext.value = prefs.getBool(_kAutoScanPrefKey) ?? false;
    } catch (_) {}
  }

  Future<void> toggleAutoScanNext(bool value) async {
    autoScanNext.value = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kAutoScanPrefKey, value);
    } catch (_) {}
  }

  @override
  void onClose() {
    cameraController.dispose();
    super.onClose();
  }

  /// Call this when the scanner screen opens so stale state is cleared.
  void resetSession() {
    lastScannedStudent.value = null;
    lastStatus.value = '';
    mismatchedClassId.value = '';
    mismatchedClassName.value = '';
    lastScannedMessage.value = 'Ready to scan student QR ID cards';
    isResultHeld.value = false;
    _isProcessingToken = false;
  }

  /// Immediately dismiss the current result card and resume scanning.
  /// Exposed so the view's "Next Student" tap calls this.
  void resumeScanning() {
    isResultHeld.value = false;
    _isProcessingToken = false;
    lastScannedStudent.value = null;
    lastStatus.value = '';
    mismatchedClassId.value = '';
    mismatchedClassName.value = '';
    lastScannedMessage.value = 'Ready to scan student QR ID cards';
    HapticFeedback.selectionClick();
  }

  /// Switch the active scanner class to the student's registered class.
  Future<void> switchToStudentClass() async {
    if (mismatchedClassId.value.isNotEmpty) {
      final attendanceCtrl = Get.find<AttendanceController>();
      await attendanceCtrl.switchClassById(mismatchedClassId.value);
      mismatchedClassId.value = '';
      mismatchedClassName.value = '';
      lastScannedStudent.value = null;
      lastStatus.value = '';
      lastScannedMessage.value =
          'Switched to ${attendanceCtrl.selectedClass.value?.name ?? "Class"}. Ready to scan.';
      isResultHeld.value = false;
      _isProcessingToken = false;
      HapticFeedback.selectionClick();
    }
  }

  // ─── Camera callback ──────────────────────────────────────────────────────

  Future<void> onBarcodeDetected(BarcodeCapture capture) async {
    // Block during result-hold OR if another frame is already being processed.
    if (isResultHeld.value || _isProcessingToken) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawToken = barcodes.first.rawValue;
    if (rawToken == null || rawToken.trim().isEmpty) return;

    await processQrToken(rawToken.trim());
  }

  // ─── Core logic ──────────────────────────────────────────────────────────

  Future<void> processQrToken(String token) async {
    if (_isProcessingToken || isResultHeld.value) return;
    _isProcessingToken = true;

    try {
      final now = DateTime.now().millisecondsSinceEpoch;

      // ── 1. Database lookup ────────────────────────────────────────────────
      final student = await studentRepository.getStudentByQrToken(token);

      if (student == null) {
        final revokedOwner = await studentRepository.findStudentByRevokedQrToken(token);
        HapticFeedback.heavyImpact();
        if (revokedOwner != null) {
          _emit(
            student: revokedOwner,
            status: 'revoked',
            message: 'REVOKED CARD: Old QR for ${revokedOwner.fullName} has been replaced.',
            holdMs: _kRejectHoldMs,
          );
          return;
        }
        _emit(
          student: null,
          status: 'invalid',
          message: 'Invalid QR Code — credential not recognised.',
          holdMs: _kRejectHoldMs,
        );
        return;
      }

      // ── 2. School verification ────────────────────────────────────────────
      final currentSchoolId = Get.find<AuthController>().currentUser.value?.schoolId;
      if (currentSchoolId != null && student.schoolId != currentSchoolId) {
        HapticFeedback.heavyImpact();
        _emit(
          student: null,
          status: 'wrong_school',
          message: 'This card belongs to another school.',
          holdMs: _kRejectHoldMs,
        );
        return;
      }

      // ── 3. Class check — BEFORE cooldown / duplicate checks ───────────────
      //       This guarantees a wrong-class card NEVER shows "already scanned".
      final attendanceCtrl = Get.find<AttendanceController>();
      final activeClass = attendanceCtrl.selectedClass.value;

      if (activeClass == null) {
        HapticFeedback.heavyImpact();
        _emit(
          student: null,
          status: 'no_class',
          message: 'No class selected. Tap the top bar to choose a class.',
          holdMs: _kRejectHoldMs,
        );
        return;
      }

      final studentClassId = student.classId.trim();
      final activeClassId  = activeClass.id.trim();

      if (studentClassId != activeClassId) {
        // Double heavy buzz — teacher can feel the rejection without looking.
        HapticFeedback.heavyImpact();
        Future.delayed(const Duration(milliseconds: 130), () => HapticFeedback.heavyImpact());

        final studentClass = attendanceCtrl.classesList.firstWhereOrNull(
          (c) => c.id.trim() == studentClassId,
        );
        final enrolledName = studentClass?.name ?? 'Class ($studentClassId)';

        mismatchedClassId.value   = studentClassId;
        mismatchedClassName.value = enrolledName;

        _emit(
          student: student,
          status: 'wrong_class',
          message: 'Wrong Class: ${student.fullName} is enrolled in $enrolledName '
              '(scanner is set to ${activeClass.name})',
          holdMs: _kRejectHoldMs,
        );
        return;
      }

      // ── 4. Section check ──────────────────────────────────────────────────
      final activeSection   = attendanceCtrl.selectedSection.value;
      final studentSectionId = student.sectionId.trim();
      final activeSectionId  = activeSection?.id.trim();

      if (activeSectionId != null && activeSectionId.isNotEmpty && studentSectionId != activeSectionId) {
        HapticFeedback.heavyImpact();
        Future.delayed(const Duration(milliseconds: 130), () => HapticFeedback.heavyImpact());

        final studentSec = attendanceCtrl.sectionsList.firstWhereOrNull(
          (s) => s.id.trim() == studentSectionId,
        );
        final enrolledSec = studentSec?.name ?? 'Section ($studentSectionId)';

        mismatchedClassId.value   = '';
        mismatchedClassName.value = '';

        _emit(
          student: student,
          status: 'wrong_section',
          message: 'Wrong Section: ${student.fullName} is in $enrolledSec (selected: ${activeSection?.name})',
          holdMs: _kRejectHoldMs,
        );
        return;
      }

      // ── 5. Enrolment eligibility ──────────────────────────────────────────
      final dateStr = attendanceCtrl.dateString;

      if (student.status != 'active') {
        HapticFeedback.vibrate();
        _emit(
          student: student,
          status: 'ineligible',
          message: '${student.fullName} status is ${student.status.toUpperCase()} — cannot mark attendance.',
          holdMs: _kRejectHoldMs,
        );
        return;
      }

      if (student.admissionDate.compareTo(dateStr) > 0) {
        HapticFeedback.vibrate();
        _emit(
          student: student,
          status: 'ineligible',
          message: 'Not enrolled on $dateStr (admission: ${student.admissionDate}).',
          holdMs: _kRejectHoldMs,
        );
        return;
      }

      // ── 6. Per-student cooldown (same-class duplicate rapid-scan guard) ───
      final lastScanTime = _scanCooldownMap[student.id] ?? 0;
      if (now - lastScanTime < _kCooldownMs) {
        HapticFeedback.selectionClick();
        _emit(
          student: student,
          status: 'cooldown',
          message: '${student.fullName} was just scanned. Wait a moment before scanning again.',
          holdMs: _kWarningHoldMs,
        );
        return;
      }

      // ── 7. Already-marked check ───────────────────────────────────────────
      final activeSlot     = attendanceCtrl.selectedTimeSlot.value;
      final existingRecord = attendanceCtrl.attendanceMap[student.id];
      final currentMark    = KpkDayMark.fromRecord(existingRecord);

      if (activeSlot == 1 && currentMark.firstTime == 'P') {
        HapticFeedback.selectionClick();
        _emit(
          student: student,
          status: 'already_marked',
          message: 'Already Present (1st Time): ${student.fullName} — ${existingRecord?.arrivalTime ?? "Morning"}.',
          holdMs: _kWarningHoldMs,
        );
        return;
      }
      if (activeSlot == 2 && currentMark.secondTime == 'P') {
        HapticFeedback.selectionClick();
        _emit(
          student: student,
          status: 'already_marked',
          message: 'Already Present (2nd Time): ${student.fullName}.',
          holdMs: _kWarningHoldMs,
        );
        return;
      }

      // ── 8. Mark attendance ────────────────────────────────────────────────
      _scanCooldownMap[student.id] = now;

      mismatchedClassId.value   = '';
      mismatchedClassName.value = '';

      final auth     = Get.find<AuthController>();
      final userId   = auth.currentUser.value?.id ?? 'usr_teacher_001';
      final settings = await studentRepository.getSchoolSettings(student.schoolId);
      final cutoffParts = settings.lateCutoffTime.split(':');
      final cutoffHour  = int.tryParse(cutoffParts.first) ?? 8;
      final cutoffMin   = cutoffParts.length > 1 ? (int.tryParse(cutoffParts[1]) ?? 15) : 15;

      final nowDt      = DateTime.now();
      final arrivalTime = DateFormat('HH:mm:ss').format(nowDt);
      final isLate = (activeSlot == 1) &&
          (nowDt.hour > cutoffHour || (nowDt.hour == cutoffHour && nowDt.minute > cutoffMin));

      KpkDayMark nextMark;
      if (activeSlot == 1) {
        final nextS2 = (currentMark.secondTime == 'P') ? 'P' : '_';
        nextMark = KpkDayMark(
          firstTime: 'P',
          secondTime: nextS2,
          isLate: isLate,
          customDepartureTime: currentMark.customDepartureTime,
        );
      } else {
        final s1 = currentMark.firstTime == '_' ? 'P' : currentMark.firstTime;
        nextMark = KpkDayMark(
          firstTime: s1,
          secondTime: 'P',
          isLate: currentMark.isLate,
          customDepartureTime: currentMark.customDepartureTime,
        );
      }

      final dbStatus        = nextMark.toDbStatus();
      final effectiveArrival = (activeSlot == 1 || existingRecord?.arrivalTime == null)
          ? arrivalTime
          : existingRecord?.arrivalTime;

      await attendanceRepository.markAttendance(
        schoolId:      student.schoolId,
        studentId:     student.id,
        classId:       student.classId,
        sectionId:     student.sectionId,
        date:          dateStr,
        status:        dbStatus,
        arrivalTime:   effectiveArrival,
        departureTime: nextMark.encodeDepartureTime(),
        markedByUserId: userId,
        markingMethod: 'qr_scan',
        remarks: 'Scanned via QR at $arrivalTime (${activeSlot == 1 ? "1st Time" : "2nd Time"})',
      );

      // Double light click = success
      HapticFeedback.lightImpact();
      SystemSound.play(SystemSoundType.click);
      Future.delayed(const Duration(milliseconds: 90), () {
        HapticFeedback.lightImpact();
        SystemSound.play(SystemSoundType.click);
      });

      sessionScanCount.value++;

      _emit(
        student: student,
        status: dbStatus,
        message: '${student.fullName} • ${dbStatus == "late" ? "Late" : "Present"} at $arrivalTime',
        holdMs: _kSuccessHoldMs,
      );
    } finally {
      // The _isProcessingToken flag is released by _startHold() after the hold
      // period expires, OR immediately if _emit was never reached (error path).
      // We ensure it's always cleared in the error case:
      if (!isResultHeld.value) {
        _isProcessingToken = false;
      }
    }
  }

  // ─── Internal helpers ────────────────────────────────────────────────────

  /// Atomically update all reactive state and start the visual hold timer.
  void _emit({
    required Student? student,
    required String status,
    required String message,
    required int holdMs,
  }) {
    lastScannedStudent.value = student;
    lastStatus.value         = status;
    lastScannedMessage.value = message;
    scanFeedbackTrigger.value++;   // triggers reticle flash + badge pop in view

    // Trigger audio feedback based on scan outcome
    if (status == 'present' || status == 'late') {
      SoundEffectService.instance.playSuccess();
    } else if (status == 'already_marked') {
      SoundEffectService.instance.playWarning();
    } else {
      SoundEffectService.instance.playError();
    }

    // When autoScanNext is false (default), the scanner pauses on scan and waits
    // for the user to press "Next Student". When true, auto-resumes after holdMs.
    final allowAutoResume = autoScanNext.value;

    _startHold(holdMs, allowAutoResume: allowAutoResume);
  }

  /// Freeze the scanner for [holdMs] milliseconds, then auto-resume if allowed.
  /// When allowAutoResume is false, stays held until "Next Student" is tapped.
  void _startHold(int holdMs, {bool allowAutoResume = true}) {
    isResultHeld.value = true;

    if (allowAutoResume && holdMs > 0) {
      Future.delayed(Duration(milliseconds: holdMs), () {
        // Only auto-resume if the teacher hasn't already tapped "Next Student".
        if (isResultHeld.value) {
          isResultHeld.value   = false;
          _isProcessingToken   = false;
        }
      });
    }
  }
}
