import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/class_picker_sheet.dart';
import '../qr_scanner_controller.dart';
import '../../attendance/attendance_controller.dart';

class QrScannerView extends StatefulWidget {
  const QrScannerView({super.key});

  @override
  State<QrScannerView> createState() => _QrScannerViewState();
}

class _QrScannerViewState extends State<QrScannerView> with TickerProviderStateMixin {
  late AnimationController _laserAnimController;
  late Animation<double> _laserAnimation;

  late AnimationController _flashAnimController;
  late Animation<double> _flashAnimation;

  late AnimationController _badgePopController;
  late Animation<double> _badgeScaleAnimation;

  int _lastHandledTrigger = 0;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<QrScannerController>();
    controller.resetSession();

    // Continuous subtle laser sweep
    _laserAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _laserAnimController, curve: Curves.easeInOut),
    );

    // Reticle flash pulse animation upon successful or failed scan
    _flashAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _flashAnimation = CurvedAnimation(
      parent: _flashAnimController,
      curve: Curves.easeOutCubic,
    );

    // Quick celebratory center icon pop
    _badgePopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _badgeScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.25).chain(CurveTween(curve: Curves.easeOutBack)), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.25, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeInBack)), weight: 30),
    ]).animate(_badgePopController);
  }

  @override
  void dispose() {
    _laserAnimController.dispose();
    _flashAnimController.dispose();
    _badgePopController.dispose();
    super.dispose();
  }

  void _triggerScanVisualFeedback() {
    _flashAnimController.forward(from: 0.0);
    _badgePopController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<QrScannerController>();
    final attendanceCtrl = Get.find<AttendanceController>();
    final size = MediaQuery.of(context).size;
    final boxSize = size.width * 0.68;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Fullscreen Mobile Scanner Viewfinder
          MobileScanner(
            controller: controller.cameraController,
            onDetect: controller.onBarcodeDetected,
          ),

          // 2. Translucent Cutout Shroud with Aperture
          CustomPaint(
            size: Size.infinite,
            painter: _ScannerCutoutPainter(
              boxSize: boxSize,
              borderRadius: 20,
            ),
          ),

          // 3. Dynamic Animated Viewfinder Reticle & Laser
          Obx(() {
            final trigger = controller.scanFeedbackTrigger.value;
            if (trigger != _lastHandledTrigger) {
              _lastHandledTrigger = trigger;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _triggerScanVisualFeedback();
              });
            }
            return _buildInteractiveReticle(context, controller, boxSize);
          }),

          // 4. Center Pop Badge Feedback Icon (✓ or ⚠️ or ✕)
          Center(
            child: AnimatedBuilder(
              animation: _badgeScaleAnimation,
              builder: (context, child) {
                if (_badgeScaleAnimation.value == 0) return const SizedBox.shrink();
                final status = controller.lastStatus.value;
                final isSuccess = status == 'present' || status == 'late';
                final isWarning = status == 'already_marked' || status == 'cooldown';

                Color badgeBg = isSuccess
                    ? const Color(0xFF10B981)
                    : isWarning
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFFEF4444);

                IconData badgeIcon = isSuccess
                    ? Icons.check_rounded
                    : isWarning
                        ? Icons.done_all_rounded
                        : Icons.close_rounded;

                return Transform.scale(
                  scale: _badgeScaleAnimation.value,
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: badgeBg.withValues(alpha: 0.95),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: badgeBg.withValues(alpha: 0.55),
                          blurRadius: 22,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(badgeIcon, color: Colors.white, size: 46),
                  ),
                );
              },
            ),
          ),

          // 5. Top Floating App Bar & Live Scanned Counters
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button to exit QR Scanner
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: _controlCircleButton(
                          icon: Icons.arrow_back_rounded,
                          color: Colors.white,
                          tooltip: 'Back',
                          onPressed: () => Get.back(),
                        ),
                      ),

                      // Active Class and Section indicator pill with interactive switcher
                      Flexible(
                        child: InkWell(
                          onTap: () => showClassPickerSheet(context, attendanceCtrl),
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.70),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white24, width: 0.8),
                            ),
                            child: Obx(() {
                              final slot = attendanceCtrl.selectedTimeSlot.value;
                              final cls = attendanceCtrl.selectedClass.value;
                              final sec = attendanceCtrl.selectedSection.value;
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.school_rounded, size: 16, color: Color(0xFF34D399)),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      '${cls?.name ?? "Select Class"} • ${sec?.name ?? "Sec"}',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: slot == 1
                                          ? Colors.amberAccent.withValues(alpha: 0.25)
                                          : Colors.lightBlueAccent.withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      slot == 1 ? '1st' : '2nd',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w900,
                                        color: slot == 1 ? Colors.amberAccent : Colors.lightBlueAccent,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 16),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Flashlight toggle
                      _controlCircleButton(
                        icon: Icons.flash_on,
                        color: Colors.white,
                        tooltip: 'Toggle Flashlight',
                        onPressed: () => controller.cameraController.toggleTorch(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Compact Live Scanned / Unmarked Counter Strip
                  Obx(() => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white12, width: 0.8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _liveCounter('Present', attendanceCtrl.presentCount, Colors.greenAccent),
                            _counterDivider(),
                            _liveCounter('Late', attendanceCtrl.lateCount, Colors.amberAccent),
                            _counterDivider(),
                            _liveCounter('Unmarked', attendanceCtrl.unmarkedCount, Colors.orangeAccent),
                            _counterDivider(),
                            _liveCounter('Session', controller.sessionScanCount.value, Colors.lightBlueAccent),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),

          // 6. Watermark target indicator right below reticle
          Positioned(
            top: (size.height / 2) + (boxSize / 2) + 16,
            left: 0,
            right: 0,
            child: Center(
              child: Obx(() {
                final cls = attendanceCtrl.selectedClass.value;
                final sec = attendanceCtrl.selectedSection.value;
                final isClassMissing = cls == null;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isClassMissing
                        ? const Color(0xFFEF4444).withValues(alpha: 0.85)
                        : Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isClassMissing ? Colors.redAccent : Colors.white24,
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isClassMissing ? Icons.warning_amber_rounded : Icons.filter_center_focus_rounded,
                        size: 14,
                        color: isClassMissing ? Colors.white : const Color(0xFF34D399),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isClassMissing
                            ? 'No class selected! Tap top bar to select class.'
                            : 'Scanning strictly for: ${cls.name} • ${sec?.name ?? "Sec"}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),

          // 7. Bottom result card — shown after every scan event
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Obx(() {
              final student = controller.lastScannedStudent.value;
              final status  = controller.lastStatus.value;
              final trigger = controller.scanFeedbackTrigger.value;
              final message = controller.lastScannedMessage.value;
              final isHeld  = controller.isResultHeld.value;

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.15),
                      end: Offset.zero,
                    ).animate(animation),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<String>('${student?.id ?? "idle"}_$trigger'),
                  child: _buildBottomCard(context, controller, student, status, message, isHeld),
                ),
              );
            }),
          ),

          // 8. Full-screen transparent tap catcher during result-hold.
          //    Lets the teacher tap anywhere (above the card) to skip the hold
          //    and start scanning the next student immediately.
          Obx(() {
            if (!controller.isResultHeld.value) return const SizedBox.shrink();
            return Positioned(
              top: 0,
              left: 0,
              right: 0,
              // Only covers the area above the bottom card (~280 px tall)
              bottom: 220,
              child: GestureDetector(
                onTap: controller.resumeScanning,
                behavior: HitTestBehavior.translucent,
                child: const SizedBox.expand(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _controlCircleButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 0.8),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 19),
        tooltip: tooltip,
        onPressed: onPressed,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _counterDivider() {
    return Container(
      height: 20,
      width: 1,
      color: Colors.white12,
    );
  }

  Widget _liveCounter(String label, int count, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count.toString(),
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color, height: 1.1),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildInteractiveReticle(BuildContext context, QrScannerController controller, double boxSize) {
    final status = controller.lastStatus.value;
    final isSuccess = status == 'present' || status == 'late';
    final isWarning = status == 'already_marked' || status == 'cooldown';
    final isError = status == 'invalid' ||
        status == 'wrong_school' ||
        status == 'ineligible' ||
        status == 'wrong_class' ||
        status == 'wrong_section' ||
        status == 'no_class' ||
        status == 'revoked';

    Color activeBorderColor = Colors.white54;
    Color laserColor = const Color(0xFF10B981);

    if (isSuccess) {
      activeBorderColor = const Color(0xFF10B981);
      laserColor = const Color(0xFF10B981);
    } else if (isWarning) {
      activeBorderColor = const Color(0xFFF59E0B);
      laserColor = const Color(0xFFF59E0B);
    } else if (isError) {
      activeBorderColor = const Color(0xFFEF4444);
      laserColor = const Color(0xFFEF4444);
    }

    return Center(
      child: AnimatedBuilder(
        animation: _flashAnimation,
        builder: (ctx, child) {
          final flashVal = _flashAnimation.value;
          final borderColor = Color.lerp(activeBorderColor, Colors.white60, flashVal)!;
          final glowOpacity = (1.0 - flashVal) * 0.75;

          return Container(
            width: boxSize,
            height: boxSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: isSuccess || isError ? 3.0 : 2.0),
              boxShadow: [
                if (_flashAnimController.isAnimating)
                  BoxShadow(
                    color: activeBorderColor.withValues(alpha: glowOpacity),
                    blurRadius: 26,
                    spreadRadius: 6,
                  ),
              ],
            ),
            child: Stack(
              children: [
                // Reticle Corner Accents
                _cornerAccent(Alignment.topLeft, isError ? const Color(0xFFEF4444) : const Color(0xFF10B981)),
                _cornerAccent(Alignment.topRight, isError ? const Color(0xFFEF4444) : const Color(0xFF10B981)),
                _cornerAccent(Alignment.bottomLeft, isError ? const Color(0xFFEF4444) : const Color(0xFF10B981)),
                _cornerAccent(Alignment.bottomRight, isError ? const Color(0xFFEF4444) : const Color(0xFF10B981)),

                // Scanning Laser line or Status / Result Badge
                if (controller.isResultHeld.value)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.80),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: activeBorderColor.withValues(alpha: 0.9), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: activeBorderColor.withValues(alpha: 0.35),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSuccess
                                ? Icons.check_circle_rounded
                                : (isWarning ? Icons.verified_user_rounded : Icons.error_rounded),
                            color: activeBorderColor,
                            size: 19,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isSuccess
                                ? (status == 'late' ? 'MARKED LATE' : 'MARKED PRESENT')
                                : (isWarning
                                    ? 'ALREADY SCANNED'
                                    : (status == 'wrong_class'
                                        ? 'WRONG CLASS'
                                        : (status == 'wrong_section'
                                            ? 'WRONG SECTION'
                                            : 'INVALID QR'))),
                            style: TextStyle(
                              color: activeBorderColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  AnimatedBuilder(
                    animation: _laserAnimation,
                    builder: (ctx, _) {
                      return Positioned(
                        top: (boxSize - 12) * _laserAnimation.value,
                        left: 10,
                        right: 10,
                        child: Container(
                          height: 2.2,
                          decoration: BoxDecoration(
                            color: laserColor,
                            boxShadow: [
                              BoxShadow(
                                color: laserColor.withValues(alpha: 0.85),
                                blurRadius: 8,
                                spreadRadius: 1.5,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _cornerAccent(Alignment alignment, Color color) {
    const double length = 20.0;
    const double thickness = 3.5;

    final isTop = alignment == Alignment.topLeft || alignment == Alignment.topRight;
    final isLeft = alignment == Alignment.topLeft || alignment == Alignment.bottomLeft;

    return Align(
      alignment: alignment,
      child: Container(
        width: length,
        height: length,
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          border: Border(
            top: isTop ? BorderSide(color: color, width: thickness) : BorderSide.none,
            bottom: !isTop ? BorderSide(color: color, width: thickness) : BorderSide.none,
            left: isLeft ? BorderSide(color: color, width: thickness) : BorderSide.none,
            right: !isLeft ? BorderSide(color: color, width: thickness) : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: alignment == Alignment.topLeft ? const Radius.circular(16) : Radius.zero,
            topRight: alignment == Alignment.topRight ? const Radius.circular(16) : Radius.zero,
            bottomLeft: alignment == Alignment.bottomLeft ? const Radius.circular(16) : Radius.zero,
            bottomRight: alignment == Alignment.bottomRight ? const Radius.circular(16) : Radius.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomCard(
    BuildContext context,
    QrScannerController controller,
    dynamic student,
    String status,
    String message,
    bool isHeld,
  ) {
    final hasStudent = student != null;
    final attCtrl = Get.find<AttendanceController>();
    final activeClassName = attCtrl.selectedClass.value?.name ?? 'Selected Class';

    // 1. CONCISE & PRECISE CLASS MISMATCH CARD
    if (status == 'wrong_class') {
      final enrolledName = controller.mismatchedClassName.value.isNotEmpty
          ? controller.mismatchedClassName.value
          : 'Other Class';

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFCA5A5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.wrong_location_rounded, size: 24, color: Color(0xFFDC2626)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        hasStudent ? student.fullName : 'Class Mismatch',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Enrolled in $enrolledName (Active: $activeClassName)',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFDC2626)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: SizedBox(
                    height: 40,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.border, width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: controller.resumeScanning,
                      child: const Text('Scan Next', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
                if (controller.mismatchedClassId.value.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 6,
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                        label: Text(
                          'Switch to $enrolledName',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        onPressed: () => controller.switchToStudentClass(),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      );
    }

    // 2. CONCISE & PRECISE SECTION MISMATCH CARD
    if (status == 'wrong_section') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFDBA74), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEDD5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.group_off_rounded, size: 24, color: Color(0xFFEA580C)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        hasStudent ? student.fullName : 'Section Mismatch',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        message,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFEA580C)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.border, width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: controller.resumeScanning,
                child: const Text('Scan Next Student', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      );
    }

    // 3. STANDARD STATUS CARDS (PRESENT, LATE, ALREADY MARKED, OR IDLE)
    IconData statusIcon = Icons.qr_code_scanner_rounded;
    Color iconColor = AppColors.primary;
    Color bgTint = AppColors.primaryLight;
    Color statusBadgeColor = AppColors.primary;
    String statusBadgeText = 'READY';

    if (status == 'present') {
      statusIcon = Icons.check_circle_rounded;
      iconColor = AppColors.present;
      bgTint = AppColors.presentBg;
      statusBadgeColor = AppColors.present;
      statusBadgeText = 'PRESENT';
    } else if (status == 'late') {
      statusIcon = Icons.access_time_filled_rounded;
      iconColor = AppColors.late;
      bgTint = AppColors.lateBg;
      statusBadgeColor = AppColors.late;
      statusBadgeText = 'LATE';
    } else if (status == 'already_marked' || status == 'cooldown') {
      statusIcon = Icons.verified_user_rounded;
      iconColor = AppColors.leave;
      bgTint = AppColors.leaveBg;
      statusBadgeColor = AppColors.leave;
      statusBadgeText = 'ALREADY MARKED';
    } else if (status.isNotEmpty) {
      statusIcon = Icons.error_outline_rounded;
      iconColor = AppColors.absent;
      bgTint = AppColors.absentBg;
      statusBadgeColor = AppColors.absent;
      statusBadgeText = status == 'revoked' ? 'REVOKED' : 'WARNING';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Left Badge / Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: bgTint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(statusIcon, size: 28, color: iconColor),
              ),
              const SizedBox(width: 14),

              // Middle info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            hasStudent ? student.fullName : 'Scan Student ID Badge',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasStudent) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusBadgeColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              statusBadgeText,
                              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: statusBadgeColor),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      hasStudent
                          ? 'Roll: ${student.rollNumber ?? "-"} • ${student.fatherOrGuardianName ?? ""}'
                          : message,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: hasStudent ? FontWeight.w500 : FontWeight.normal,
                        color: hasStudent ? Colors.grey.shade800 : Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (hasStudent && status != 'already_marked' && status != 'cooldown') ...[
                      const SizedBox(height: 2),
                      Text(
                        message,
                        style: TextStyle(fontSize: 11, color: iconColor, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (isHeld && hasStudent)
            (status == 'present' || status == 'late' || status == 'already_marked' || status == 'cooldown')
                ? _buildNextStudentAction(controller)
                : _nextStudentHint(controller),
        ],
      ),
    );
  }

  /// Prominent, professional "Next Student" button shown when a student is scanned successfully.
  Widget _buildNextStudentAction(QrScannerController controller) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Obx(() {
        final isAuto = controller.autoScanNext.value;
        final isAlreadyMarked = controller.lastStatus.value == 'already_marked' || controller.lastStatus.value == 'cooldown';

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAlreadyMarked ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                label: const Text(
                  'Next Student',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, letterSpacing: 0.3),
                ),
                onPressed: controller.resumeScanning,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isAlreadyMarked
                  ? 'Already scanned • Tap button to scan next student'
                  : (isAuto
                      ? 'Auto-advancing in 2s... or tap button to scan next'
                      : 'Scanner paused • Tap button or viewfinder to scan next student'),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      }),
    );
  }

  /// Professional "Dismiss & Scan Next" button shown at bottom of result card during hold.
  Widget _nextStudentHint(QrScannerController controller, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SizedBox(
        width: double.infinity,
        height: 40,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            backgroundColor: isError
                ? const Color(0xFFFEF2F2)
                : const Color(0xFFF0FDF4),
            side: BorderSide(
              color: isError
                  ? const Color(0xFFFCA5A5)
                  : const Color(0xFF86EFAC),
              width: 1.2,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: controller.resumeScanning,
          icon: Icon(
            isError ? Icons.close_rounded : Icons.refresh_rounded,
            size: 17,
            color: isError ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
          ),
          label: Text(
            isError ? 'Dismiss & Scan Next' : 'Scan Next Student',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: isError ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
            ),
          ),
        ),
      ),
    );
  }



}

/// Custom painter for semi-translucent cutout aperture over the camera preview
class _ScannerCutoutPainter extends CustomPainter {
  final double boxSize;
  final double borderRadius;

  const _ScannerCutoutPainter({
    required this.boxSize,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.58);

    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCenter(center: center, width: boxSize, height: boxSize);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(rrect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ScannerCutoutPainter oldDelegate) {
    return oldDelegate.boxSize != boxSize || oldDelegate.borderRadius != borderRadius;
  }
}
