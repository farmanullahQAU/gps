import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/biometric_auth_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../attendance/attendance_controller.dart';
import '../admin/admin_controller.dart';
import '../students/students_controller.dart';
import '../sync/sync_controller.dart';
import '../../core/services/notification_service.dart';

class AuthController extends GetxController {
  final AuthRepository authRepository;

  AuthController(this.authRepository);

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<SchoolTenantOption> multipleSchoolTenants = <SchoolTenantOption>[].obs;

  // Reactive Biometric Authentication State
  final RxBool isBiometricSupported = false.obs;
  final RxBool isBiometricEnabled = false.obs;
  final RxMap<String, String> biometricUserInfo = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadCachedSession();
    checkBiometricStatus();
  }

  Future<void> checkBiometricStatus() async {
    try {
      isBiometricSupported.value = await BiometricAuthService.isBiometricsSupported();
      isBiometricEnabled.value = await BiometricAuthService.isBiometricEnabled();
      biometricUserInfo.value = await BiometricAuthService.getBiometricUserInfo();
    } catch (_) {}
  }

  Future<bool> loginWithBiometrics() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final authenticated = await BiometricAuthService.authenticate(
        reason: 'Scan fingerprint or face to unlock GPS portal',
      );
      if (!authenticated) {
        return false;
      }

      final info = await BiometricAuthService.getBiometricUserInfo();
      final pairedUserId = info['id'];

      // Look up local user from SQLite
      UserModel? resolvedUser;
      if (pairedUserId != null && pairedUserId.isNotEmpty) {
        final dbUser = await (authRepository.db.select(authRepository.db.users)
              ..where((t) => t.id.equals(pairedUserId)))
            .getSingleOrNull();
        if (dbUser != null) {
          resolvedUser = UserModel(
            id: dbUser.id,
            schoolId: dbUser.schoolId,
            name: dbUser.name,
            email: dbUser.email ?? '',
            role: dbUser.role,
            pinCodeHash: dbUser.pinCodeHash,
            phone: dbUser.phone,
            avatarUrl: dbUser.avatarUrl,
            cnic: dbUser.cnic,
            designation: dbUser.designation,
          );
        }
      }

      // If no paired user by ID, check last active local user in SQLite
      if (resolvedUser == null) {
        final allUsers = await authRepository.db.select(authRepository.db.users).get();
        if (allUsers.isNotEmpty) {
          final first = allUsers.first;
          resolvedUser = UserModel(
            id: first.id,
            schoolId: first.schoolId,
            name: first.name,
            email: first.email ?? '',
            role: first.role,
            pinCodeHash: first.pinCodeHash,
            phone: first.phone,
            avatarUrl: first.avatarUrl,
            cnic: first.cnic,
            designation: first.designation,
          );
        }
      }

      if (resolvedUser == null) {
        Get.snackbar(
          'No Local User Found',
          'Please sign in with your email or mobile once to link biometric access.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFFEF3C7),
          colorText: const Color(0xFF92400E),
        );
        return false;
      }

      // Restore session
      final school = await (authRepository.db.select(authRepository.db.schools)
            ..where((t) => t.id.equals(resolvedUser!.schoolId)))
          .getSingleOrNull();

      await authRepository.saveSession(
        token: 'biometric_token_${resolvedUser.id}',
        user: resolvedUser,
        school: {
          'id': school?.id ?? resolvedUser.schoolId,
          'name': school?.name ?? 'Government Primary School',
          'code': school?.code ?? 'EMIS-LOCAL',
        },
      );

      currentUser.value = resolvedUser;

      // Re-initialize all controllers
      if (Get.isRegistered<AttendanceController>()) {
        await Get.find<AttendanceController>().onSchoolChanged();
      }
      if (Get.isRegistered<AdminController>()) {
        Get.find<AdminController>().resetState();
        await Get.find<AdminController>().loadAllAdminData();
      }
      if (Get.isRegistered<StudentsController>()) {
        Get.find<StudentsController>().resetState();
        await Get.find<StudentsController>().loadStudents();
      }

      Get.snackbar(
        'Biometric Unlock',
        'Welcome back, ${resolvedUser.name}!',
        backgroundColor: const Color(0xFFDCFCE7),
        colorText: const Color(0xFF166534),
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar('Biometric Error', e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCachedSession() async {
    final cached = await authRepository.getCachedUser();
    currentUser.value = cached;
    if (cached != null) {
      if (Get.isRegistered<AttendanceController>() && Get.find<AttendanceController>().classesList.isEmpty) {
        await Get.find<AttendanceController>().loadClasses();
      }
      if (Get.isRegistered<AdminController>() && Get.find<AdminController>().school.value == null) {
        await Get.find<AdminController>().loadAllAdminData();
      }
      if (Get.isRegistered<StudentsController>() && Get.find<StudentsController>().students.isEmpty) {
        await Get.find<StudentsController>().loadStudents();
      }
    }
    await checkBiometricStatus();

    // Check cloud for verification status if email not verified in local cache
    if (currentUser.value != null && !isEmailVerified) {
      authRepository.refreshSessionFromCloud().then((updated) {
        if (updated != null) {
          currentUser.value = updated;
        }
      });
    }
  }

  final RxBool showVerificationBanner = true.obs;

  bool get isEmailVerified => currentUser.value?.isEmailVerified ?? false;

  void dismissVerificationBanner() {
    showVerificationBanner.value = false;
  }

  Future<Map<String, dynamic>> sendVerificationEmail() async {
    final user = currentUser.value;
    final res = await authRepository.sendVerificationEmail(
      email: user?.email,
      userId: user?.id,
    );
    if (res['alreadyVerified'] == true && user != null) {
      currentUser.value = user.copyWith(isEmailVerified: true);
      showVerificationBanner.value = false;
    }
    return res;
  }

  Future<bool> verifyEmailWithOtp(String code) async {
    final user = currentUser.value;
    if (user == null) return false;

    try {
      final ok = await authRepository.verifyEmail(
        code: code.trim(),
        email: user.email,
        userId: user.id,
      );
      if (ok) {
        currentUser.value = user.copyWith(isEmailVerified: true);
        showVerificationBanner.value = false;
        Get.snackbar(
          'Email Verified',
          'Your email address has been successfully verified.',
          backgroundColor: const Color(0xFFDCFCE7),
          colorText: const Color(0xFF166534),
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      }
    } catch (e) {
      Get.snackbar(
        'Verification Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFEE2E2),
        colorText: const Color(0xFF991B1B),
      );
    }
    return false;
  }

  Future<Map<String, dynamic>> requestPasswordResetOtp(String email) async {
    return authRepository.requestPasswordResetOtp(email);
  }

  Future<List<SchoolTenantOption>> findSchoolsForIdentifier(String identifier) async {
    return authRepository.findSchoolsForIdentifier(identifier);
  }

  Future<bool> login({
    required String identifier,
    String? emisCode,
    String? password,
    String? pin,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      multipleSchoolTenants.clear();
      final user = await authRepository.login(
        identifier: identifier,
        emisCode: emisCode,
        password: password,
        pin: pin,
      );
      currentUser.value = user;

      // Sync FCM device token to backend for push notifications
      final token = NotificationService.instance.fcmToken;
      if (token != null) {
        NotificationService.instance.syncTokenToBackend(token);
      }

      // Re-initialize all controllers for the newly authenticated tenant
      if (Get.isRegistered<AttendanceController>()) {
        await Get.find<AttendanceController>().onSchoolChanged();
      }
      if (Get.isRegistered<AdminController>()) {
        Get.find<AdminController>().resetState();
        await Get.find<AdminController>().loadAllAdminData();
      }
      if (Get.isRegistered<StudentsController>()) {
        Get.find<StudentsController>().resetState();
        await Get.find<StudentsController>().loadStudents();
      }
      if (Get.isRegistered<SyncController>()) {
        // Only force a full pull if this device has no local classes for this school yet;
        // otherwise perform a fast incremental delta sync from the stored cursor.
        final needsInitialHydration = Get.isRegistered<AttendanceController>() &&
            Get.find<AttendanceController>().classesList.isEmpty;
        Get.find<SyncController>().syncNow(silent: true, forceFull: needsInitialHydration).then((_) {
          if (Get.isRegistered<AttendanceController>()) {
            Get.find<AttendanceController>().loadClasses();
          }
          if (Get.isRegistered<AdminController>()) {
            Get.find<AdminController>().loadAllAdminData();
          }
        });
      }
      return true;
    } on MultipleSchoolsFoundException catch (e) {
      multipleSchoolTenants.value = e.schools;
      return false;
    } on SchoolPendingApprovalException catch (e) {
      errorMessage.value = e.message;
      _showPendingApprovalNotice(e.message);
      return false;
    } on SchoolSuspendedException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Account Suspended',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
      return false;
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Sign In Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void _showPendingApprovalNotice(String message) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFBBF24), width: 1.5),
                ),
                child: const Icon(Icons.hourglass_top_rounded, color: Color(0xFFB45309), size: 36),
              ),
              const SizedBox(height: 16),
              const Text(
                'Registration Pending Approval',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, height: 1.45, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF14532D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Get.back(),
                  child: const Text('Understood'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<SchoolRegistrationResult?> registerSchool({
    required String schoolName,
    required String schoolCode,
    required String adminName,
    required String adminPassword,
    required String adminPhone,
    String? adminEmail,
    String? adminPin,
    String? district,
    String? tehsil,
    String? circleOffice,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final res = await authRepository.registerSchool(
        schoolName: schoolName,
        schoolCode: schoolCode,
        adminName: adminName,
        adminPassword: adminPassword,
        adminPhone: adminPhone,
        adminEmail: adminEmail,
        adminPin: adminPin,
        district: district,
        tehsil: tehsil,
        circleOffice: circleOffice,
      );
      return res;
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Registration Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> changePin(String newPin) async {
    final ok = await authRepository.changePin(newPin);
    if (ok) {
      await loadCachedSession();
      Get.snackbar('PIN Updated', 'Your offline unlock PIN has been updated successfully.');
    }
    return ok;
  }

  Future<bool> resetPassword({
    String? schoolCode,
    required String identifier,
    required String newPassword,
    String? pin,
    String? otp,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final ok = await authRepository.resetPassword(
        schoolCode: schoolCode,
        identifier: identifier,
        newPassword: newPassword,
        pin: pin,
        otp: otp,
      );
      if (ok) {
        Get.snackbar(
          'Password Reset Successful',
          'Your new password has been set. You can now sign in.',
          backgroundColor: const Color(0xFFDCFCE7),
          colorText: const Color(0xFF166534),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return ok;
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Reset Failed',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> unlockWithPin(String pin) async {
    final ok = await authRepository.unlockWithPin(pin);
    if (ok) {
      await loadCachedSession();
    }
    return ok;
  }

  Future<void> switchRole(String targetRole) async {
    final updated = await authRepository.switchLocalUserRole(targetRole);
    if (updated != null) {
      currentUser.value = updated;
      Get.snackbar(
        'Switched Active Role',
        'Now signed in as ${updated.name} (${updated.role.toUpperCase()})',
      );
    }
  }

  Future<void> seedDemoData({String initialRole = 'admin'}) async {
    try {
      isLoading.value = true;
      await authRepository.seedLocalDemoData(initialRole: initialRole);
      await loadCachedSession();
      Get.snackbar(
        'KPK School Demo Initialized',
        'Loaded GPS Gulbahar No. 1 Peshawar (EMIS-12405) with Kachi to Class 5.',
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to seed demo: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Wipes all local SQLite tables clean, purges cached sessions, and resets in-memory controllers.
  /// Used when switching from demo/test data to actual real school records.
  Future<void> clearAllDatabaseData() async {
    try {
      isLoading.value = true;
      await authRepository.db.clearAllData();
      await authRepository.logout();
      currentUser.value = null;

      if (Get.isRegistered<AttendanceController>()) {
        final att = Get.find<AttendanceController>();
        att.classesList.clear();
        att.sectionsList.clear();
        att.studentsList.clear();
        att.selectedClass.value = null;
        att.selectedSection.value = null;
      }
      if (Get.isRegistered<AdminController>()) {
        Get.find<AdminController>().resetState();
      }
      if (Get.isRegistered<StudentsController>()) {
        final stu = Get.find<StudentsController>();
        stu.students.clear();
      }
      if (Get.isRegistered<SyncController>()) {
        final sc = Get.find<SyncController>();
        sc.pendingCount.value = 0;
      }

      Get.snackbar(
        'Database Cleared',
        'All database tables have been wiped clean. You can now start with actual school data.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDCFCE7),
        colorText: const Color(0xFF166534),
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar(
        'Clear Failed',
        'Failed to clear database: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFEE2E2),
        colorText: const Color(0xFF991B1B),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateUserProfileAndCredentials({
    required String userId,
    String? name,
    String? email,
    String? phone,
    String? cnic,
    String? designation,
    String? avatarUrl,
    String? newPassword,
    String? newPin,
  }) async {
    try {
      isLoading.value = true;
      final ok = await authRepository.updateUserCredentials(
        userId: userId,
        name: name,
        email: email,
        phone: phone,
        cnic: cnic,
        designation: designation,
        avatarUrl: avatarUrl,
        newPassword: newPassword,
        newPin: newPin,
      );
      if (ok) {
        await loadCachedSession();
        Get.snackbar(
          'Profile Updated',
          'Your profile and offline credentials have been saved locally and queued for synchronization.',
          backgroundColor: const Color(0xFFDCFCE7),
          colorText: const Color(0xFF166534),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return ok;
    } catch (e) {
      Get.snackbar(
        'Update Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFEE2E2),
        colorText: const Color(0xFF991B1B),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> resetPasswordOffline({
    String? schoolCode,
    required String identifier,
    required String currentPin,
    required String newPassword,
    String? newPin,
  }) async {
    try {
      isLoading.value = true;
      final ok = await authRepository.resetPasswordOfflineVerified(
        schoolCode: schoolCode,
        identifier: identifier,
        currentPin: currentPin,
        newPassword: newPassword,
        newPin: newPin,
      );
      if (ok) {
        Get.snackbar(
          'Password Reset Successful',
          'Your new password has been set. You can now sign in with your credentials.',
          backgroundColor: const Color(0xFFDCFCE7),
          colorText: const Color(0xFF166534),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return ok;
    } catch (e) {
      Get.snackbar(
        'Reset Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFEE2E2),
        colorText: const Color(0xFF991B1B),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await authRepository.logout();
    currentUser.value = null;
    if (Get.isRegistered<AttendanceController>()) {
      Get.find<AttendanceController>().resetState();
    }
    if (Get.isRegistered<AdminController>()) {
      Get.find<AdminController>().resetState();
    }
    if (Get.isRegistered<StudentsController>()) {
      Get.find<StudentsController>().resetState();
    }
  }
}
