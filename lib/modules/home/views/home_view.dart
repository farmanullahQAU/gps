import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/attendance_charts.dart';
import '../../../core/widgets/class_picker_sheet.dart';
import '../../admin/admin_controller.dart';
import '../../admin/views/admin_setup_view.dart';
import '../../attendance/attendance_controller.dart';
import '../../attendance/views/student_insights_view.dart';
import '../../auth/auth_controller.dart';
import '../../pdf_reports/views/kpk_register_summary_view.dart';
import '../../pdf_reports/views/school_leaving_certificate_view.dart';
import '../../students/views/students_list_view.dart';

// ---------------------------------------------------------------------------
// Design Tokens
// ---------------------------------------------------------------------------
const double _kRadius = 14;
const double _kGap = 12;
const Color _kInk = Color(0xFF0F172A);
const Color _kBrand = Color(0xFF14532D);

BoxDecoration _card({Color color = Colors.white}) => BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(_kRadius),
      border: Border.all(color: AppColors.border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );

/// Executive, Professional Home Dashboard
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final attCtrl = Get.find<AttendanceController>();

    return RefreshIndicator(
      color: AppColors.primaryDark,
      onRefresh: attCtrl.loadStudentsAndAttendance,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _GreetingHeader(),
            SizedBox(height: _kGap),
            _EmailVerificationBanner(),
            _TodayAttendanceCard(),
            SizedBox(height: 18),
            _SectionTitle('Institutional Management'),
            SizedBox(height: 10),
            _QuickAccessSection(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header: Profile Avatar, Designation, Date, and Role Badge
// ---------------------------------------------------------------------------
class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader();

  String get _salutation {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _buildAvatar(String? avatarUrl, String initial) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      if (avatarUrl.startsWith('preset_')) {
        Color bg = const Color(0xFFDCFCE7);
        IconData icon = Icons.face_rounded;
        if (avatarUrl.contains('female')) {
          bg = const Color(0xFFFCE7F3);
          icon = Icons.face_3_rounded;
        } else if (avatarUrl.contains('senior')) {
          bg = const Color(0xFFFEF3C7);
          icon = Icons.account_circle_rounded;
        } else if (avatarUrl.contains('scholar')) {
          bg = const Color(0xFFE0E7FF);
          icon = Icons.school_rounded;
        }
        return Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, size: 26, color: _kBrand),
        );
      } else {
        final path = avatarUrl.startsWith('/') ? 'https://myschool-api.pages.dev$avatarUrl' : avatarUrl;
        if (path.startsWith('http://') || path.startsWith('https://')) {
          return ClipOval(
            child: Image.network(
              path,
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _initialAvatar(initial),
            ),
          );
        } else if (File(avatarUrl).existsSync()) {
          return ClipOval(
            child: Image.file(
              File(avatarUrl),
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _initialAvatar(initial),
            ),
          );
        }
      }
    }
    return _initialAvatar(initial);
  }

  Widget _initialAvatar(String initial) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _kBrand,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: _kBrand.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    final today = DateFormat('EEE, d MMM yyyy').format(DateTime.now());

  return Obx(() {
      final user = authCtrl.currentUser.value;
      final isAdmin = user?.isAdmin ?? false;
      final name = user?.name ?? 'Teacher';
      final designation = user?.designation ?? (isAdmin ? 'School Administrator' : 'Faculty / Teacher');
      final initial = name.trim().isEmpty ? 'T' : name.trim()[0].toUpperCase();

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: _card(),
        child: Row(
          children: [
            _buildAvatar(user?.avatarUrl, initial),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _kInk,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: isAdmin ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isAdmin ? 'Administrator' : 'Faculty',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: isAdmin ? const Color(0xFF92400E) : const Color(0xFF166534),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    designation,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$_salutation • $today',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textMuted.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}


// ---------------------------------------------------------------------------
// Today's Attendance Overview Card (Clean, Executive & No Clunky Buttons)
// ---------------------------------------------------------------------------
class _TodayAttendanceCard extends StatelessWidget {
  const _TodayAttendanceCard();

  @override
  Widget build(BuildContext context) {
    final attCtrl = Get.find<AttendanceController>();
    final authCtrl = Get.find<AuthController>();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _card(),
      child: Obx(() {
        final present = attCtrl.presentCount;
        final absent = attCtrl.absentCount;
        final late = attCtrl.lateCount;
        final leave = attCtrl.leaveCount;
        final halfDay = attCtrl.halfDayCount;
        final unmarked = attCtrl.unmarkedCount;
        final cls = attCtrl.selectedClass.value?.name ?? 'Select class';
        final sec = attCtrl.selectedSection.value?.name;
        final fmName = attCtrl.currentClassFormMaster;
        final canTake = attCtrl.canTakeAttendanceForSelectedClass;
        final isAdmin = authCtrl.currentUser.value?.isAdmin ?? false;

        final holiday = attCtrl.activeHoliday.value;
        final (String? statusText, IconData? statusIcon, Color? statusFg, Color? statusBg) = holiday != null
            ? ('Holiday', Icons.event_busy_rounded, const Color(0xFF6B21A8), const Color(0xFFF3E8FF))
            : attCtrl.isSunday
                ? ('Sunday Off', Icons.event_busy_rounded, const Color(0xFF6B21A8), const Color(0xFFF3E8FF))
                : (null, null, null, null);

        final fmLine = isAdmin
            ? 'Form Master: $fmName'
            : canTake
                ? 'Form Master: You'
                : 'Form Master: $fmName • View only';

        final selectedLevel = attCtrl.selectedClass.value?.numericLevel;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seamless Integrated Class & Section Header
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => showClassPickerSheet(context, attCtrl),
                borderRadius: BorderRadius.circular(10),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _kBrand,
                        borderRadius: BorderRadius.circular(11),
                        boxShadow: [
                          BoxShadow(
                            color: _kBrand.withValues(alpha: 0.18),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        selectedLevel == 0 ? 'K' : '${selectedLevel ?? 1}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
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
                                  sec == null ? cls : '$cls • $sec',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: _kInk,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 20,
                                color: AppColors.textMuted,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                canTake ? Icons.verified_user_rounded : Icons.shield_outlined,
                                size: 12,
                                color: canTake ? _kBrand : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  fmLine,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: canTake ? _kBrand : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (statusText != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 11, color: statusFg),
                            const SizedBox(width: 3),
                            Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: statusFg,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 14),

            // Middle Attendance Cockpit: Donut Chart + Statistics Cards
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AnimatedAttendanceDonutChart(
                    present: present,
                    absent: absent,
                    lateCount: late,
                    leave: leave,
                    halfDay: halfDay,
                    unmarked: unmarked,
                    size: 84,
                    strokeWidth: 8.5,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _statTile(
                              label: 'Present',
                              value: present,
                              icon: Icons.check_circle_rounded,
                              color: const Color(0xFF16A34A),
                              bgColor: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            _statTile(
                              label: 'Absent',
                              value: absent,
                              icon: Icons.cancel_rounded,
                              color: const Color(0xFFDC2626),
                              bgColor: Colors.white,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _statTile(
                              label: 'Late',
                              value: late,
                              icon: Icons.alarm_rounded,
                              color: const Color(0xFFD97706),
                              bgColor: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            _statTile(
                              label: 'Leave',
                              value: leave + halfDay,
                              icon: Icons.event_available_rounded,
                              color: const Color(0xFF0284C7),
                              bgColor: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Two-Time Sessions (1st & 2nd Hazri) + Monthly Summary strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF1F5F9), Color(0xFFF8FAFC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _kpkMiniMetric('1st Time', '${attCtrl.firstTimePresentCount}', Icons.wb_sunny_rounded, const Color(0xFFD97706)),
                  _kpkMiniDivider(),
                  _kpkMiniMetric('2nd Time', '${attCtrl.secondTimePresentCount}', Icons.wb_twilight_rounded, const Color(0xFF0284C7)),
                  _kpkMiniDivider(),
                  _kpkMiniMetric(
                    'Month Avg',
                    (attCtrl.currentMonthKpkSummary.value?.averageAttendance ?? 0).toStringAsFixed(1),
                    Icons.trending_up_rounded,
                    _kBrand,
                    highlight: true,
                  ),
                  _kpkMiniDivider(),
                  _kpkMiniMetric(
                    'Month %',
                    '${(attCtrl.currentMonthKpkSummary.value?.percentageAttendance ?? 0).toStringAsFixed(1)}%',
                    Icons.pie_chart_rounded,
                    _kBrand,
                    highlight: true,
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _kpkMiniDivider() => Container(
        width: 1,
        height: 24,
        color: const Color(0xFFCBD5E1),
      );

  Widget _kpkMiniMetric(String label, String value, IconData icon, Color color, {bool highlight = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 3.5),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: highlight ? _kBrand : _kInk,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _statTile({
    required String label,
    required int value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 12.5, color: color),
            ),
            const SizedBox(width: 5.5),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                '$value',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: _kInk,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Institutional Management Quick Access (4 High-Visibility Grid Cards)
// ---------------------------------------------------------------------------
class _QuickAccessSection extends StatelessWidget {
  const _QuickAccessSection();

  @override
  Widget build(BuildContext context) {
    final adminCtrl = Get.find<AdminController>();
    final attCtrl = Get.find<AttendanceController>();
    final authCtrl = Get.find<AuthController>();

    return Obx(() {
      final isAdmin = authCtrl.currentUser.value?.isAdmin ?? false;
      final pendingCorrections = adminCtrl.correctionRequests
          .where((r) => r.status == 'pending')
          .length;

      return Column(
        children: [
          if (isAdmin && pendingCorrections > 0) ...[
            _PendingBanner(
              count: pendingCorrections,
              onTap: () async {
                await adminCtrl.loadAllAdminData();
                Get.to(() => const ApprovalsAuditSubPage());
              },
            ),
            const SizedBox(height: 12),
          ],
          // Row 1: Students & Student Analytics (High-Visibility)
          Row(
            children: [
              Expanded(
                child: _EnterpriseCard(
                  icon: Icons.school_rounded,
                  accentColor: const Color(0xFF1D4ED8), // Royal Sapphire Blue
                  title: 'Students',
                  subtitle: 'Directory & Admissions',
                  count: '${attCtrl.schoolTotalActiveStudents.value}',
                  onTap: () => Get.to(() => const StudentsListView()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _EnterpriseCard(
                  icon: Icons.query_stats_rounded,
                  accentColor: const Color(0xFFD97706), // Warm Amber / Gold
                  title: 'Student Analytics',
                  subtitle: 'Insights & Attendance Trends',
                  count: 'Insights',
                  onTap: () => Get.to(() => const StudentInsightsView()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Row 2: Classes & Academic Calendar
          Row(
            children: [
              Expanded(
                child: _EnterpriseCard(
                  icon: Icons.meeting_room_rounded,
                  accentColor: const Color(0xFF0D9488), // Deep Teal
                  title: 'Primary Classes',
                  subtitle: 'Sections & Form Masters',
                  count: '${attCtrl.classesList.length}',
                  onTap: () async {
                    await adminCtrl.loadAllAdminData();
                    Get.to(() => const ClassesManagementSubPage());
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _EnterpriseCard(
                  icon: Icons.event_available_rounded,
                  accentColor: const Color(0xFF059669), // Emerald
                  title: 'School Calendar',
                  subtitle: 'Holidays & Vacations',
                  count: adminCtrl.holidays.isEmpty ? null : '${adminCtrl.holidays.length} Dates',
                  onTap: () async {
                    await adminCtrl.loadAllAdminData();
                    Get.to(() => const HolidaysManagementSubPage());
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Row 3: Staff Directory & Monthly Goshwara
          Row(
            children: [
              Expanded(
                child: _EnterpriseCard(
                  icon: Icons.badge_rounded,
                  accentColor: const Color(0xFF7C3AED), // Academic Violet
                  title: 'Faculty & Staff',
                  subtitle: 'Teachers & Designations',
                  count: adminCtrl.teachers.isEmpty ? null : '${adminCtrl.teachers.length} Staff',
                  onTap: () async {
                    await adminCtrl.loadAllAdminData();
                    Get.to(() => const TeachersManagementSubPage());
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _EnterpriseCard(
                  icon: Icons.menu_book_rounded,
                  accentColor: const Color(0xFF0F5132), // Statutory Forest Green
                  title: 'Monthly Goshwara',
                  subtitle: 'گوشوارہ حاضری ماہانہ',
                  count: 'Statutory',
                  onTap: () => Get.to(() => const KpkMonthlyRegisterSummaryView()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Row 4: School Leaving Certificate (SLC) & School Administration
          if (isAdmin)
            Row(
              children: [
                Expanded(
                  child: _EnterpriseCard(
                    icon: Icons.workspace_premium_rounded,
                    accentColor: const Color(0xFF047857),
                    title: 'Leaving Certificate',
                    subtitle: 'سرٹیفکیٹ داخل خارج',
                    count: 'SLC',
                    onTap: () => Get.to(() => const SchoolLeavingCertificateView()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _EnterpriseCard(
                    icon: Icons.admin_panel_settings_rounded,
                    accentColor: const Color(0xFFB45309), // Burnished Amber
                    title: 'School Admin',
                    subtitle: 'Timings & Governance',
                    count: 'Admin',
                    onTap: () async {
                      await adminCtrl.loadAllAdminData();
                      Get.to(() => const AdminSetupView());
                    },
                  ),
                ),
              ],
            )
          else
            _EnterpriseCard(
              icon: Icons.workspace_premium_rounded,
              accentColor: const Color(0xFF047857),
              title: 'School Leaving Certificate',
              subtitle: 'سرٹیفکیٹ داخل خارج و چال چلن',
              count: 'SLC',
              onTap: () => Get.to(() => const SchoolLeavingCertificateView()),
            ),
        ],
      );
    });
  }
}

class _EnterpriseCard extends StatelessWidget {
  final IconData icon;
  final Color accentColor;
  final String title;
  final String subtitle;
  final String? count;
  final VoidCallback onTap;

  const _EnterpriseCard({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: accentColor.withValues(alpha: 0.1),
        highlightColor: accentColor.withValues(alpha: 0.04),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.20),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accentColor.withValues(alpha: 0.16),
                          accentColor.withValues(alpha: 0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.25),
                        width: 1.2,
                      ),
                    ),
                    child: Icon(icon, size: 21, color: accentColor),
                  ),
                  if (count != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.20),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        count!,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: accentColor,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: _kInk,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2.5),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: accentColor.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingBanner extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _PendingBanner({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFFBEB),
      borderRadius: BorderRadius.circular(_kRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_kRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_kRadius),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE68A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.rule_rounded, size: 18, color: Color(0xFF92400E)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      count == 1 ? '1 Attendance Correction Request' : '$count Attendance Correction Requests',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF78350F),
                      ),
                    ),
                    const Text(
                      'Requires Head Teacher review & approval',
                      style: TextStyle(fontSize: 10.5, color: Color(0xFF92400E)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFFB45309)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w800,
          color: _kInk,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

/// Discreet, professional non-blocking Email Verification Notice Banner
class _EmailVerificationBanner extends StatelessWidget {
  const _EmailVerificationBanner();

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();

    return Obx(() {
      final user = authCtrl.currentUser.value;
      final email = user?.email.trim() ?? '';
      if (user == null || email.isEmpty || authCtrl.isEmailVerified || !authCtrl.showVerificationBanner.value) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.only(bottom: _kGap),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(_kRadius),
          border: Border.all(color: const Color(0xFFBFDBFE)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: const BoxDecoration(
                color: Color(0xFFDBEAFE),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mark_email_unread_outlined, size: 20, color: Color(0xFF1D4ED8)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Verify your email address',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Verify $email to enable secure one-click recovery.',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF2563EB)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D4ED8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                visualDensity: VisualDensity.compact,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                showGeneralDialog(
                  context: context,
                  barrierDismissible: true,
                  barrierLabel: 'Verify Email',
                  barrierColor: Colors.black.withValues(alpha: 0.45),
                  transitionDuration: const Duration(milliseconds: 280),
                  pageBuilder: (ctx, anim1, anim2) => _EmailVerificationDialog(
                    authCtrl: authCtrl,
                    email: user.email,
                  ),
                  transitionBuilder: (ctx, anim1, anim2, child) {
                    final curve = CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic);
                    return AnimatedBuilder(
                      animation: curve,
                      builder: (context, _) {
                        final blurVal = 10.0 * curve.value;
                        return BackdropFilter(
                          filter: ui.ImageFilter.blur(
                            sigmaX: blurVal > 0 ? blurVal : 0.001,
                            sigmaY: blurVal > 0 ? blurVal : 0.001,
                          ),
                          child: FadeTransition(
                            opacity: curve,
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.90, end: 1.0).animate(curve),
                              child: child,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              child: const Text('Verify Now'),
            ),
            const SizedBox(width: 2),
            IconButton(
              icon: const Icon(Icons.close, size: 16, color: Color(0xFF6B7280)),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
              onPressed: authCtrl.dismissVerificationBanner,
              tooltip: 'Verify later',
            ),
          ],
        ),
      );
    });
  }
}

/// Modal Dialog allowing users to verify their email address via OTP at their convenience
class _EmailVerificationDialog extends StatefulWidget {
  final AuthController authCtrl;
  final String email;

  const _EmailVerificationDialog({required this.authCtrl, required this.email});

  @override
  State<_EmailVerificationDialog> createState() => _EmailVerificationDialogState();
}

class _EmailVerificationDialogState extends State<_EmailVerificationDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _otpCtrl = TextEditingController();
  bool _isLoading = false;

  Timer? _timer;
  int _countdown = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _dispatchVerificationEmail();
    _startTimer();
  }

  Future<void> _dispatchVerificationEmail() async {
    try {
      await widget.authCtrl.sendVerificationEmail();
    } catch (_) {}
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _countdown = 60;
      _canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown > 1) {
        if (mounted) setState(() => _countdown--);
      } else {
        _timer?.cancel();
        if (mounted) setState(() => _canResend = true);
      }
    });
  }

  Future<void> _handleResend() async {
    _startTimer();
    try {
      final res = await widget.authCtrl.sendVerificationEmail();
      final msg = res['message']?.toString() ?? 'A fresh 6-digit verification code has been dispatched to ${widget.email}.';

      Get.snackbar(
        'Code Sent',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEFF6FF),
        colorText: const Color(0xFF1E40AF),
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      Get.snackbar(
        'Notice',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white.withValues(alpha: 0.94),
      surfaceTintColor: Colors.transparent,
      elevation: 24,
      shadowColor: Colors.black.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.85),
          width: 1.5,
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mark_email_read_outlined, color: Color(0xFF1D4ED8), size: 22),
          ),
          const SizedBox(width: 10),
          const Text('Verify Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'A 6-digit confirmation code was sent to:\n${widget.email}\n\nPlease enter the code below to verify your email address.',
                style: TextStyle(fontSize: 12.5, height: 1.45, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 18),

              TextFormField(
                controller: _otpCtrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 8),
                decoration: InputDecoration(
                  labelText: '6-Digit Verification Code',
                  hintText: '• • • • • •',
                  counterText: '',
                  prefixIcon: const Icon(Icons.security_rounded, size: 20, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  isDense: true,
                ),
                validator: (v) {
                  if (v == null || v.trim().length != 6) {
                    return 'Please enter the complete 6-digit code';
                  }
                  return null;
                },
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _canResend ? _handleResend : null,
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                  child: Text(
                    _canResend ? 'Resend Code' : 'Resend in ${_countdown}s',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: _canResend ? AppColors.primary : Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Verify Later'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: _isLoading
              ? null
              : () async {
                  if (!_formKey.currentState!.validate()) return;
                  setState(() => _isLoading = true);
                  final ok = await widget.authCtrl.verifyEmailWithOtp(
                    _otpCtrl.text,
                  );
                  setState(() => _isLoading = false);
                  if (ok && context.mounted) {
                    Navigator.pop(context);
                  }
                },
          child: _isLoading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Confirm Verification'),
        ),
      ],
    );
  }
}

