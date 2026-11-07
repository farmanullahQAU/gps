import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/biometric_auth_service.dart';
import '../../../core/services/database_backup_service.dart';
import '../../../core/services/notification_service.dart';
import '../../admin/admin_controller.dart';
import '../../admin/views/admin_setup_view.dart';
import '../../attendance/attendance_controller.dart';
import '../../auth/auth_controller.dart';
import '../../auth/views/login_view.dart';
import '../../sync/sync_controller.dart';
import '../../sync/views/sync_dashboard_view.dart';
import '../../qr_scanner/qr_scanner_controller.dart';
import 'edit_profile_view.dart';

class SettingsView extends StatelessWidget {
  final bool showAppBar;
  const SettingsView({super.key, this.showAppBar = true});

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
          width: 58,
          height: 58,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, size: 34, color: AppColors.primaryDark),
        );
      } else {
        final path = avatarUrl.startsWith('/') ? 'https://myschool-api.pages.dev$avatarUrl' : avatarUrl;
        if (path.startsWith('http://') || path.startsWith('https://')) {
          return ClipOval(
            child: Image.network(
              path,
              width: 58,
              height: 58,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _initialAvatar(initial),
            ),
          );
        } else if (File(avatarUrl).existsSync()) {
          return ClipOval(
            child: Image.file(
              File(avatarUrl),
              width: 58,
              height: 58,
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
      width: 58,
      height: 58,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    final adminCtrl = Get.find<AdminController>();
    final syncCtrl = Get.find<SyncController>();
    final localeCtrl = Get.find<LocaleController>();
    final qrCtrl = Get.isRegistered<QrScannerController>() ? Get.find<QrScannerController>() : null;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: showAppBar
          ? AppBar(
              title: Text('settings'.tr, style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800)),
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              elevation: 0,
            )
          : null,
      body: Obx(() {
        final user = authCtrl.currentUser.value;
        final isAdmin = user?.isAdmin ?? false;
        final name = (user?.name ?? '').trim().isEmpty ? 'Faculty Member' : user!.name;
        final email = user?.email ?? '';
        final designation = user?.designation ?? (isAdmin ? 'School Administrator' : 'Faculty / Teacher');
        final initial = name.isEmpty ? 'T' : name[0].toUpperCase();
        final sch = adminCtrl.school.value;
        final pendingSync = syncCtrl.pendingCount.value;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            // 1. Logged-in User Profile Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildAvatar(user?.avatarUrl, initial),
                  const SizedBox(width: 14),
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
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: isAdmin ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(10),
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
                        const SizedBox(height: 3),
                        Text(
                          designation,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                        if (email.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      visualDensity: VisualDensity.compact,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Get.to(() => const EditProfileView());
                    },
                    child: const Text('Edit Profile', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 2. School Info Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.school_rounded, color: AppColors.primaryDark, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sch?.name ?? 'School Management System',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          sch?.code != null && sch!.code.isNotEmpty ? 'EMIS: ${sch.code}' : 'Institutional Portal',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 3. Application Preferences Group
            _sectionHeader('PREFERENCES & SYSTEM'),
            const SizedBox(height: 8),
            Container(
              decoration: _cardBox(),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.language_rounded, color: AppColors.primaryDark),
                    title: const Text('Language / زبان', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                    subtitle: Text(localeCtrl.isUrdu.value ? 'اردو (Urdu)' : 'English', style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                    trailing: Switch.adaptive(
                      value: localeCtrl.isUrdu.value,
                      activeTrackColor: AppColors.primary,
                      onChanged: (_) => localeCtrl.toggleLanguage(),
                    ),
                  ),
                  if (qrCtrl != null) ...[
                    const Divider(height: 1, indent: 56, color: AppColors.border),
                    Obx(() => ListTile(
                      leading: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primaryDark),
                      title: const Text('Auto-Scan Next Student', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                      subtitle: Text(
                        qrCtrl.autoScanNext.value
                            ? 'Auto-advancing: resumes scanning after 2s'
                            : 'Paused on scan (requires tapping "Next Student")',
                        style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                      ),
                      trailing: Switch.adaptive(
                        value: qrCtrl.autoScanNext.value,
                        activeTrackColor: AppColors.primary,
                        onChanged: (val) => qrCtrl.toggleAutoScanNext(val),
                      ),
                    )),
                  ],
                  const Divider(height: 1, indent: 56, color: AppColors.border),
                  Obx(() {
                    if (!authCtrl.isBiometricSupported.value) {
                      return const SizedBox.shrink();
                    }
                    final isEnabled = authCtrl.isBiometricEnabled.value;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.fingerprint_rounded, color: Color(0xFF0D9488)),
                          title: const Text('Biometric App Lock', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                          subtitle: Text(
                            isEnabled ? 'Active (Fingerprint / Face Unlock)' : 'Quick secure unlock on open',
                            style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                          ),
                          trailing: Switch.adaptive(
                            value: isEnabled,
                            activeTrackColor: AppColors.primary,
                            onChanged: (val) async {
                              if (val) {
                                final ok = await BiometricAuthService.authenticate(
                                  reason: 'Confirm biometrics to enable App Lock',
                                );
                                if (ok) {
                                  await BiometricAuthService.setBiometricEnabled(
                                    true,
                                    userId: user?.id,
                                    name: user?.name,
                                    role: user?.role,
                                  );
                                  await authCtrl.checkBiometricStatus();
                                  Get.snackbar('Biometric Lock Enabled', 'You can now unlock the app using Fingerprint / Face.', snackPosition: SnackPosition.BOTTOM);
                                }
                              } else {
                                await BiometricAuthService.setBiometricEnabled(false);
                                await authCtrl.checkBiometricStatus();
                                Get.snackbar('Biometric Lock Disabled', 'Biometric app lock is now off.', snackPosition: SnackPosition.BOTTOM);
                              }
                            },
                          ),
                        ),
                        const Divider(height: 1, indent: 56, color: AppColors.border),
                      ],
                    );
                  }),
                  ListTile(
                    leading: const Icon(Icons.cloud_sync_outlined, color: Color(0xFF2563EB)),
                    title: const Text('Cloud Sync & Outbox', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                    subtitle: Text(
                      pendingSync > 0 ? '$pendingSync pending mutation(s) queued' : 'Fully synced with cloud',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                    ),
                    trailing: pendingSync > 0
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(10)),
                            child: Text('$pendingSync', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF92400E))),
                          )
                        : const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                    onTap: () => Get.to(() => const SyncDashboardView()),
                  ),
                  const Divider(height: 1, indent: 56, color: AppColors.border),
                  ListTile(
                    leading: const Icon(Icons.backup_outlined, color: Color(0xFF047857)),
                    title: const Text('Offline Database Backup & Restore', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                    subtitle: const Text('Export or restore local school register snapshots', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
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
                  const Divider(height: 1, indent: 56, color: AppColors.border),
                  ListTile(
                    leading: const Icon(Icons.notifications_active_outlined, color: Color(0xFF7C3AED)),
                    title: const Text('Push Notifications (FCM)', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                    subtitle: const Text('Tap to view and copy device token', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                    trailing: const Icon(Icons.copy_rounded, size: 18, color: AppColors.textMuted),
                    onTap: () {
                      final token = NotificationService.instance.fcmToken;
                      if (token == null || token.isEmpty) {
                        Get.snackbar(
                          'Token Not Generated Yet',
                          'FCM token is being fetched from Google Play Services. Please ensure Internet is connected.',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        return;
                      }
                      Clipboard.setData(ClipboardData(text: token));
                      Get.defaultDialog(
                        title: 'Device Registration Token',
                        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'This token uniquely identifies your phone for Firebase push messages:',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: SelectableText(
                                token,
                                style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                              ),
                            ),
                          ],
                        ),
                        textConfirm: 'Copy Token',
                        confirmTextColor: Colors.white,
                        buttonColor: AppColors.primaryDark,
                        onConfirm: () {
                          Clipboard.setData(ClipboardData(text: token));
                          Get.back();
                          Get.snackbar(
                            'Copied to Clipboard',
                            'FCM token copied! You can paste it in Firebase Console.',
                            backgroundColor: const Color(0xFFDCFCE7),
                            colorText: const Color(0xFF166534),
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            if (isAdmin) ...[
              const SizedBox(height: 20),
              // 4. Administrator Governance Group
              _sectionHeader('ADMINISTRATION & GOVERNANCE'),
              const SizedBox(height: 8),
              Container(
                decoration: _cardBox(),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.admin_panel_settings_outlined, color: Color(0xFFB45309)),
                      title: const Text('School Admin Hub', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                      subtitle: const Text('Classes, teachers, calendar, bell times & audit', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                      onTap: () async {
                        await adminCtrl.loadAllAdminData();
                        Get.to(() => const AdminSetupView());
                      },
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // 5. Account Actions Group
            _sectionHeader('ACCOUNT'),
            const SizedBox(height: 8),
            Container(
              decoration: _cardBox(),
              child: ListTile(
                leading: const Icon(Icons.logout_rounded, color: AppColors.absent),
                title: const Text('Sign Out', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.absent)),
                subtitle: const Text('Log out of this device session', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                onTap: () async {
                  await authCtrl.logout();
                  Get.offAll(() => LoginView());
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.textSecondary,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  BoxDecoration _cardBox() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    );
  }
}
