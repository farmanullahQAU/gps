import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/theme/app_theme.dart';
import '../../admin/admin_controller.dart';
import '../../admin/views/admin_setup_view.dart';
import '../../attendance/views/attendance_view.dart';
import '../../auth/auth_controller.dart';
import '../../auth/views/login_view.dart';
import '../../pdf_reports/views/pdf_reports_view.dart';
import '../../settings/views/settings_view.dart';
import '../../students/views/students_list_view.dart';
import '../../sync/sync_controller.dart';
import '../../sync/views/sync_dashboard_view.dart';
import 'home_view.dart';

class MainNavigationController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  void changeTab(int index) {
    selectedIndex.value = index.clamp(0, 2);
  }
}

/// Primary 3-tab application shell:
/// Tab 0: Home (Executive Dashboard & Quick Actions)
/// Tab 1: Reports (Attendance Register, Gazette & Monthly Analytics)
/// Tab 2: Settings (Logged-in Profile, School Admin, Preferences & Sign Out)
/// Attendance Register is accessed directly via the Home Floating Action Button or quick actions.
class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({super.key});

  @override
  Widget build(BuildContext context) {
    final navCtrl = Get.put(MainNavigationController());
    final adminCtrl = Get.find<AdminController>();

    return Obx(() {
      final pages = const <Widget>[
        HomeView(),
        PdfReportsView(),
        SettingsView(showAppBar: false),
      ];

      final destinations = <NavigationDestination>[
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home_rounded, color: AppColors.primaryDark),
          label: 'home'.tr,
        ),
        NavigationDestination(
          icon: const Icon(Icons.description_outlined),
          selectedIcon: const Icon(Icons.description_rounded, color: AppColors.primaryDark),
          label: 'pdf_reports'.tr,
        ),
        NavigationDestination(
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings_rounded, color: AppColors.primaryDark),
          label: 'settings'.tr,
        ),
      ];

      final index = navCtrl.selectedIndex.value.clamp(0, 2);

      return Scaffold(
        backgroundColor: AppColors.bgLight,
        appBar: index == 0
            ? AppBar(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                elevation: 0,
                titleSpacing: 16,
                title: Obx(() {
                  final sch = adminCtrl.school.value;
                  return Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.school_rounded, color: Colors.white, size: 19),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              sch?.name ?? 'School Management System',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              sch?.code != null && sch!.code.isNotEmpty ? sch.code : 'Institutional Portal',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
                actions: const [ShellAppBarActions()],
              )
            : (index == 2)
                ? AppBar(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    title: Text(
                      'settings'.tr,
                      style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800),
                    ),
                    actions: const [ShellAppBarActions()],
                  )
                : null,
        body: IndexedStack(index: index, children: pages),
        floatingActionButton: index == 0
            ? FloatingActionButton(
                onPressed: () => Get.to(() => const AttendanceView()),
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                elevation: 4,
                shape: const CircleBorder(),
                tooltip: 'attendance_register'.tr,
                child: const Icon(Icons.how_to_reg_rounded, size: 26, color: Colors.white),
              )
            : null,
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: navCtrl.changeTab,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 8,
          shadowColor: Colors.black26,
          height: 64,
          indicatorColor: AppColors.primaryLight,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: destinations,
        ),
      );
    });
  }
}

/// Language toggle, sync status and account menu — shared across all primary tabs.
class ShellAppBarActions extends StatelessWidget {
  const ShellAppBarActions({super.key});

  @override
  Widget build(BuildContext context) {
    final syncCtrl = Get.find<SyncController>();
    final authCtrl = Get.find<AuthController>();
    final adminCtrl = Get.find<AdminController>();
    final localeCtrl = Get.find<LocaleController>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(() => _pillButton(
              onTap: localeCtrl.toggleLanguage,
              child: Text(
                localeCtrl.isUrdu.value ? 'EN' : 'اردو',
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            )),
        const SizedBox(width: 6),
        Obx(() {
          final pending = syncCtrl.pendingCount.value;
          final syncing = syncCtrl.isSyncing.value;
          return _pillButton(
            onTap: () => Get.to(() => const SyncDashboardView()),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  syncing
                      ? Icons.sync_rounded
                      : (pending > 0 ? Icons.cloud_upload_outlined : Icons.cloud_done_outlined),
                  size: 15,
                  color: pending > 0 ? Colors.amberAccent : Colors.white,
                ),
                if (pending > 0) ...[
                  const SizedBox(width: 4),
                  Text(
                    '$pending',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.amberAccent),
                  ),
                ],
              ],
            ),
          );
        }),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          onSelected: (value) async {
            switch (value) {
              case 'students':
                Get.to(() => const StudentsListView());
                break;
              case 'settings':
                await adminCtrl.loadAllAdminData();
                Get.to(() => const AdminSetupView());
                break;
              case 'logout':
                await authCtrl.logout();
                Get.offAll(() => LoginView());
                break;
            }
          },
          itemBuilder: (ctx) {
            final isAdmin = authCtrl.currentUser.value?.isAdmin ?? false;
            return [
              _menuItem('students', Icons.badge_outlined, 'Students & ID Cards'),
              if (isAdmin) _menuItem('settings', Icons.settings_outlined, 'School Administration'),
              const PopupMenuDivider(),
              _menuItem('logout', Icons.logout_rounded, 'Sign Out', color: AppColors.absent),
            ];
          },
        ),
      ],
    );
  }

  Widget _pillButton({required VoidCallback onTap, required Widget child}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      ),
    );
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String label, {Color? color}) {
    return PopupMenuItem<String>(
      value: value,
      height: 44,
      child: Row(
        children: [
          Icon(icon, size: 19, color: color ?? AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: color ?? AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
