// lib/modules/saas/saas_controller.dart
import 'package:get/get.dart';
import '../../data/models/saas_subscription_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/saas_repository.dart';
import '../attendance/attendance_controller.dart';
import '../auth/auth_controller.dart';

class SaasController extends GetxController {
  final SaasRepository saasRepository;

  SaasController({required this.saasRepository});

  final Rx<TenantSubscriptionModel?> tenantSubscription = Rx<TenantSubscriptionModel?>(null);
  final RxList<SaasPlanModel> availablePlans = <SaasPlanModel>[].obs;
  final Rx<SaasPlatformOverviewModel?> platformOverview = Rx<SaasPlatformOverviewModel?>(null);
  final RxList<SaasSchoolTenantModel> allSchools = <SaasSchoolTenantModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isUpgrading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSubscription();
  }

  Future<void> loadSubscription() async {
    isLoading.value = true;
    try {
      final res = await saasRepository.getSubscription();
      tenantSubscription.value = res.tenant;
      availablePlans.assignAll(res.plans);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> upgradePlan(String planId) async {
    isUpgrading.value = true;
    try {
      final ok = await saasRepository.upgradePlan(planId);
      if (ok) {
        await loadSubscription();
        Get.snackbar(
          'Plan Upgraded Successfully',
          'Your school subscription is now on the ${planId.toUpperCase()} tier.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return ok;
    } catch (e) {
      Get.snackbar('Upgrade Error', e.toString());
      return false;
    } finally {
      isUpgrading.value = false;
    }
  }

  Future<void> loadPlatformOverview() async {
    isLoading.value = true;
    try {
      platformOverview.value = await saasRepository.getPlatformOverview();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAllTenants() async {
    isLoading.value = true;
    try {
      allSchools.assignAll(await saasRepository.getAllTenants());
    } finally {
      isLoading.value = false;
    }
  }

  // Multi-School Switcher: Allows switching active school tenant
  Future<void> switchSchoolTenant(SaasSchoolTenantModel targetSchool) async {
    isLoading.value = true;
    try {
      final authRepo = Get.find<AuthRepository>();
      final currentUser = await authRepo.getCachedUser();
      if (currentUser == null) return;

      final updatedUser = UserModel(
        id: currentUser.id,
        schoolId: targetSchool.id,
        name: currentUser.name,
        email: currentUser.email,
        role: currentUser.role,
        pinCodeHash: currentUser.pinCodeHash,
        phone: currentUser.phone,
        avatarUrl: currentUser.avatarUrl,
        cnic: currentUser.cnic,
        designation: currentUser.designation,
      );

      await authRepo.saveSession(
        token: await authRepo.getAuthToken() ?? 'offline_token',
        user: updatedUser,
        school: {
          'id': targetSchool.id,
          'name': targetSchool.name,
          'code': targetSchool.code,
        },
      );

      final authCtrl = Get.find<AuthController>();
      await authCtrl.loadCachedSession();

      if (Get.isRegistered<AttendanceController>()) {
        final attCtrl = Get.find<AttendanceController>();
        await attCtrl.loadClasses();
        await attCtrl.refreshSchoolWideKpis();
      }

      await loadSubscription();

      Get.snackbar(
        'Switched Active School Tenant',
        'Now managing: ${targetSchool.name} (${targetSchool.code})',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> approveSchool(String schoolId) async {
    isLoading.value = true;
    try {
      final ok = await saasRepository.approveSchool(schoolId);
      if (ok) {
        await loadAllTenants();
        Get.snackbar(
          'School Approved',
          'The school registration has been approved. Staff can now log in.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return ok;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> rejectSchool(String schoolId) async {
    isLoading.value = true;
    try {
      final ok = await saasRepository.rejectSchool(schoolId);
      if (ok) {
        await loadAllTenants();
        Get.snackbar(
          'School Rejected',
          'The school registration was rejected.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return ok;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> suspendSchool(String schoolId) async {
    isLoading.value = true;
    try {
      final ok = await saasRepository.suspendSchool(schoolId);
      if (ok) {
        await loadAllTenants();
        Get.snackbar(
          'School Suspended',
          'The school account has been suspended.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return ok;
    } finally {
      isLoading.value = false;
    }
  }
}
