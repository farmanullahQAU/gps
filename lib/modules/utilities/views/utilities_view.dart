import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/database_backup_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../admin/admin_controller.dart';
import '../../admin/views/admin_setup_view.dart';
import '../../attendance/attendance_controller.dart';
import '../../auth/auth_controller.dart';
import '../../qr_scanner/views/qr_scanner_view.dart';
import '../../students/views/students_list_view.dart';
import '../../sync/sync_controller.dart';
import '../../sync/views/sync_dashboard_view.dart';

/// Enterprise Administrative Utilities & Tools Hub
/// Houses secondary tools: Backup & Restore, Cloud Sync, WhatsApp Alerts,
/// QR Attendance Scanner, Gazetted Holiday Calendar, Approval Audits, and School Config.
class UtilitiesView extends StatelessWidget {
  const UtilitiesView({super.key});

  @override
  Widget build(BuildContext context) {
    final adminCtrl = Get.find<AdminController>();
    final authCtrl = Get.find<AuthController>();
    final syncCtrl = Get.isRegistered<SyncController>() ? Get.find<SyncController>() : null;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Obx(() {
        final user = authCtrl.currentUser.value;
        final isAdmin = user?.isAdmin ?? false;
        final pendingSync = syncCtrl?.pendingCount.value ?? 0;
        final pendingCorrections = adminCtrl.correctionRequests
            .where((r) => r.status == 'pending')
            .length;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            // Top Header Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, Color(0xFF0F5132)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDark.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.handyman_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'utilities'.tr,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'utilities_desc'.tr,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Category 1: DATA MANAGEMENT & SAFETY
            _sectionHeader('data_safety_title'.tr),
            const SizedBox(height: 8),
            _ToolCardGroup(
              children: [
                _ToolTile(
                  icon: Icons.backup_rounded,
                  iconColor: const Color(0xFF047857), // Forest Emerald
                  iconBg: const Color(0xFFECFDF5),
                  title: 'backup_restore'.tr,
                  subtitle: 'Export / import offline register snapshots (.sqlite)',
                  badge: 'Safety',
                  badgeColor: const Color(0xFFECFDF5),
                  badgeTextColor: const Color(0xFF047857),
                  onTap: () => DatabaseBackupService.instance.showBackupRestoreModal(
                    context,
                    db: adminCtrl.studentRepository.db,
                    schoolId: user?.schoolId,
                    onRestored: () async {
                      await adminCtrl.loadAllAdminData();
                      if (Get.isRegistered<AttendanceController>()) {
                        await Get.find<AttendanceController>().loadClasses();
                      }
                    },
                  ),
                ),
                const Divider(height: 1, indent: 64, color: AppColors.border),
                _ToolTile(
                  icon: Icons.cloud_sync_rounded,
                  iconColor: const Color(0xFF1D4ED8), // Royal Blue
                  iconBg: const Color(0xFFEFF6FF),
                  title: 'sync_status'.tr,
                  subtitle: 'cloud_sync_desc'.tr,
                  badge: pendingSync > 0 ? '$pendingSync Pending' : 'Synced',
                  badgeColor: pendingSync > 0 ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7),
                  badgeTextColor: pendingSync > 0 ? const Color(0xFF92400E) : const Color(0xFF166534),
                  onTap: () => Get.to(() => const SyncDashboardView()),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Category 2: SCANNING & ROLL CALL
            _sectionHeader('scanning_title'.tr),
            const SizedBox(height: 8),
            _ToolCardGroup(
              children: [
                _ToolTile(
                  icon: Icons.qr_code_scanner_rounded,
                  iconColor: const Color(0xFF7C3AED), // Violet
                  iconBg: const Color(0xFFF5F3FF),
                  title: 'qr_rollcall_scanner'.tr,
                  subtitle: 'qr_rollcall_desc'.tr,
                  badge: 'Camera',
                  badgeColor: const Color(0xFFF5F3FF),
                  badgeTextColor: const Color(0xFF7C3AED),
                  onTap: () => Get.to(() => const QrScannerView()),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Category 3: COMMUNICATION & ALERTS
            _sectionHeader('communication_title'.tr),
            const SizedBox(height: 8),
            _ToolCardGroup(
              children: [
                _ToolTile(
                  icon: Icons.chat_rounded,
                  iconColor: const Color(0xFF25D366), // WhatsApp Green
                  iconBg: const Color(0xFFE8F5E9),
                  title: 'whatsapp_alerts_title'.tr,
                  subtitle: 'whatsapp_alerts_desc'.tr,
                  badge: 'WhatsApp',
                  badgeColor: const Color(0xFFE8F5E9),
                  badgeTextColor: const Color(0xFF15803D),
                  onTap: () {
                    // Navigate directly to Students Directory filtered for quick parent WhatsApp contact
                    Get.to(() => const StudentsListView());
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Category 4: CALENDAR & GOVERNANCE
            _sectionHeader('calendar_approvals_title'.tr),
            const SizedBox(height: 8),
            _ToolCardGroup(
              children: [
                _ToolTile(
                  icon: Icons.event_available_rounded,
                  iconColor: const Color(0xFF0D9488), // Teal
                  iconBg: const Color(0xFFF0FDFA),
                  title: 'holidays_calendar'.tr,
                  subtitle: 'gazetted_holidays_desc'.tr,
                  badge: adminCtrl.holidays.isEmpty ? null : '${adminCtrl.holidays.length} Dates',
                  badgeColor: const Color(0xFFF0FDFA),
                  badgeTextColor: const Color(0xFF0D9488),
                  onTap: () async {
                    await adminCtrl.loadAllAdminData();
                    Get.to(() => const HolidaysManagementSubPage());
                  },
                ),
                if (isAdmin) ...[
                  const Divider(height: 1, indent: 64, color: AppColors.border),
                  _ToolTile(
                    icon: Icons.fact_check_rounded,
                    iconColor: const Color(0xFFD97706), // Amber
                    iconBg: const Color(0xFFFFFBEB),
                    title: 'approvals_audit_title'.tr,
                    subtitle: 'approvals_audit_desc'.tr,
                    badge: pendingCorrections > 0 ? '$pendingCorrections Pending' : 'Audited',
                    badgeColor: pendingCorrections > 0 ? const Color(0xFFFEE2E2) : const Color(0xFFF1F5F9),
                    badgeTextColor: pendingCorrections > 0 ? const Color(0xFFB91C1C) : const Color(0xFF475569),
                    onTap: () async {
                      await adminCtrl.loadAllAdminData();
                      Get.to(() => const ApprovalsAuditSubPage());
                    },
                  ),
                  const Divider(height: 1, indent: 64, color: AppColors.border),
                  _ToolTile(
                    icon: Icons.admin_panel_settings_rounded,
                    iconColor: const Color(0xFFB45309), // Burnished Amber
                    iconBg: const Color(0xFFFEF3C7),
                    title: 'school_governance_title'.tr,
                    subtitle: 'school_governance_desc'.tr,
                    badge: 'Admin',
                    badgeColor: const Color(0xFFFEF3C7),
                    badgeTextColor: const Color(0xFFB45309),
                    onTap: () async {
                      await adminCtrl.loadAllAdminData();
                      Get.to(() => const AdminSetupView());
                    },
                  ),
                ],
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _ToolCardGroup extends StatelessWidget {
  final List<Widget> children;
  const _ToolCardGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(children: children),
    );
  }
}

class _ToolTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String? badge;
  final Color? badgeColor;
  final Color? badgeTextColor;
  final VoidCallback onTap;

  const _ToolTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    this.badge,
    this.badgeColor,
    this.badgeTextColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
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
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: badgeColor ?? const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              badge!,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: badgeTextColor ?? AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ],
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
              const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
