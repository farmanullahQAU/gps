import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/kpk_register_helper.dart';
import '../../../core/widgets/class_picker_sheet.dart';
import '../pdf_generator_service.dart';
import '../pdf_reports_controller.dart';
import '../../attendance/attendance_controller.dart';
import 'monthly_goshwara_view.dart';
import 'school_leaving_certificate_view.dart';

/// Compact, scannable Official KPK PDF Reports screen:
/// 1. Unified Scope & Period Header (Class + Form Master, Date Range & Quick Presets)
/// 2. Compact 5-Template Selection List (fits on one screen without clutter)
/// 3. Sticky Bottom Preview & Print Action Bar
class PdfReportsView extends StatelessWidget {
  const PdfReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PdfReportsController>();
    final attendanceCtrl = Get.find<AttendanceController>();

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'pdf_reports'.tr,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // 1. Compact Scope & Reporting Period Header
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Class Selection & Current Date in One Row
                Obx(() {
                  final selectedCls = attendanceCtrl.selectedClass.value;
                  final cls = selectedCls?.name ?? 'Class';
                  final periodRange = controller.periodFormattedRange;

                  return Row(
                    children: [
                      // 1. Compact Class Selection Widget (Clean class name with dropdown arrow, no duplicate number)
                      InkWell(
                        onTap: () => showClassPickerSheet(context, attendanceCtrl),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 38,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: AppColors.bgLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                cls,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 3),
                              const Icon(Icons.arrow_drop_down_rounded, size: 20, color: AppColors.textSecondary),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // 2. Selected Date Range Widget with Stepper chevrons (like attendance page)
                      Expanded(
                        child: Container(
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.bgLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(9)),
                                  onTap: () => controller.stepPreviousDay(),
                                  child: const SizedBox(
                                    width: 30,
                                    height: 38,
                                    child: Icon(Icons.chevron_left_rounded, size: 20, color: AppColors.textSecondary),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () => _pickCustomRange(context, controller),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_rounded,
                                        size: 13,
                                        color: AppColors.primaryDark,
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          periodRange,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(9)),
                                  onTap: () => controller.stepNextDay(),
                                  child: const SizedBox(
                                    width: 30,
                                    height: 38,
                                    child: Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textSecondary),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 8),

                // Row 2: Period Presets Strip with smooth horizontal scroll and active highlighting
                Obx(() {
                  final active = controller.selectedPreset.value;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _presetPill(
                          title: 'Today',
                          icon: Icons.today_rounded,
                          isSelected: active == 'today',
                          onTap: () => controller.setPreset('today'),
                        ),
                        const SizedBox(width: 6),
                        _presetPill(
                          title: 'This Month',
                          icon: Icons.calendar_view_month_rounded,
                          isSelected: active == 'this_month',
                          onTap: () => controller.setPreset('this_month'),
                        ),
                        const SizedBox(width: 6),
                        _presetPill(
                          title: 'Last Month',
                          icon: Icons.history_rounded,
                          isSelected: active == 'last_month',
                          onTap: () => controller.setPreset('last_month'),
                        ),
                        const SizedBox(width: 6),
                        _presetPill(
                          title: 'Pick Month',
                          icon: Icons.edit_calendar_rounded,
                          isSelected: active == 'pick_month',
                          onTap: () => _showMonthPickerSheet(context, controller),
                        ),
                        const SizedBox(width: 6),
                        _presetPill(
                          title: 'Full Session',
                          icon: Icons.school_rounded,
                          isSelected: active == 'full_period',
                          onTap: () => controller.setPreset('full_period'),
                        ),
                        const SizedBox(width: 6),
                        _presetPill(
                          title: 'Custom',
                          icon: Icons.date_range_rounded,
                          isSelected: active == 'custom',
                          onTap: () => _pickCustomRange(context, controller),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          // 2. Official KPK Report Format Cards
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
              children: [
                // Top Highlight: Dedicated Statutory Forms & Certificates
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'STATUTORY FORMS & CERTIFICATES',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Material(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(10),
                              child: InkWell(
                                onTap: () => Get.to(() => const MonthlyGoshwaraView()),
                                borderRadius: BorderRadius.circular(10),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 34,
                                        height: 34,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0F5132),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.table_view_rounded, color: Colors.white, size: 18),
                                      ),
                                      const SizedBox(width: 8),
                                      const Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'ماہانہ گوشوارہ',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF0F5132)),
                                            ),
                                            Text(
                                              'Monthly Goshwara',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF0F5132)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Material(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(10),
                              child: InkWell(
                                onTap: () => Get.to(() => const SchoolLeavingCertificateView()),
                                borderRadius: BorderRadius.circular(10),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 34,
                                        height: 34,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF047857),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 18),
                                      ),
                                      const SizedBox(width: 8),
                                      const Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'سرٹیفکیٹ داخل خارج',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF047857)),
                                            ),
                                            Text(
                                              'Leaving Certificate (SLC)',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF047857)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                const Padding(
                  padding: EdgeInsets.only(left: 2, bottom: 8),
                  child: Text(
                    'SELECT OFFICIAL KPK REPORT FORMAT',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Obx(() => Column(
                      children: [
                        _reportCard(
                          controller,
                          type: ReportType.monthlyMatrix,
                          title: 'Monthly Attendance Matrix (گوشوارہ حاضری ماہانہ)',
                          subtitle: 'Official 28–31 day KPK matrix with //, /, A, L, S (Sun) & 8-column گوشوارہ',
                          icon: Icons.calendar_view_month_rounded,
                          accentColor: const Color(0xFF059669),
                          badge: 'STATUTORY',
                          badgeColor: const Color(0xFF047857),
                        ),
                        const SizedBox(height: 8),
                        _reportCard(
                          controller,
                          type: ReportType.classRegister,
                          title: 'Class Summary & History Register (رجسٹر حاضری)',
                          subtitle: 'Two-time sessions (2x), حاضری units, اوسط حاضری & signature blocks',
                          icon: Icons.assignment_rounded,
                          accentColor: const Color(0xFF4338CA),
                          badge: 'OFFICIAL',
                          badgeColor: const Color(0xFF4338CA),
                        ),
                        const SizedBox(height: 8),
                        _reportCard(
                          controller,
                          type: ReportType.dailySheet,
                          title: 'Daily Attendance Master Sheet (روزانہ حاضری)',
                          subtitle: 'Date-stamped single-day snapshot with arrival timings & remarks',
                          icon: Icons.fact_check_rounded,
                          accentColor: const Color(0xFFD97706),
                          badge: 'DAILY',
                          badgeColor: const Color(0xFFB45309),
                        ),
                        const SizedBox(height: 8),
                        _reportCard(
                          controller,
                          type: ReportType.individualStudent,
                          title: 'Individual Student Attendance Dossier',
                          subtitle: 'Complete student profile, term attendance %, leaves & parent record',
                          icon: Icons.badge_rounded,
                          accentColor: const Color(0xFF0D9488),
                          badge: 'DOSSIER',
                          badgeColor: const Color(0xFF0F766E),
                        ),
                        const SizedBox(height: 8),
                        _reportCard(
                          controller,
                          type: ReportType.monthlyGoshwara,
                          title: 'Monthly Performance Goshwara (ماہانہ گوشوارہ)',
                          subtitle: 'Official KPK statutory report: staff particulars, posts, facilities & PTC funds',
                          icon: Icons.table_view_rounded,
                          accentColor: const Color(0xFF0F5132),
                          badge: 'STATUTORY',
                          badgeColor: const Color(0xFF0F5132),
                        ),
                        const SizedBox(height: 8),
                        _reportCard(
                          controller,
                          type: ReportType.administrativeSummary,
                          title: 'School-Wide ASDEO Inspection Summary',
                          subtitle: 'Consolidated primary classes (Kachi–5th) summary for Head Teacher',
                          icon: Icons.domain_verification_rounded,
                          accentColor: const Color(0xFF7C3AED),
                          badge: 'ADMIN',
                          badgeColor: const Color(0xFF6D28D9),
                        ),
                      ],
                    )),
                const SizedBox(height: 14),

                // Conditional Student Selector for Individual Student Dossier
                Obx(() {
                  final rType = controller.selectedReportType.value;
                  if (rType != ReportType.individualStudent) {
                    return const SizedBox.shrink();
                  }
                  final students = attendanceCtrl.studentsList;
                  if (students.isEmpty) return const SizedBox.shrink();
                  final currentSel = controller.selectedStudent.value ?? students.first;

                  return Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary, width: 1.4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline_rounded, size: 18, color: AppColors.primaryDark),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<Student>(
                              isExpanded: true,
                              isDense: true,
                              value: students.contains(currentSel) ? currentSel : students.first,
                              items: students.map((s) {
                                return DropdownMenuItem(
                                  value: s,
                                  child: Text(
                                    'Roll ${s.rollNumber ?? "-"}: ${s.fullName} (${s.admissionNumber})',
                                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                                  ),
                                );
                              }).toList(),
                              onChanged: (st) {
                                if (st != null) controller.selectedStudent.value = st;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          // 3. Compact Sticky Bottom Action Bar (with Excel/CSV Export, PDF Preview & Print)
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: const Border(top: BorderSide(color: AppColors.border)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Obx(() {
                final isGenerating = controller.isGenerating.value;
                return Row(
                  children: [
                    Tooltip(
                      message: 'Export Excel / CSV for EMIS',
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF166534),
                            backgroundColor: const Color(0xFFF0FDF4),
                            side: const BorderSide(color: Color(0xFF86EFAC), width: 1.3),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.table_view_rounded, size: 17),
                          label: const Text(
                            'CSV',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                          ),
                          onPressed: isGenerating ? null : () => controller.exportCsv(context),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 4,
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryDark,
                            side: const BorderSide(color: AppColors.primaryDark, width: 1.4),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.visibility_outlined, size: 17),
                          label: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Preview PDF',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
                            ),
                          ),
                          onPressed: isGenerating ? null : () => controller.previewPdf(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 5,
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryDark,
                            foregroundColor: Colors.white,
                            elevation: 1,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: isGenerating
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Icon(Icons.picture_as_pdf_rounded, size: 17),
                          label: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              isGenerating ? 'Generating...' : 'Print / Export',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
                            ),
                          ),
                          onPressed: isGenerating ? null : () => controller.exportPdf(),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickCustomRange(BuildContext context, PdfReportsController controller) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(
        start: controller.startDate.value,
        end: controller.endDate.value.isBefore(controller.startDate.value)
            ? controller.startDate.value
            : controller.endDate.value,
      ),
    );
    if (picked != null) {
      controller.selectedPreset.value = 'custom';
      controller.startDate.value = picked.start;
      controller.endDate.value = picked.end;
      controller.refreshReportPeriodSummary();
    }
  }

  void _showMonthPickerSheet(BuildContext context, PdfReportsController controller) {
    int selectedYear = controller.startDate.value.year;
    final activeMonth = controller.startDate.value.month;
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheet) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Register Month',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded),
                        onPressed: () => setSheet(() => selectedYear--),
                      ),
                      Text(
                        '$selectedYear',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded),
                        onPressed: () => setSheet(() => selectedYear++),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 2.2,
                ),
                itemCount: 12,
                itemBuilder: (context, i) {
                  final m = i + 1;
                  final days = KpkMonthlySummary.daysInMonth(selectedYear, m);
                  final isCurrentSel = selectedYear == controller.startDate.value.year && m == activeMonth;
                  return InkWell(
                    onTap: () {
                      Navigator.pop(ctx);
                      controller.selectMonth(selectedYear, m);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isCurrentSel ? AppColors.primaryDark : AppColors.bgLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isCurrentSel ? AppColors.primaryDark : AppColors.border,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            monthNames[i],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isCurrentSel ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '$days Days',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: isCurrentSel ? const Color(0xFFA7F3D0) : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reportCard(
    PdfReportsController controller, {
    required ReportType type,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    String? badge,
    Color? badgeColor,
  }) {
    final isSelected = controller.selectedReportType.value == type;

    return InkWell(
      onTap: () => controller.selectedReportType.value = type,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.6 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.02),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isSelected ? accentColor : accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isSelected ? Colors.white : accentColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: isSelected ? accentColor : (badgeColor ?? accentColor),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? AppColors.textPrimary.withValues(alpha: 0.8) : AppColors.textSecondary,
                      height: 1.25,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.event_available_rounded, size: 12, color: accentColor),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Target: ${controller.periodFormattedRange}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.textMuted.withValues(alpha: 0.5),
                  width: 1.6,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _presetPill({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 11),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF047857) : AppColors.bgLight,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: isSelected ? const Color(0xFF047857) : AppColors.border,
            width: isSelected ? 1.4 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF047857).withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.check_circle_rounded : icon,
              size: 14,
              color: isSelected ? Colors.white : AppColors.primaryDark,
            ),
            const SizedBox(width: 5),
            Text(
              title,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
