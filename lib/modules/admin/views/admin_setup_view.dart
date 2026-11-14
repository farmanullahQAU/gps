import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/class_picker_sheet.dart';
import '../admin_controller.dart';
import 'register_teacher_view.dart';
import 'teacher_details_view.dart';
import '../../attendance/attendance_controller.dart';
import '../../auth/auth_controller.dart';
import '../../sync/sync_controller.dart';
import '../../sync/views/sync_dashboard_view.dart';
import '../../saas/views/district_super_admin_view.dart';

/// Professional School Settings Hub:
/// Replaces the crowded 4-tab inline-form screen with a clean Settings Hub
/// where each administrative domain opens its own focused sub-page.
class AdminSetupView extends StatelessWidget {
  const AdminSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    final adminCtrl = Get.find<AdminController>();
    final attCtrl = Get.find<AttendanceController>();
    final syncCtrl = Get.find<SyncController>();
    final authCtrl = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: Text(
          'school_setup_title'.tr,
          style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800),
        ),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        final user = authCtrl.currentUser.value;
        final isAdmin = user?.isAdmin ?? false;

        // If a non-admin user navigates to this tab, show an executive restricted notice
        if (!isAdmin) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFBBF24), width: 1.5),
                    ),
                    child: const Icon(Icons.admin_panel_settings_outlined, size: 34, color: Color(0xFFB45309)),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Administrator Access Required',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This section is reserved for the School Head Teacher and administrative in-charge. All daily teaching and attendance tools are available on your Home Dashboard.',
                    style: TextStyle(fontSize: 13, height: 1.5, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final sch = adminCtrl.school.value;
        final set = adminCtrl.settings.value;
        final classesCount = attCtrl.classesList.length;
        final teachersCount = adminCtrl.teachers.length;
        final holidaysCount = adminCtrl.holidays.length;
        final pendingCorrections = adminCtrl.correctionRequests
            .where((r) => r.status == 'pending')
            .length;
        final auditCount = adminCtrl.auditLogs.length;
        final pendingSync = syncCtrl.pendingCount.value;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            // 1. School Summary Banner
            _SchoolOverviewCard(
              name: sch?.name ?? 'School Administration',
              emisCode: sch?.code ?? 'EMIS-PORTAL',
              schoolType: set?.schoolType ?? 'GPS',
              district: set?.district ?? 'Peshawar',
              tehsil: set?.tehsil ?? 'City Peshawar',
              circleOffice: set?.circleOffice ?? 'ASDEO Circle City-I',
              climateZone: set?.climateZone ?? 'summer_zone',
              openingTime: set?.openingTime ?? '08:00',
              closingTime: set?.closingTime ?? '13:30',
              cutoffTime: set?.lateCutoffTime ?? '08:15',
              headTeacher: set?.headTeacherName ?? (user?.name ?? 'Head Teacher'),
              onEdit: () => Get.to(() => const SchoolProfileSubPage()),
            ),
            const SizedBox(height: 22),

            // 2. Academic & Staff Configuration Group
            const _HubSectionTitle('ACADEMIC & STAFF CONFIGURATION'),
            const SizedBox(height: 8),
            Container(
              decoration: _groupCardDecoration(),
              child: Column(
                children: [
                  _SettingsHubTile(
                    icon: Icons.domain_rounded,
                    color: AppColors.primaryDark,
                    title: 'School Profile & Bell Timings',
                    subtitle: 'EMIS code, office details, and official school hours',
                    badgeText: set?.schoolType ?? 'GPS',
                    onTap: () => Get.to(() => const SchoolProfileSubPage()),
                  ),
                  const Divider(height: 1, indent: 64, color: AppColors.border),
                  _SettingsHubTile(
                    icon: Icons.class_outlined,
                    color: const Color(0xFF0284C7),
                    title: 'Primary Classes & Form Masters',
                    subtitle: 'Manage classes and assign class in-charges',
                    badgeText: '$classesCount Classes',
                    onTap: () => Get.to(() => const ClassesManagementSubPage()),
                  ),
                  const Divider(height: 1, indent: 64, color: AppColors.border),
                  _SettingsHubTile(
                    icon: Icons.badge_outlined,
                    color: const Color(0xFF7C3AED),
                    title: 'Teachers & Staff Directory',
                    subtitle: 'Head Teacher and faculty profile accounts',
                    badgeText: '$teachersCount Staff',
                    onTap: () => Get.to(() => const TeachersManagementSubPage()),
                  ),
                  const Divider(height: 1, indent: 64, color: AppColors.border),
                  _SettingsHubTile(
                    icon: Icons.event_note_rounded,
                    color: const Color(0xFFD97706),
                    title: 'Gazetted Holidays & Calendar',
                    subtitle: 'Scheduled non-instructional school holidays',
                    badgeText: '$holidaysCount Dates',
                    onTap: () => Get.to(() => const HolidaysManagementSubPage()),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 3. Governance, Audit & Cloud Sync Group
            const _HubSectionTitle('GOVERNANCE & SYSTEM AUDIT'),
            const SizedBox(height: 8),
            Container(
              decoration: _groupCardDecoration(),
              child: Column(
                children: [
                  _SettingsHubTile(
                    icon: Icons.verified_user_outlined,
                    color: const Color(0xFF0F766E),
                    title: 'Correction Approvals & Audit Trail',
                    subtitle: 'Review edit requests and system activity logs',
                    badgeText: pendingCorrections > 0
                        ? '$pendingCorrections Pending'
                        : '$auditCount Logs',
                    highlightBadge: pendingCorrections > 0,
                    onTap: () => Get.to(() => const ApprovalsAuditSubPage()),
                  ),
                  const Divider(height: 1, indent: 64, color: AppColors.border),
                  _SettingsHubTile(
                    icon: Icons.cloud_sync_outlined,
                    color: const Color(0xFF2563EB),
                    title: 'Cloud Synchronization',
                    subtitle: 'Offline queue status and server sync health',
                    badgeText: pendingSync > 0 ? '$pendingSync Queued' : 'Synced',
                    highlightBadge: pendingSync > 0,
                    onTap: () => Get.to(() => const SyncDashboardView()),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 4. Multi-Tenant District Oversight Group
            const _HubSectionTitle('DISTRICT OVERSIGHT'),
            const SizedBox(height: 8),
            Container(
              decoration: _groupCardDecoration(),
              child: Column(
                children: [
                  _SettingsHubTile(
                    icon: Icons.account_tree_rounded,
                    color: const Color(0xFF4338CA),
                    title: 'District School Network',
                    subtitle: 'Multi-school portal and administrative oversight',
                    badgeText: 'District',
                    onTap: () => Get.to(() => const DistrictSuperAdminView()),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Hub Overview Card & Shared Widgets
// ---------------------------------------------------------------------------
class _SchoolOverviewCard extends StatelessWidget {
  final String name;
  final String emisCode;
  final String schoolType;
  final String district;
  final String tehsil;
  final String circleOffice;
  final String climateZone;
  final String openingTime;
  final String closingTime;
  final String cutoffTime;
  final String headTeacher;
  final VoidCallback onEdit;

  const _SchoolOverviewCard({
    required this.name,
    required this.emisCode,
    required this.schoolType,
    required this.district,
    required this.tehsil,
    required this.circleOffice,
    required this.climateZone,
    required this.openingTime,
    required this.closingTime,
    required this.cutoffTime,
    required this.headTeacher,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isWinter = climateZone == 'winter_zone';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B3B24), Color(0xFF14532D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B3B24).withValues(alpha: 0.16),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$emisCode · $schoolType',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.amberAccent,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isWinter ? 'Winter Zone' : 'Summer Zone',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_outlined, size: 13, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Edit',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              fontSize: 17.5,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$district · $tehsil · $circleOffice',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF86EFAC)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Bell: $openingTime – $closingTime  •  Late Cutoff: $cutoffTime',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HubSectionTitle extends StatelessWidget {
  final String text;
  const _HubSectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.7,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _SettingsHubTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String badgeText;
  final bool highlightBadge;
  final VoidCallback onTap;

  const _SettingsHubTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.onTap,
    this.highlightBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 21, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
              decoration: BoxDecoration(
                color: highlightBadge
                    ? const Color(0xFFFEF3C7)
                    : color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: highlightBadge ? const Color(0xFF92400E) : color,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

BoxDecoration _groupCardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: AppColors.border),
  );
}

// ===========================================================================
// SUB-PAGE 1: KPK School Profile & Bell Timings
// ===========================================================================
class SchoolProfileSubPage extends StatefulWidget {
  const SchoolProfileSubPage({super.key});

  @override
  State<SchoolProfileSubPage> createState() => _SchoolProfileSubPageState();
}

class _SchoolProfileSubPageState extends State<SchoolProfileSubPage> {
  final AdminController _controller = Get.find<AdminController>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _codeCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _districtCtrl;
  late final TextEditingController _tehsilCtrl;
  late final TextEditingController _circleCtrl;
  late final TextEditingController _openCtrl;
  late final TextEditingController _closeCtrl;
  late final TextEditingController _cutoffCtrl;
  late final TextEditingController _htCtrl;
  late String _schoolType;
  late String _climateZone;

  @override
  void initState() {
    super.initState();
    final sch = _controller.school.value;
    final set = _controller.settings.value;

    _nameCtrl = TextEditingController(text: sch?.name ?? 'Govt Primary School Gulbahar No. 1 Peshawar');
    _codeCtrl = TextEditingController(text: sch?.code ?? 'EMIS-12405');
    _addressCtrl = TextEditingController(text: sch?.address ?? 'Gulbahar Colony, Peshawar, KPK');
    _phoneCtrl = TextEditingController(text: sch?.phone ?? '+92912214455');
    _districtCtrl = TextEditingController(text: set?.district ?? 'Peshawar');
    _tehsilCtrl = TextEditingController(text: set?.tehsil ?? 'City Peshawar');
    _circleCtrl = TextEditingController(text: set?.circleOffice ?? 'ASDEO Circle City-I');
    _openCtrl = TextEditingController(text: set?.openingTime ?? '08:00');
    _closeCtrl = TextEditingController(text: set?.closingTime ?? '13:30');
    _cutoffCtrl = TextEditingController(text: set?.lateCutoffTime ?? '08:15');
    _htCtrl = TextEditingController(text: set?.headTeacherName ?? 'Muhammad Yousaf Khan (HT)');
    _schoolType = set?.schoolType ?? 'GPS';
    _climateZone = set?.climateZone ?? 'summer_zone';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _districtCtrl.dispose();
    _tehsilCtrl.dispose();
    _circleCtrl.dispose();
    _openCtrl.dispose();
    _closeCtrl.dispose();
    _cutoffCtrl.dispose();
    _htCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime(TextEditingController target) async {
    final parts = target.text.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts.firstOrNull ?? '8') ?? 8,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      final hh = picked.hour.toString().padLeft(2, '0');
      final mm = picked.minute.toString().padLeft(2, '0');
      setState(() => target.text = '$hh:$mm');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text(
          'School Profile & Timings',
          style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800),
        ),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                // 1. School Category Selector
                _formSectionCard(
                  title: 'School Category & Classification',
                  icon: Icons.category_outlined,
                  children: [
                    Row(
                      children: [
                        _categoryOption(
                          type: 'GPS',
                          title: 'GPS',
                          subtitle: 'Boys Primary',
                          icon: Icons.boy_rounded,
                          color: const Color(0xFF0284C7),
                        ),
                        const SizedBox(width: 8),
                        _categoryOption(
                          type: 'GGPS',
                          title: 'GGPS',
                          subtitle: 'Girls Primary',
                          icon: Icons.girl_rounded,
                          color: const Color(0xFFDB2777),
                        ),
                        const SizedBox(width: 8),
                        _categoryOption(
                          type: 'GCMPS',
                          title: 'GCMPS',
                          subtitle: 'Model Primary',
                          icon: Icons.stars_rounded,
                          color: const Color(0xFF0D9488),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 2. Official KPK E&SED Identity
                _formSectionCard(
                  title: 'Official KPK E&SED Identity',
                  icon: Icons.school_outlined,
                  children: [
                    TextField(
                      controller: _nameCtrl,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                      decoration: const InputDecoration(
                        labelText: 'Official School Name',
                        hintText: 'e.g. Govt Primary School Gulbahar No. 1 Peshawar',
                        prefixIcon: Icon(Icons.account_balance_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _codeCtrl,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        labelText: 'KPK EMIS Code',
                        hintText: 'e.g. 12405',
                        prefixIcon: const Icon(Icons.tag_rounded, size: 20),
                        suffixIcon: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF166534)),
                              SizedBox(width: 4),
                              Text('Verified', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF166534))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 3. Bell Timings & Late Arrival (Interactive Cards)
                _formSectionCard(
                  title: 'Bell Timings & Late Arrival Rules',
                  icon: Icons.schedule_rounded,
                  children: [
                    Row(
                      children: [
                        _timingCard(
                          title: 'Opening Bell',
                          timeText: _openCtrl.text,
                          icon: Icons.wb_sunny_outlined,
                          color: const Color(0xFF166534),
                          onTap: () => _pickTime(_openCtrl),
                        ),
                        const SizedBox(width: 8),
                        _timingCard(
                          title: 'Late Cutoff',
                          timeText: _cutoffCtrl.text,
                          icon: Icons.timer_outlined,
                          color: const Color(0xFFB45309),
                          onTap: () => _pickTime(_cutoffCtrl),
                        ),
                        const SizedBox(width: 8),
                        _timingCard(
                          title: 'Closing Bell',
                          timeText: _closeCtrl.text,
                          icon: Icons.nightlight_outlined,
                          color: const Color(0xFF475569),
                          onTap: () => _pickTime(_closeCtrl),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF92400E)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Students arriving after ${_cutoffCtrl.text} are marked as Late.',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF78350F)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 4. KPK Seasonal Climate Zone
                _formSectionCard(
                  title: 'KP E&SED Seasonal Climate Zone (Malakand & KPK)',
                  icon: Icons.thermostat_outlined,
                  children: [
                    Row(
                      children: [
                        _climateOption(
                          zoneKey: 'summer_zone',
                          title: 'Summer Zone',
                          desc: 'Malakand (Batkhela/Dargai), Lower Dir, Buner, Peshawar, Mardan, Swabi (Winter: Jan 1–15 • Summer: Jun 1–Aug 31)',
                          icon: Icons.wb_sunny_rounded,
                          color: const Color(0xFFD97706),
                        ),
                        const SizedBox(width: 8),
                        _climateOption(
                          zoneKey: 'winter_zone',
                          title: 'Winter Zone',
                          desc: 'Swat, Upper Dir, Shangla, Chitral, Abbottabad, Mansehra (Winter: Dec 23–Feb 28 • Summer: Jul 1–31)',
                          icon: Icons.ac_unit_rounded,
                          color: const Color(0xFF0284C7),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 5. District & Circle Office Jurisdiction
                _formSectionCard(
                  title: 'District & Circle Office Jurisdiction',
                  icon: Icons.location_on_outlined,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _districtCtrl,
                            decoration: const InputDecoration(
                              labelText: 'District',
                              prefixIcon: Icon(Icons.location_city_outlined, size: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _tehsilCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Tehsil',
                              prefixIcon: Icon(Icons.place_outlined, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _circleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'ASDEO / SDEO Circle Office',
                        hintText: 'e.g. ASDEO Circle City-I',
                        prefixIcon: Icon(Icons.apartment_rounded, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 6. Official Signatures & School Contact
                _formSectionCard(
                  title: 'Official Head Teacher Stamp & Contact',
                  icon: Icons.verified_outlined,
                  children: [
                    TextField(
                      controller: _htCtrl,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                      decoration: const InputDecoration(
                        labelText: 'Head Teacher / Incharge Name',
                        hintText: 'For official KPK Monthly Register and SLC stamps',
                        prefixIcon: Icon(Icons.badge_outlined, size: 19),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'School Landline / Official Mobile',
                        prefixIcon: Icon(Icons.phone_outlined, size: 19),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _addressCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Physical & Postal Address',
                        prefixIcon: Icon(Icons.map_outlined, size: 19),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Sticky Bottom Save Bar
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(top: BorderSide(color: AppColors.border)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                label: const Text(
                  'Save School Profile Configuration',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
                onPressed: () async {
                  await _controller.saveSchoolSetup(
                    name: _nameCtrl.text.trim(),
                    code: _codeCtrl.text.trim(),
                    address: _addressCtrl.text.trim(),
                    phone: _phoneCtrl.text.trim(),
                    schoolType: _schoolType,
                    district: _districtCtrl.text.trim(),
                    tehsil: _tehsilCtrl.text.trim(),
                    circleOffice: _circleCtrl.text.trim(),
                    climateZone: _climateZone,
                    openingTime: _openCtrl.text.trim(),
                    closingTime: _closeCtrl.text.trim(),
                    lateCutoffTime: _cutoffCtrl.text.trim(),
                    headTeacherName: _htCtrl.text.trim(),
                  );
                  Get.snackbar(
                    'Profile Updated',
                    'School configuration and bell timings saved successfully.',
                    backgroundColor: const Color(0xFFDCFCE7),
                    colorText: const Color(0xFF166534),
                    snackPosition: SnackPosition.TOP,
                  );
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryOption({
    required String type,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _schoolType == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _schoolType = type),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.1) : AppColors.bgLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 24, color: isSelected ? color : AppColors.textSecondary),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? color : AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? color : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timingCard({
    required String title,
    required String timeText,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(height: 5),
              Text(
                timeText.isEmpty ? '--:--' : timeText,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _climateOption({
    required String zoneKey,
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _climateZone == zoneKey;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _climateZone = zoneKey),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.08) : AppColors.bgLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: isSelected ? color : AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? color : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 9.5, color: AppColors.textSecondary, height: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _groupCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primaryDark),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

// ===========================================================================
// SUB-PAGE 2: Primary Classes & Form Masters Management
// ===========================================================================
class ClassesManagementSubPage extends StatelessWidget {
  const ClassesManagementSubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final attCtrl = Get.find<AttendanceController>();
    final adminCtrl = Get.find<AdminController>();
    final authCtrl = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text(
          'Primary Classes & Form Masters',
          style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800),
        ),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Import Classes CSV',
            icon: const Icon(Icons.upload_file_rounded),
            onPressed: () => _showAdminCsvImportSheet(
              context: context,
              title: 'Import Classes & Sections (CSV)',
              formatHint: 'Class Name, Numeric Level, Section Name\nExample:\nClass Kachi, 0, Section A\nClass 1st, 1, Section A',
              hintText: 'Class Kachi, 0, Section A\nClass 1st, 1, Section A',
              onImport: (csv) => adminCtrl.importClassesFromCsv(csv),
            ),
          ),
        ],
      ),
      body: Obx(() {
        final isAdmin = authCtrl.currentUser.value?.isAdmin ?? false;
        final classes = attCtrl.classesList;
        final activeClassId = attCtrl.selectedClass.value?.id;
        final totalStudents = attCtrl.schoolTotalActiveStudents.value;
        final assignedCount = classes.where((c) => attCtrl.classFormMasterIdMap.containsKey(c.id)).length;

        return Column(
          children: [
            // Executive KPI summary strip
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2563EB),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.school_rounded, size: 12, color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${classes.length} Classes',
                                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900, color: Color(0xFF1E3A8A)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '$totalStudents Total Enrolled Students',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2563EB)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD97706),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.verified_user_rounded, size: 12, color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$assignedCount / ${classes.length} Assigned',
                                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900, color: Color(0xFF92400E)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'Form Master Assigned',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFB45309)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: classes.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (ctx, i) {
                  final c = classes[i];
                  final isCurrent = c.id == activeClassId;
                  final enrolled = attCtrl.classEnrollmentMap[c.id] ?? 0;
                  final fmName = attCtrl.classFormMasterNameMap[c.id];
                  final hasFm = fmName != null && fmName.trim().isNotEmpty && fmName != 'Unassigned';

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isCurrent ? AppColors.primary : AppColors.border,
                        width: isCurrent ? 1.8 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isCurrent
                              ? AppColors.primary.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isCurrent
                                        ? [AppColors.primaryDark, AppColors.primary]
                                        : [const Color(0xFF0F172A), const Color(0xFF334155)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(13),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isCurrent ? AppColors.primaryDark : const Color(0xFF0F172A))
                                          .withValues(alpha: 0.20),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  c.numericLevel == 0 ? 'K' : '${c.numericLevel}',
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
                                    Text(
                                      c.name,
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: AppColors.border),
                                          ),
                                          child: Text(
                                            '$enrolled Enrolled',
                                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFECFDF5),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: const Color(0xFFA7F3D0)),
                                          ),
                                          child: Text(
                                            'Grade ${c.numericLevel}',
                                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF065F46)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (isCurrent)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_circle_rounded, size: 12, color: AppColors.primaryDark),
                                      SizedBox(width: 4),
                                      Text(
                                        'ACTIVE',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.primaryDark,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    visualDensity: VisualDensity.compact,
                                    side: const BorderSide(color: AppColors.border),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () => attCtrl.switchClassById(c.id),
                                  child: const Text('Set Active', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Form Master Assignment Bar
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                            decoration: BoxDecoration(
                              color: hasFm ? const Color(0xFFF8FAFC) : const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(11),
                              border: Border.all(
                                color: hasFm ? AppColors.border : const Color(0xFFFDE68A),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: hasFm ? AppColors.primaryLight : const Color(0xFFFEF3C7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    hasFm ? Icons.person_rounded : Icons.person_off_rounded,
                                    size: 15,
                                    color: hasFm ? AppColors.primaryDark : const Color(0xFFD97706),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'FORM MASTER',
                                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 0.5),
                                      ),
                                      Text(
                                        hasFm ? fmName : 'No teacher assigned yet',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w800,
                                          color: hasFm ? AppColors.textPrimary : const Color(0xFFB45309),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isAdmin)
                                  InkWell(
                                    onTap: () => showAssignFormMasterSheet(context, c),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryLight,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            hasFm ? Icons.edit_rounded : Icons.add_rounded,
                                            size: 13,
                                            color: AppColors.primaryDark,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            hasFm ? 'Change' : 'Assign',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.primaryDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (isAdmin)
              Container(
                padding: EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  MediaQuery.of(context).padding.bottom + 12,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 1,
                    ),
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: const Text(
                      'Add New Class & Assign Form Master',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                    onPressed: () => _showAddClassSheet(context, adminCtrl, attCtrl),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  void _showAddClassSheet(
    BuildContext context,
    AdminController adminCtrl,
    AttendanceController attCtrl,
  ) {
    final classNameCtrl = TextEditingController();
    final secNameCtrl = TextEditingController(text: 'Section A');
    String? selectedTeacherId = adminCtrl.teachers.firstOrNull?.id;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create New Class & Section',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              const Text(
                'Add a new grade/section and assign its Form Master (Class Teacher).',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: classNameCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Class Name (e.g. Class 5th - B / Class 6th)',
                  prefixIcon: Icon(Icons.class_outlined, size: 19),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: secNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Section Name',
                  prefixIcon: Icon(Icons.grid_view_rounded, size: 19),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: selectedTeacherId,
                decoration: const InputDecoration(
                  labelText: 'Form Master (Class Teacher)',
                  prefixIcon: Icon(Icons.person_pin_outlined, size: 19),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Unassigned'),
                  ),
                  ...adminCtrl.teachers.map(
                    (t) => DropdownMenuItem<String?>(
                      value: t.id,
                      child: Text(t.name),
                    ),
                  ),
                ],
                onChanged: (v) => setModalState(() => selectedTeacherId = v),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (classNameCtrl.text.trim().isEmpty) return;
                    Navigator.pop(ctx);
                    await adminCtrl.addClassSection(
                      className: classNameCtrl.text.trim(),
                      numericLevel: attCtrl.classesList.length,
                      sectionName: secNameCtrl.text.trim().isEmpty
                          ? 'Section A'
                          : secNameCtrl.text.trim(),
                      teacherId: selectedTeacherId,
                    );
                  },
                  child: const Text(
                    'Create Class & Assign Form Master',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// SUB-PAGE 3: Teachers & PST Staff Management
// ===========================================================================
class TeachersManagementSubPage extends StatelessWidget {
  const TeachersManagementSubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final adminCtrl = Get.find<AdminController>();
    final attCtrl = Get.find<AttendanceController>();
    final authCtrl = Get.find<AuthController>();
    final isAdmin = authCtrl.currentUser.value?.isAdmin ?? false;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text(
          'School Faculty & Staff (اسٹاف)',
          style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800),
        ),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Import Staff CSV',
            icon: const Icon(Icons.upload_file_rounded),
            onPressed: () => _showAdminCsvImportSheet(
              context: context,
              title: 'Import Faculty & Staff (CSV)',
              formatHint: 'Full Name, Email, Phone, Role, Designation, CNIC, PIN\nExample:\nAli Khan, ali@gps.edu.pk, 03001234567, teacher, PST, 17301-1234567-1, 1234',
              hintText: 'Ali Khan, ali@gps.edu.pk, 03001234567, teacher, PST, 17301-1234567-1, 1234',
              onImport: (csv) => adminCtrl.importStaffFromCsv(csv),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final staff = adminCtrl.teachers;
              if (staff.isEmpty) {
                return const Center(
                  child: Text('No teaching or support staff registered yet.', style: TextStyle(color: AppColors.textSecondary)),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: staff.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) {
                  final u = staff[i];
                  final isHT = u.role == 'admin';
                  final designation = u.designation ?? (isHT ? 'Head Teacher' : 'Teacher');

                  // Find assigned class name
                  String? assignedClassName;
                  for (final entry in attCtrl.classFormMasterIdMap.entries) {
                    if (entry.value == u.id) {
                      final cls = attCtrl.classesList.firstWhereOrNull((c) => c.id == entry.key);
                      assignedClassName = cls?.name;
                      break;
                    }
                  }

                  final isSupport = designation.contains('Class IV') ||
                      designation.contains('Naib Qasid') ||
                      designation.contains('Chowkidar') ||
                      designation.contains('Mali') ||
                      designation.contains('Sweeper');

                  return Container(
                    decoration: _groupCardDecoration(),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      leading: _buildTeacherAvatar(u),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              u.name,
                              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: isHT
                                  ? const Color(0xFFFEF3C7)
                                  : isSupport
                                      ? const Color(0xFFF3E8FF)
                                      : AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isHT
                                  ? 'ADMIN'
                                  : isSupport
                                      ? 'SUPPORT'
                                      : 'TEACHING',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: isHT
                                    ? const Color(0xFF92400E)
                                    : isSupport
                                        ? const Color(0xFF6B21A8)
                                        : AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          Text(
                            designation,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(
                                assignedClassName != null ? Icons.verified_rounded : Icons.radio_button_unchecked_rounded,
                                size: 13,
                                color: assignedClassName != null ? const Color(0xFF166534) : AppColors.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  assignedClassName != null
                                      ? 'Form Master: $assignedClassName'
                                      : 'No Class Assigned',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: assignedClassName != null ? FontWeight.w700 : FontWeight.w500,
                                    color: assignedClassName != null ? const Color(0xFF166534) : AppColors.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded, size: 22, color: AppColors.textSecondary),
                      onTap: () => Get.to(() => TeacherDetailsView(teacher: u)),
                    ),
                  );
                },
              );
            }),
          ),
          if (isAdmin)
            Container(
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                MediaQuery.of(context).padding.bottom + 12,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
                  label: const Text(
                    'Register Staff Member (اسٹاف اندراج)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                  onPressed: () => Get.to(() => const RegisterTeacherView()),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTeacherAvatar(User u) {
    final avatar = u.avatarUrl;
    if (avatar != null && avatar.isNotEmpty) {
      if (avatar.startsWith('preset_')) {
        Color bg = const Color(0xFFDCFCE7);
        IconData ic = Icons.face_rounded;
        if (avatar.contains('female')) {
          bg = const Color(0xFFFCE7F3);
          ic = Icons.face_3_rounded;
        } else if (avatar.contains('senior')) {
          bg = const Color(0xFFFEF3C7);
          ic = Icons.account_circle_rounded;
        } else if (avatar.contains('scholar')) {
          bg = const Color(0xFFE0E7FF);
          ic = Icons.school_rounded;
        }
        return Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(ic, color: AppColors.primaryDark, size: 26),
        );
      } else if (File(avatar).existsSync()) {
        return ClipOval(
          child: Image.file(
            File(avatar),
            width: 44,
            height: 44,
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) => _fallbackAvatar(u),
          ),
        );
      }
    }
    return _fallbackAvatar(u);
  }

  Widget _fallbackAvatar(User u) {
    final isHT = u.role == 'admin';
    return CircleAvatar(
      radius: 22,
      backgroundColor: isHT ? Colors.amber.withValues(alpha: 0.2) : AppColors.primaryLight,
      child: Text(
        u.name.isNotEmpty ? u.name[0].toUpperCase() : 'T',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: isHT ? Colors.amber.shade900 : AppColors.primaryDark,
        ),
      ),
    );
  }
}

// ===========================================================================
// SUB-PAGE 4: Gazetted Holidays & Calendar Management (KP E&SED & Malakand)
// ===========================================================================
class HolidaysManagementSubPage extends StatelessWidget {
  const HolidaysManagementSubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final adminCtrl = Get.find<AdminController>();
    final authCtrl = Get.find<AuthController>();
    final isAdmin = authCtrl.currentUser.value?.isAdmin ?? false;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text(
          'School Calendar & Holidays',
          style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800),
        ),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        actions: [
          if (isAdmin)
            IconButton(
              tooltip: 'Sync Official Gazetted Holidays',
              icon: const Icon(Icons.sync_rounded),
              onPressed: () => adminCtrl.syncOfficialKpkGazettedHolidays(),
            ),
        ],
      ),
      body: Column(
        children: [
          // Institutional Notification Presets Banner (Admin only)
          if (isAdmin)
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.verified_outlined, size: 15, color: AppColors.primaryDark),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Gazetted Calendar & Break Presets',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _presetChip(
                          icon: Icons.event_available_rounded,
                          label: 'Sync 2026 Gazetted Holidays (15d)',
                          color: AppColors.primaryDark,
                          onTap: () => adminCtrl.syncOfficialKpkGazettedHolidays(),
                        ),
                        const SizedBox(width: 8),
                        _presetChip(
                          icon: Icons.wb_sunny_outlined,
                          label: 'Winter Vacation (Jan 1–15)',
                          color: const Color(0xFFD97706),
                          onTap: () => adminCtrl.addHolidayRange(
                            start: DateTime(2026, 1, 1),
                            end: DateTime(2026, 1, 15),
                            description: 'Winter Vacation',
                          ),
                        ),
                        const SizedBox(width: 8),
                        _presetChip(
                          icon: Icons.ac_unit_rounded,
                          label: 'Summer Vacation (Jul 1–31)',
                          color: const Color(0xFF0284C7),
                          onTap: () => adminCtrl.addHolidayRange(
                            start: DateTime(2026, 7, 1),
                            end: DateTime(2026, 7, 31),
                            description: 'Summer Vacation',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (isAdmin) const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: Obx(() {
              final holidays = adminCtrl.holidays;
              if (holidays.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      isAdmin
                          ? 'No gazetted holidays configured yet. Tap "Sync 2026 Gazetted Holidays" above or add dates below.'
                          : 'No holidays scheduled yet in the academic calendar.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: holidays.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) {
                  final h = holidays[i];
                  final parsed = DateTime.tryParse(h.date);
                  final formattedDate = parsed != null
                      ? DateFormat('EEE, dd MMM yyyy').format(parsed)
                      : h.date;

                  return Container(
                    decoration: _groupCardDecoration(),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      leading: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.event_busy_rounded, color: Color(0xFFD97706)),
                      ),
                      title: Text(
                        h.description,
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(
                        '$formattedDate (${h.date})  •  Excluded from Working Days',
                        style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                      ),
                      trailing: isAdmin
                          ? IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.absent),
                              tooltip: 'Remove Holiday',
                              onPressed: () => adminCtrl.removeHoliday(h.id),
                            )
                          : null,
                    ),
                  );
                },
              );
            }),
          ),
          if (isAdmin)
            Container(
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                MediaQuery.of(context).padding.bottom + 12,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryDark,
                          side: const BorderSide(color: AppColors.primaryDark, width: 1.2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.date_range_rounded, size: 18),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Add Vacation Range',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                          ),
                        ),
                        onPressed: () => _showAddHolidayRangeSheet(context, adminCtrl),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Add Single Holiday',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                          ),
                        ),
                        onPressed: () => _showAddHolidaySheet(context, adminCtrl),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _presetChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: color),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddHolidaySheet(BuildContext context, AdminController adminCtrl) {
    final descCtrl = TextEditingController();
    DateTime pickedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Non-Instructional Holiday',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              const Text(
                'Students will not be marked absent on gazetted holidays.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Holiday Title (e.g. Eid-ul-Fitr / DEO Notification)',
                  prefixIcon: Icon(Icons.celebration_outlined, size: 19),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final p = await showDatePicker(
                    context: context,
                    initialDate: pickedDate,
                    firstDate: DateTime(2025),
                    lastDate: DateTime(2030),
                  );
                  if (p != null) setModalState(() => pickedDate = p);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.bgLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primaryDark),
                      const SizedBox(width: 10),
                      const Text(
                        'Holiday Date:',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat('EEE, dd MMM yyyy').format(pickedDate),
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (descCtrl.text.trim().isEmpty) return;
                    Navigator.pop(ctx);
                    await adminCtrl.addHoliday(
                      DateFormat('yyyy-MM-dd').format(pickedDate),
                      descCtrl.text.trim(),
                    );
                  },
                  child: const Text(
                    'Save Holiday to Calendar',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddHolidayRangeSheet(BuildContext context, AdminController adminCtrl) {
    final descCtrl = TextEditingController(text: 'KP E&SED Vacation / Closure');
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime(startDate.year, startDate.month, startDate.day + 4);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Multi-Day Vacation / Closure Range',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              const Text(
                'Automatically adds all non-Sunday dates in the range (Winter/Summer Break, Eid, or DEO/DC Malakand closure).',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Vacation / Notification Title',
                  prefixIcon: Icon(Icons.date_range_rounded, size: 19),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2025),
                    lastDate: DateTime(2030),
                    initialDateRange: DateTimeRange(start: startDate, end: endDate),
                  );
                  if (picked != null) {
                    setModalState(() {
                      startDate = picked.start;
                      endDate = picked.end;
                    });
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.bgLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded, size: 18, color: AppColors.primaryDark),
                      const SizedBox(width: 10),
                      const Text(
                        'Range:',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const Spacer(),
                      Text(
                        '${DateFormat('dd MMM yyyy').format(startDate)} – ${DateFormat('dd MMM yyyy').format(endDate)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (descCtrl.text.trim().isEmpty) return;
                    Navigator.pop(ctx);
                    await adminCtrl.addHolidayRange(
                      start: startDate,
                      end: endDate,
                      description: descCtrl.text.trim(),
                    );
                  },
                  child: const Text(
                    'Add Vacation Range to Calendar',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// SUB-PAGE 5: Correction Approvals & Tamper-Evident Audit Trail
// ===========================================================================
class ApprovalsAuditSubPage extends StatefulWidget {
  const ApprovalsAuditSubPage({super.key});

  @override
  State<ApprovalsAuditSubPage> createState() => _ApprovalsAuditSubPageState();
}

class _ApprovalsAuditSubPageState extends State<ApprovalsAuditSubPage> {
  int _selectedSegment = 0; // 0 = Correction Requests, 1 = Audit Trail

  @override
  Widget build(BuildContext context) {
    final adminCtrl = Get.find<AdminController>();
    final authCtrl = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text(
          'Approvals & Audit Trail',
          style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800),
        ),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        final requests = adminCtrl.correctionRequests;
        final logs = adminCtrl.auditLogs;
        final isAdmin = authCtrl.currentUser.value?.isAdmin ?? false;

        return Column(
          children: [
            // Top Segmented Switcher
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: _segmentPill(
                      index: 0,
                      label: 'Correction Requests (${requests.length})',
                      icon: Icons.rule_rounded,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _segmentPill(
                      index: 1,
                      label: 'Audit Trail (${logs.length})',
                      icon: Icons.history_edu_rounded,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: _selectedSegment == 0
                  ? _buildRequestsList(requests, isAdmin, adminCtrl)
                  : _buildAuditLogsList(logs),
            ),
          ],
        );
      }),
    );
  }

  Widget _segmentPill({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final selected = _selectedSegment == index;
    return InkWell(
      onTap: () => setState(() => _selectedSegment = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryDark : AppColors.bgLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primaryDark : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsList(
    List<dynamic> requests,
    bool isAdmin,
    AdminController controller,
  ) {
    if (requests.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No correction requests submitted. Edits to locked attendance registers appear here for Head Teacher review.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        final r = requests[i];
        final isPending = r.status == 'pending';
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: _groupCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${r.studentName}  •  ${r.date}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isPending
                          ? const Color(0xFFFEF3C7)
                          : r.status == 'approved'
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      r.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isPending
                            ? const Color(0xFF92400E)
                            : r.status == 'approved'
                                ? const Color(0xFF166534)
                                : const Color(0xFF991B1B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Change: ${r.oldStatus.toUpperCase()} → ${r.proposedStatus.toUpperCase()}',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Reason: ${r.reason} (Requested by ${r.requestedByName})',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              if (isPending && isAdmin) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.absent,
                          side: const BorderSide(color: AppColors.absent),
                        ),
                        icon: const Icon(Icons.close_rounded, size: 17),
                        label: const Text('Reject'),
                        onPressed: () => controller.decideCorrectionRequest(r, 'rejected'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.present,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.check_rounded, size: 17),
                        label: const Text('Approve'),
                        onPressed: () => controller.decideCorrectionRequest(r, 'approved'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildAuditLogsList(List<dynamic> logs) {
    if (logs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No attendance audit logs recorded yet.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: logs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) {
        final l = logs[i];
        final dt = DateFormat('dd MMM yyyy, hh:mm a')
            .format(DateTime.fromMillisecondsSinceEpoch(l.createdAt));
        return Container(
          decoration: _groupCardDecoration(),
          child: ListTile(
            dense: true,
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.history_edu_rounded, size: 19, color: AppColors.primaryDark),
            ),
            title: Text(
              '${(l.oldStatus ?? "none").toUpperCase()} → ${l.newStatus.toUpperCase()}  (${l.attendanceRecordId})',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
            ),
            subtitle: Text(
              'Reason: ${l.reason}\nBy ${l.changedByUserId}  •  $dt',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ),
        );
      },
    );
  }
}

void _showAdminCsvImportSheet({
  required BuildContext context,
  required String title,
  required String formatHint,
  required String hintText,
  required Future<int> Function(String csv) onImport,
}) {
  final csvCtrl = TextEditingController();
  String? selectedFileName;
  bool isImporting = false;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (context, setModalState) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(context).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Upload a .csv file from your device or paste rows below.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.folder_open_rounded, size: 18),
                  label: Text(selectedFileName ?? 'Choose .CSV File'),
                  onPressed: isImporting
                      ? null
                      : () async {
                          final picked = await FilePicker.pickFile(
                            type: FileType.custom,
                            allowedExtensions: ['csv', 'txt'],
                          );
                          if (picked != null && picked.path != null) {
                            final file = File(picked.path!);
                            final content = await file.readAsString();
                            setModalState(() {
                              selectedFileName = picked.name;
                              csvCtrl.text = content;
                            });
                          }
                        },
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.bgLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    formatHint,
                    style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: csvCtrl,
                  maxLines: 6,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                  decoration: InputDecoration(
                    hintText: hintText,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: isImporting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check_circle_outline_rounded, size: 18),
                    label: Text(
                      isImporting ? 'Importing...' : 'Import CSV Rows',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    onPressed: isImporting
                        ? null
                        : () async {
                            final raw = csvCtrl.text.trim();
                            if (raw.isEmpty) {
                              Get.snackbar('Input Required', 'Please select a CSV file or paste rows first.');
                              return;
                            }
                            setModalState(() => isImporting = true);
                            try {
                              await onImport(raw);
                              if (ctx.mounted) Navigator.pop(ctx);
                            } finally {
                              if (ctx.mounted) setModalState(() => isImporting = false);
                            }
                          },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
