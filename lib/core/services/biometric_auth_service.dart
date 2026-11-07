import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Professional, resilient Biometric Authentication Service
/// Handles fingerprint, face unlock, and device PIN/passcode fallback
class BiometricAuthService {
  static final LocalAuthentication _auth = LocalAuthentication();
  static const String _prefBiometricEnabledKey = 'gps_biometric_auth_enabled';
  static const String _prefBiometricUserKey = 'gps_biometric_last_user_id';
  static const String _prefBiometricUserNameKey = 'gps_biometric_last_user_name';
  static const String _prefBiometricUserEmailKey = 'gps_biometric_last_user_email';
  static const String _prefBiometricUserRoleKey = 'gps_biometric_last_user_role';
  static const String _prefBiometricSchoolIdKey = 'gps_biometric_last_school_id';

  /// Check if the physical hardware supports biometrics
  static Future<bool> isBiometricsSupported() async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      final available = await _auth.getAvailableBiometrics();
      return isSupported && (canCheck || available.isNotEmpty);
    } catch (_) {
      return false;
    }
  }

  /// Get list of available hardware biometrics on this device
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return <BiometricType>[];
    }
  }

  /// Check whether biometric app lock is toggled ON by user
  static Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefBiometricEnabledKey) ?? false;
  }

  /// Enable or disable biometric app lock
  static Future<void> setBiometricEnabled(
    bool enabled, {
    String? userId,
    String? name,
    String? email,
    String? role,
    String? schoolId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefBiometricEnabledKey, enabled);
    if (enabled) {
      if (userId != null) await prefs.setString(_prefBiometricUserKey, userId);
      if (name != null) await prefs.setString(_prefBiometricUserNameKey, name);
      if (email != null) await prefs.setString(_prefBiometricUserEmailKey, email);
      if (role != null) await prefs.setString(_prefBiometricUserRoleKey, role);
      if (schoolId != null) await prefs.setString(_prefBiometricSchoolIdKey, schoolId);
    }
  }

  /// Retrieve last paired biometric user info
  static Future<Map<String, String>> getBiometricUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getString(_prefBiometricUserKey) ?? '',
      'name': prefs.getString(_prefBiometricUserNameKey) ?? '',
      'email': prefs.getString(_prefBiometricUserEmailKey) ?? '',
      'role': prefs.getString(_prefBiometricUserRoleKey) ?? '',
      'schoolId': prefs.getString(_prefBiometricSchoolIdKey) ?? '',
    };
  }

  /// Authenticate user via fingerprint, face unlock, or device credentials
  static Future<bool> authenticate({
    String reason = 'Authenticate to access GPS Attendance System',
  }) async {
    try {
      final isSupported = await isBiometricsSupported();
      if (!isSupported) return false;

      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
    } on PlatformException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }
}
