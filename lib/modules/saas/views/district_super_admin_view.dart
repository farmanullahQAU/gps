// lib/modules/saas/views/district_super_admin_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../saas_controller.dart';

class DistrictSuperAdminView extends StatefulWidget {
  const DistrictSuperAdminView({super.key});

  @override
  State<DistrictSuperAdminView> createState() => _DistrictSuperAdminViewState();
}

class _DistrictSuperAdminViewState extends State<DistrictSuperAdminView> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final ctrl = Get.find<SaasController>();
    ctrl.loadPlatformOverview();
    ctrl.loadAllTenants();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SaasController>();

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('District & Platform Oversight', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              controller.loadPlatformOverview();
              controller.loadAllTenants();
            },
            tooltip: 'Refresh Platform Intelligence',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.allSchools.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final overview = controller.platformOverview.value;
        final schools = controller.allSchools.where((s) {
          if (_searchQuery.isEmpty) return true;
          final q = _searchQuery.toLowerCase();
          return s.name.toLowerCase().contains(q) ||
              s.code.toLowerCase().contains(q) ||
              s.district.toLowerCase().contains(q);
        }).toList();

        return RefreshIndicator(
          onRefresh: () async {
            await controller.loadPlatformOverview();
            await controller.loadAllTenants();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Banner
                _buildHeaderBanner(),

                const SizedBox(height: 18),

                // Platform KPI Metrics (2x2 Grid)
                if (overview != null) _buildKpiGrid(overview),

                const SizedBox(height: 22),

                // District Breakdown Chips
                if (overview != null && overview.districtBreakdown.isNotEmpty) ...[
                  const Text(
                    'KPK District Distribution',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: overview.districtBreakdown.map((d) {
                      return Chip(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: AppColors.border),
                        avatar: const CircleAvatar(
                          backgroundColor: Color(0xFFDCFCE7),
                          child: Icon(Icons.location_city_rounded, size: 13, color: Color(0xFF166534)),
                        ),
                        label: Text(
                          '${d['district']}: ${d['school_count']} Schools',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 22),
                ],

                // School Directory Header & Search Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'All Enrolled Schools (Tenants)',
                      style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    Text(
                      '${schools.length} Schools',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _searchQuery = v.trim()),
                  decoration: InputDecoration(
                    hintText: 'Search by School Name, EMIS, or District...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 14),

                // Schools List
                if (schools.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                    child: const Center(
                      child: Text('No schools matching your search query.', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  )
                else
                  ...schools.map((school) => _buildSchoolCard(context, controller, school)),

                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.public_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'SaaS Multi-Tenant Architecture',
                style: TextStyle(color: Color(0xFFC7D2FE), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'District & Super-Admin Console',
            style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Live analytics across all schools in Khyber Pakhtunkhwa. Tap any school to switch active tenant inspection.',
            style: TextStyle(color: Color(0xFFE0E7FF), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiGrid(dynamic overview) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _kpiItem(
          label: 'Total Schools',
          value: '${overview.totalSchools}',
          icon: Icons.account_balance_rounded,
          color: const Color(0xFF2563EB),
          subtext: 'Active SaaS Tenants',
        ),
        _kpiItem(
          label: 'Total Students',
          value: '${overview.totalStudents}',
          icon: Icons.groups_rounded,
          color: const Color(0xFF16A34A),
          subtext: 'Enrolled in System',
        ),
        _kpiItem(
          label: 'Staff / Faculty',
          value: '${overview.totalStaff}',
          icon: Icons.badge_rounded,
          color: const Color(0xFF7C3AED),
          subtext: 'Teachers & Incharges',
        ),
        _kpiItem(
          label: 'Attendance Rate',
          value: '${overview.todayPlatformAttendanceRate}%',
          icon: Icons.pie_chart_rounded,
          color: const Color(0xFFD97706),
          subtext: 'Marked Across KPK',
        ),
      ],
    );
  }

  Widget _kpiItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required String subtext,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 2),
          Text(subtext, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildSchoolCard(BuildContext context, SaasController controller, dynamic school) {
    Color statusBg;
    Color statusFg;
    String statusLabel;

    if (school.isPending) {
      statusBg = const Color(0xFFFEF3C7);
      statusFg = const Color(0xFFB45309);
      statusLabel = 'PENDING APPROVAL';
    } else if (school.isSuspended) {
      statusBg = const Color(0xFFFEE2E2);
      statusFg = const Color(0xFFB91C1C);
      statusLabel = 'SUSPENDED';
    } else if (school.isRejected) {
      statusBg = const Color(0xFFF3F4F6);
      statusFg = const Color(0xFF4B5563);
      statusLabel = 'REJECTED';
    } else {
      statusBg = const Color(0xFFDCFCE7);
      statusFg = const Color(0xFF15803D);
      statusLabel = 'APPROVED';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: school.isPending ? const Color(0xFFFBBF24) : AppColors.border,
          width: school.isPending ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: school.isPending ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.school_rounded,
                  color: school.isPending ? const Color(0xFFB45309) : AppColors.primaryDark,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      school.name,
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${school.code} • ${school.district}, ${school.tehsil}',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusFg.withValues(alpha: 0.2)),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: statusFg, letterSpacing: 0.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.groups_rounded, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${school.studentCount} Students',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.badge_rounded, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${school.staffCount} Staff',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                ],
              ),
              if (school.isPending) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        side: const BorderSide(color: Color(0xFFFCA5A5)),
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _confirmRejectSchool(context, controller, school),
                      child: const Text('Reject', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 6),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _confirmApproveSchool(context, controller, school),
                      icon: const Icon(Icons.check_circle_rounded, size: 14),
                      label: const Text('Approve', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ] else ...[
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryDark,
                    side: const BorderSide(color: AppColors.primary, width: 1.2),
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _confirmSwitchSchool(context, controller, school),
                  icon: const Icon(Icons.swap_horiz_rounded, size: 14),
                  label: const Text('Inspect School', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _confirmApproveSchool(BuildContext context, SaasController controller, dynamic school) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A)),
            SizedBox(width: 10),
            Text('Approve School?'),
          ],
        ),
        content: Text(
          'Approve "${school.name}" (${school.code}) for active operation? Staff and administrators will be granted instant login access.',
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              await controller.approveSchool(school.id);
            },
            child: const Text('Confirm Approval'),
          ),
        ],
      ),
    );
  }

  void _confirmRejectSchool(BuildContext context, SaasController controller, dynamic school) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.cancel_rounded, color: Color(0xFFDC2626)),
            SizedBox(width: 10),
            Text('Reject Registration?'),
          ],
        ),
        content: Text(
          'Reject registration request for "${school.name}" (${school.code})?',
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              await controller.rejectSchool(school.id);
            },
            child: const Text('Reject School'),
          ),
        ],
      ),
    );
  }

  void _confirmSwitchSchool(BuildContext context, SaasController controller, dynamic school) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.swap_horiz_rounded, color: AppColors.primary),
            SizedBox(width: 10),
            Text('Switch Active Tenant?'),
          ],
        ),
        content: Text(
          'Switch your active session to "${school.name}" (${school.code}) for administrative oversight?',
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              await controller.switchSchoolTenant(school);
              Get.back();
            },
            child: const Text('Confirm Switch'),
          ),
        ],
      ),
    );
  }
}
