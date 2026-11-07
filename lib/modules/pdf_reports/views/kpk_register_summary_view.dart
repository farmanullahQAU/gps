import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/kpk_register_helper.dart';
import '../../../core/widgets/class_picker_sheet.dart';
import '../../attendance/attendance_controller.dart';
import '../pdf_generator_service.dart';
import '../pdf_reports_controller.dart';

/// Professional, clean, and scannable End-of-Month Register Summary View
/// (گوشوارہ حاضری ماہانہ - Statutory KPK 8-Column Register Summary)
class KpkMonthlyRegisterSummaryView extends StatelessWidget {
  const KpkMonthlyRegisterSummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    final reportCtrl = Get.find<PdfReportsController>();
    final attCtrl = Get.find<AttendanceController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Monthly Goshwara (گوشوارہ حاضری ماہانہ)',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            Text(
              'KPK E&SED Statutory 8-Column Register Summary',
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        final kpk = reportCtrl.reportPeriodSummary.value ??
            attCtrl.currentMonthKpkSummary.value;
        final selectedCls = attCtrl.selectedClass.value;
        final clsName = selectedCls?.name ?? 'Class';
        final secName = attCtrl.selectedSection.value?.name;
        final monthName = DateFormat('MMMM yyyy').format(reportCtrl.startDate.value);

