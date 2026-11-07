import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ChartSegment {
  final double value;
  final Color color;
  final String label;

  const ChartSegment({
    required this.value,
    required this.color,
    required this.label,
  });
}

/// Multi-segment animated donut chart for Attendance visualization
class AnimatedAttendanceDonutChart extends StatelessWidget {
  final int present;
  final int absent;
  final int lateCount;
  final int leave;
  final int halfDay;
  final int unmarked;
  final double size;
  final double strokeWidth;

  const AnimatedAttendanceDonutChart({
    super.key,
    required this.present,
    required this.absent,
    required this.lateCount,
    required this.leave,
    required this.halfDay,
    required this.unmarked,
    this.size = 108,
    this.strokeWidth = 12,
  });

  int get total => present + absent + lateCount + leave + halfDay + unmarked;

  double get attendancePercentage {
    if (total == 0) return 0;
    return ((present + lateCount + (halfDay * 0.5)) / total * 100).clamp(0.0, 100.0);
  }

  @override
  Widget build(BuildContext context) {
    final segments = <ChartSegment>[
      if (present > 0) ChartSegment(value: present.toDouble(), color: AppColors.present, label: 'Present'),
      if (lateCount > 0) ChartSegment(value: lateCount.toDouble(), color: AppColors.late, label: 'Late'),
      if (halfDay > 0) ChartSegment(value: halfDay.toDouble(), color: AppColors.halfDay, label: 'Half-Day'),
      if (leave > 0) ChartSegment(value: leave.toDouble(), color: AppColors.leave, label: 'Leave'),
      if (absent > 0) ChartSegment(value: absent.toDouble(), color: AppColors.absent, label: 'Absent'),
      if (unmarked > 0)
        ChartSegment(value: unmarked.toDouble(), color: const Color(0xFFE2E8F0), label: 'Unmarked'),
    ];

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeOutCubic,
      builder: (context, progress, _) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: _DonutChartPainter(
                  segments: segments,
                  total: total.toDouble(),
                  progress: progress,
                  strokeWidth: strokeWidth,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(attendancePercentage * progress).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: size * 0.21,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    unmarked == total && total > 0 ? 'Unmarked' : 'Attended',
                    style: TextStyle(
                      fontSize: size * 0.095,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<ChartSegment> segments;
  final double total;
  final double progress;
  final double strokeWidth;

  _DonutChartPainter({
    required this.segments,
    required this.total,
    required this.progress,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final bgPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    if (total <= 0 || segments.isEmpty) return;

    double startAngle = -math.pi / 2;
    final gapAngle = segments.length > 1 ? 0.04 : 0.0;

    for (final seg in segments) {
      final sweepAngle = ((seg.value / total) * 2 * math.pi * progress) - gapAngle;
      if (sweepAngle > 0) {
        final segPaint = Paint()
          ..color = seg.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = segments.length == 1 ? StrokeCap.butt : StrokeCap.round;

        canvas.drawArc(rect, startAngle + (gapAngle / 2), sweepAngle, false, segPaint);
      }
      startAngle += (seg.value / total) * 2 * math.pi * progress;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.total != total ||
        oldDelegate.segments.length != segments.length;
  }
}

/// Sleek horizontal stacked progress bar showing attendance status distribution
class StatusDistributionBar extends StatelessWidget {
  final int present;
  final int lateCount;
  final int leave;
  final int halfDay;
  final int absent;
  final int unmarked;
  final double height;

  const StatusDistributionBar({
    super.key,
    required this.present,
    required this.lateCount,
    required this.leave,
    required this.halfDay,
    required this.absent,
    required this.unmarked,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    final total = present + lateCount + leave + halfDay + absent + unmarked;
    if (total == 0) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(height),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            if (present > 0) Expanded(flex: present, child: Container(color: AppColors.present)),
            if (lateCount > 0) Expanded(flex: lateCount, child: Container(color: AppColors.late)),
            if (halfDay > 0) Expanded(flex: halfDay, child: Container(color: AppColors.halfDay)),
            if (leave > 0) Expanded(flex: leave, child: Container(color: AppColors.leave)),
            if (absent > 0) Expanded(flex: absent, child: Container(color: AppColors.absent)),
            if (unmarked > 0) Expanded(flex: unmarked, child: Container(color: const Color(0xFFE2E8F0))),
          ],
        ),
      ),
    );
  }
}