        if (kpk == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.calculate_outlined, size: 36, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Calculating Register Summary...',
                  style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        final avgDaily = kpk.averageAttendance.toStringAsFixed(1);
        final pctAtt = kpk.percentageAttendance.toStringAsFixed(1);
        final isEquationValid = (kpk.studentsAtStartOfMonth + kpk.admittedDuringMonth - kpk.withdrawnDuringMonth) == kpk.studentsAtEndOfMonth;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
          children: [
            // -------------------------------------------------------------
            // 1. Context Selector Card (Class & Month)
            // -------------------------------------------------------------
            // -------------------------------------------------------------
            // 1. Context Selector Card (Class & Month)
            // -------------------------------------------------------------
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 340;
                  final children = [
                    // Class selector tile
                    Expanded(
                      flex: isCompact ? 0 : 1,
                      child: InkWell(
                        onTap: () => showClassPickerSheet(context, attCtrl),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryDark.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: const Icon(Icons.school_rounded, size: 15, color: AppColors.primaryDark),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'CLASS',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF64748B),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      secName == null ? clsName : '$clsName ($secName)',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.unfold_more_rounded, size: 18, color: AppColors.textSecondary),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: isCompact ? 0 : 8, height: isCompact ? 8 : 0),
                    // Month selector tile
                    Expanded(
                      flex: isCompact ? 0 : 1,
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: reportCtrl.startDate.value,
                            firstDate: DateTime(DateTime.now().year - 2),
                            lastDate: DateTime.now(),
                            helpText: 'Select Month',
                          );
                          if (picked != null) {
                            reportCtrl.startDate.value = DateTime(picked.year, picked.month, 1);
                            reportCtrl.endDate.value = KpkMonthlySummary.lastDayOfMonth(picked.year, picked.month);
                          }
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: const Icon(Icons.calendar_month_rounded, size: 15, color: Color(0xFF2563EB)),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'PERIOD',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF64748B),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      monthName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.unfold_more_rounded, size: 18, color: AppColors.textSecondary),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ];

                  return isCompact
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: children,
                        )
                      : Row(
                          children: children,
                        );
                },
              ),
            ),
            const SizedBox(height: 14),

            // -------------------------------------------------------------
            // 2. High-Level KPI Summary (Present % & Daily Avg)
            // -------------------------------------------------------------
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.pie_chart_rounded, size: 20, color: Color(0xFF166534)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Attendance %',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                '$pctAtt%',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF166534),
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.analytics_rounded, size: 20, color: Color(0xFF1D4ED8)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Daily Average',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                avgDaily,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1D4ED8),
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // -------------------------------------------------------------
            // 3. Days Breakdown Strip (Working, Sundays, Holidays)
            // -------------------------------------------------------------
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  _dayChip('Working Days', '${kpk.workingDays}', const Color(0xFF0F5132), isBold: true),
                  _vSep(),
                  _dayChip('Calendar Days', '${kpk.totalCalendarDays}', const Color(0xFF334155)),
                  _vSep(),
                  _dayChip('Sundays', '${kpk.sundaysCount}', const Color(0xFF64748B)),
                  _vSep(),
                  _dayChip('Holidays', '${kpk.holidaysCount}', const Color(0xFFDC2626)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // -------------------------------------------------------------
            // 4. Student Enrollment Balance (Cols 1 - 4)
            // -------------------------------------------------------------
            const Padding(
              padding: EdgeInsets.only(left: 2, bottom: 6),
              child: Text(
                'Student Enrollment & Movement (تعداد طلباء)',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _statItem(
                    col: '1',
                    title: 'Month Opening Roll',
                    urdu: 'مہینے کے شروع میں طلباء',
                    value: '${kpk.studentsAtStartOfMonth}',
                    color: const Color(0xFF2563EB),
                    icon: Icons.group_outlined,
                  ),
                  const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
                  _statItem(
                    col: '2',
                    title: 'New Admissions',
                    urdu: 'داخل شدہ',
                    value: '+${kpk.admittedDuringMonth}',
                    color: const Color(0xFF16A34A),
                    icon: Icons.person_add_alt_1_rounded,
                  ),
                  const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
                  _statItem(
                    col: '3',
                    title: 'Withdrawals / Struck Off',
                    urdu: 'خارج شدہ',
                    value: '-${kpk.withdrawnDuringMonth}',
                    color: const Color(0xFFDC2626),
                    icon: Icons.person_remove_rounded,
                  ),
                  const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
                  _statItem(
                    col: '4',
                    title: 'Month End Roll',
                    urdu: 'بقایا تعداد (ماہ کے آخر میں)',
                    value: '${kpk.studentsAtEndOfMonth}',
                    color: const Color(0xFF0F5132),
                    icon: Icons.verified_user_rounded,
                    highlight: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // -------------------------------------------------------------
            // 5. School Sessions & Ratios (Cols 5 - 8)
            // -------------------------------------------------------------
            const Padding(
              padding: EdgeInsets.only(left: 2, bottom: 6),
              child: Text(
                'Sessions & Attendance Metrics (اوقات مدرسہ و حاضری)',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _statItem(
                    col: '5',
                    title: 'Monthly Madrasah Sessions',
                    urdu: 'ماہ کے کل اوقات (2x روزانہ)',
                    value: '${kpk.totalSchoolSessions}',
                    color: const Color(0xFF7C3AED),
                    icon: Icons.access_time_rounded,
                  ),
                  const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
                  _statItem(
                    col: '6',
                    title: 'Year-to-Date Sessions',
                    urdu: 'شروع سال سے اب تک اوقات',
                    value: '${kpk.cumulativeSessionsFromYearStart}',
                    color: const Color(0xFF4F46E5),
                    icon: Icons.history_rounded,
                  ),
                  const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
                  _statItem(
                    col: '7',
                    title: 'Average Daily Attendance',
                    urdu: 'اوسط حاضری روزانہ',
                    value: avgDaily,
                    color: const Color(0xFF0D9488),
                    icon: Icons.bar_chart_rounded,
                    highlight: true,
                  ),
                  const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
                  _statItem(
                    col: '8',
                    title: 'Attendance Percentage',
                    urdu: 'فیصد حاضری',
                    value: '$pctAtt%',
                    color: const Color(0xFFD97706),
                    icon: Icons.percent_rounded,
                    highlight: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // -------------------------------------------------------------
            // 6. Clean Verification Footer
            // -------------------------------------------------------------
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isEquationValid ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isEquationValid ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isEquationValid ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                    size: 18,
                    color: isEquationValid ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isEquationValid
                          ? 'Roll Balance Verified: ${kpk.studentsAtStartOfMonth} + ${kpk.admittedDuringMonth} - ${kpk.withdrawnDuringMonth} = ${kpk.studentsAtEndOfMonth}'
                          : 'Roll mismatch detected. Please review student admissions and withdrawals.',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isEquationValid ? const Color(0xFF166534) : const Color(0xFF991B1B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Obx(() {
            final busy = reportCtrl.isGenerating.value;
            return Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: busy
                        ? null
                        : () {
                            reportCtrl.selectedReportType.value = ReportType.monthlyMatrix;
                            reportCtrl.previewPdf();
                          },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: AppColors.primaryDark,
                      side: const BorderSide(color: AppColors.primaryDark, width: 1.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text(
                      'Preview PDF (پیش نظارہ)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: busy
                        ? null
                        : () {
                            reportCtrl.selectedReportType.value = ReportType.monthlyMatrix;
                            reportCtrl.exportPdf();
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: busy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.print_rounded, size: 18),
                    label: const Text(
                      'Print Goshwara (پرنٹ)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _dayChip(String label, String value, Color color, {bool isBold = false}) {
    return Expanded(
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 1),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _vSep() => Container(
        width: 1,
        height: 22,
        color: const Color(0xFFE2E8F0),
      );

  Widget _statItem({
    required String col,
    required String title,
    required String urdu,
    required String value,
    required Color color,
    required IconData icon,
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          // Column badge
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              col,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Title & Urdu label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  urdu,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Value Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: highlight ? color.withValues(alpha: 0.12) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: highlight ? color.withValues(alpha: 0.3) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
                color: highlight ? color : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
