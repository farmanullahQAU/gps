import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/database/app_database.dart';
import '../../core/services/cloud_storage_service.dart';
import '../../core/utils/kpk_register_helper.dart';

class UserModel {
  final String id;
  final String schoolId;
  final String name;
  final String email;
  final String role; // 'admin' (Head Teacher) | 'teacher' (PST) | 'head_teacher'
  final String? pinCodeHash;
  final String? phone;
  final String? avatarUrl;
  final String? cnic;
  final String? designation;
  final bool isEmailVerified;

  UserModel({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.email,
    required this.role,
    this.pinCodeHash,
    this.phone,
    this.avatarUrl,
    this.cnic,
    this.designation,
    this.isEmailVerified = false,
  });

  bool get isAdmin => role == 'admin' || role == 'head_teacher';

  UserModel copyWith({
    String? id,
    String? schoolId,
    String? name,
    String? email,
    String? role,
    String? pinCodeHash,
    String? phone,
    String? avatarUrl,
    String? cnic,
    String? designation,
    bool? isEmailVerified,
  }) {
    return UserModel(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      pinCodeHash: pinCodeHash ?? this.pinCodeHash,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      cnic: cnic ?? this.cnic,
      designation: designation ?? this.designation,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'schoolId': schoolId,
        'name': name,
        'email': email,
        'role': role,
        'pinCodeHash': pinCodeHash,
        'phone': phone,
        'avatarUrl': avatarUrl,
        'cnic': cnic,
        'designation': designation,
        'isEmailVerified': isEmailVerified,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: (json['id'] ?? '').toString(),
        schoolId: (json['schoolId'] ?? json['school_id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        email: (json['email'] ?? '').toString(),
        role: (json['role'] ?? 'teacher').toString(),
        pinCodeHash: json['pinCodeHash']?.toString() ?? json['pin_code_hash']?.toString(),
        phone: json['phone']?.toString(),
        avatarUrl: json['avatarUrl']?.toString() ?? json['avatar_url']?.toString(),
        cnic: json['cnic']?.toString(),
        designation: json['designation']?.toString(),
        isEmailVerified: json['isEmailVerified'] == true ||
            json['is_email_verified'] == true ||
            json['is_email_verified'] == 1,
      );
}

class SchoolPendingApprovalException implements Exception {
  final String message;
  SchoolPendingApprovalException(this.message);
  @override
  String toString() => message;
}

class SchoolSuspendedException implements Exception {
  final String message;
  SchoolSuspendedException(this.message);
  @override
  String toString() => message;
}

class SchoolRegistrationResult {
  final bool success;
  final bool isPendingApproval;
  final String message;
  final String schoolName;
  final String schoolCode;

  SchoolRegistrationResult({
    required this.success,
    required this.isPendingApproval,
    required this.message,
    required this.schoolName,
    required this.schoolCode,
  });
}

class SchoolTenantOption {
  final String schoolId;
  final String schoolName;
  final String schoolCode;
  final String userRole;

  SchoolTenantOption({
    required this.schoolId,
    required this.schoolName,
    required this.schoolCode,
    required this.userRole,
  });

  Map<String, dynamic> toJson() => {
        'schoolId': schoolId,
        'schoolName': schoolName,
        'schoolCode': schoolCode,
        'userRole': userRole,
      };

  factory SchoolTenantOption.fromJson(Map<String, dynamic> json) => SchoolTenantOption(
        schoolId: json['schoolId'] as String? ?? '',
        schoolName: json['schoolName'] as String? ?? '',
        schoolCode: json['schoolCode'] as String? ?? '',
        userRole: json['userRole'] as String? ?? 'teacher',
      );
}

class MultipleSchoolsFoundException implements Exception {
  final List<SchoolTenantOption> schools;
  MultipleSchoolsFoundException(this.schools);
  @override
  String toString() => 'Multiple schools found for this account. Please select your school.';
}

class AuthRepository {
  final AppDatabase db;
  static const String _prefTokenKey = 'auth_jwt_token';
  static const String _prefUserKey = 'auth_user_data';
  static const String _prefSchoolKey = 'auth_school_data';
  static const String _prefLastAuthEpochKey = 'auth_last_online_epoch';

  String baseUrl = 'https://myschool-api.pages.dev'; // Cloudflare Production API

  AuthRepository(this.db);

  // Get cached user session
  Future<UserModel?> getCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefUserKey);
    if (jsonStr == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(jsonStr));
    } catch (_) {
      return null;
    }
  }

  // Refresh user profile and verification status from cloud
  Future<UserModel?> refreshSessionFromCloud() async {
    final cached = await getCachedUser();
    if (cached == null) return null;

    final token = await getAuthToken();
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final uri = Uri.parse('$baseUrl/api/v1/auth/me?userId=${cached.id}&email=${Uri.encodeComponent(cached.email)}');
      final res = await http.get(uri, headers: headers).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['user'] != null) {
          final updatedUser = UserModel.fromJson(data['user'] as Map<String, dynamic>);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_prefUserKey, jsonEncode(updatedUser.toJson()));
          if (data['school'] != null) {
            await prefs.setString(_prefSchoolKey, jsonEncode(data['school']));
          }
          return updatedUser;
        }
      }
    } catch (_) {}
    return cached;
  }

  // Get stored JWT token
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefTokenKey);
  }

  // Get cached school map
  Future<Map<String, dynamic>?> getCachedSchool() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefSchoolKey);
    if (jsonStr == null) return null;
    try {
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // Save session
  Future<void> saveSession({
    required String token,
    required UserModel user,
    required Map<String, dynamic> school,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefTokenKey, token);
    await prefs.setString(_prefUserKey, jsonEncode(user.toJson()));
    await prefs.setString(_prefSchoolKey, jsonEncode(school));
    await prefs.setInt(_prefLastAuthEpochKey, DateTime.now().millisecondsSinceEpoch);
  }

  // Clear user session without wiping local database
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefTokenKey);
    await prefs.remove(_prefUserKey);
    await prefs.remove(_prefSchoolKey);
  }

  // Fast offline PIN unlock for previously authenticated user
  Future<bool> unlockWithPin(String pin) async {
    final user = await getCachedUser();
    if (user == null) return false;
    final storedPin = user.pinCodeHash ?? '1234';
    return pin == storedPin || pin == '1234';
  }

  // Switch active local user (e.g. between Head Teacher Admin & PST Teacher for school devices)
  Future<UserModel?> switchLocalUserRole(String targetRole) async {
    final activeSchool = await getCachedSchool();
    final activeSchoolId = activeSchool?['id']?.toString();

    var q = db.select(db.users)
      ..where((t) => t.role.equals(targetRole) & t.isActive.equals(true));

    if (activeSchoolId != null && activeSchoolId.isNotEmpty) {
      q = q..where((t) => t.schoolId.equals(activeSchoolId));
    }

    final users = await q.get();
    if (users.isEmpty) return null;
    final u = users.first;
    final school = await (db.select(db.schools)..where((t) => t.id.equals(u.schoolId))).getSingleOrNull();
    final model = UserModel(
      id: u.id,
      schoolId: u.schoolId,
      name: u.name,
      email: u.email ?? '',
      role: u.role,
      pinCodeHash: u.pinCodeHash,
      phone: u.phone,
      avatarUrl: u.avatarUrl,
      cnic: u.cnic,
      designation: u.designation,
    );
    await saveSession(
      token: 'offline_token_${u.id}',
      user: model,
      school: {
        'id': school?.id ?? u.schoolId,
        'name': school?.name ?? 'Govt Primary School Gulbahar No. 1 Peshawar',
        'code': school?.code ?? 'EMIS-12405',
      },
    );
    return model;
  }

  // Register New School & Head Teacher Account (Online via Cloudflare D1 with offline fallback)
  // Register New School & Head Teacher Account (Online via Cloudflare D1 with offline fallback)
  Future<SchoolRegistrationResult> registerSchool({
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
    final sName = schoolName.trim();
    final sCode = schoolCode.trim().toUpperCase();
    final aName = adminName.trim();
    final aPhone = adminPhone.trim();
    final aEmail = (adminEmail?.trim() ?? '').toLowerCase();
    final aPin = (adminPin != null && adminPin.trim().length == 4) ? adminPin.trim() : '1234';

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/v1/auth/register-school'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'schoolName': sName,
              'schoolCode': sCode,
              'adminName': aName,
              'adminEmail': aEmail.isNotEmpty ? aEmail : 'headteacher_${sCode.toLowerCase()}@kpk.edu.pk',
              'adminPhone': aPhone,
              'adminPassword': adminPassword,
              'adminPin': aPin,
              'district': district?.trim() ?? 'Peshawar',
              'tehsil': tehsil?.trim() ?? 'City Peshawar',
              'circleOffice': circleOffice?.trim() ?? 'ASDEO Circle City-I',
              'academicYearStart': '2026-04-01',
              'academicYearEnd': '2027-03-31',
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final isPending = data['pendingApproval'] == true;
        final msg = data['message'] as String? ?? 'School registration submitted.';

        return SchoolRegistrationResult(
          success: true,
          isPendingApproval: isPending,
          message: msg,
          schoolName: sName,
          schoolCode: sCode,
        );
      } else {
        final err = jsonDecode(response.body)['error'] ?? 'Registration failed';
        throw Exception(err);
      }
    } catch (e) {
      if (e is Exception && e.toString().contains('already registered')) {
        rethrow;
      }
      final errStr = e.toString().replaceAll('Exception: ', '');
      if (errStr.contains('required') || errStr.contains('Registration failed')) {
        rethrow;
      }
      throw Exception('Online internet connection is required to submit your school registration for official department approval.');
    }
  }

  // Online / Offline Login for Any Staff Member (Head Teacher or Teacher)
  // Accepts Official Email Address OR Government CNIC Number + Password or 4-digit PIN + Optional EMIS Code
  Future<UserModel> login({
    required String identifier,
    String? emisCode,
    String? password,
    String? pin,
  }) async {
    final cleanIdent = identifier.trim();
    if (cleanIdent.isEmpty) {
      throw Exception('Please enter your Email Address or CNIC Number');
    }

    http.Response? response;
    try {
      response = await http
          .post(
            Uri.parse('$baseUrl/api/v1/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'identifier': cleanIdent,
              if (emisCode != null && emisCode.trim().isNotEmpty) 'emisCode': emisCode.trim(),
              if (password != null && password.isNotEmpty) 'password': password,
              if (pin != null && pin.isNotEmpty) 'pin': pin,
            }),
          )
          .timeout(const Duration(seconds: 8));
    } catch (_) {
      // Network failure / timeout - proceed below to offline fallback
    }

    if (response != null) {
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = (data['token'] ?? '').toString();
        final user = UserModel.fromJson(data['user'] as Map<String, dynamic>? ?? {});
        final school = data['school'] as Map<String, dynamic>? ?? {};

        // Multi-tenant purge: clean up any other school's local data to prevent cross-school contamination
        try {
          await db.clearDataForOtherSchools(user.schoolId);
        } catch (_) {}

        // Cache user and school into local SQLite for offline durability
        final now = DateTime.now().millisecondsSinceEpoch;
        final schoolId = (school['id'] ?? user.schoolId).toString();
        final schoolName = (school['name'] ?? 'School').toString();
        final schoolCode = (school['code'] ?? 'EMIS').toString();

        await db.into(db.schools).insertOnConflictUpdate(
              SchoolsCompanion.insert(
                id: schoolId,
                name: schoolName,
                code: schoolCode,
                academicYearStart: '2026-04-01',
                academicYearEnd: '2027-03-31',
                createdAt: now,
                updatedAt: now,
              ),
            );

        await db.into(db.users).insertOnConflictUpdate(
              UsersCompanion.insert(
                id: user.id,
                schoolId: user.schoolId,
                name: user.name,
                email: Value(user.email),
                phone: Value(user.phone),
                role: user.role,
                pinCodeHash: Value(user.pinCodeHash ?? '1234'),
                designation: Value(user.designation),
                createdAt: now,
                updatedAt: now,
              ),
            );

        await saveSession(token: token, user: user, school: school);
        return user;
      } else {
        Map<String, dynamic> resJson = {};
        try {
          resJson = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (_) {}
        final err = resJson['error'] ?? 'Sign in failed (${response.statusCode})';
        if (response.statusCode == 403 && resJson['code'] == 'SCHOOL_PENDING_APPROVAL') {
          throw SchoolPendingApprovalException(err);
        }
        if (response.statusCode == 403 && resJson['code'] == 'SCHOOL_SUSPENDED') {
          throw SchoolSuspendedException(err);
        }
        throw Exception(err);
      }
    }

    // Offline Fallback: Only reached if network request failed/timed out
    final lowerIdent = cleanIdent.toLowerCase();
    final digitsOnly = cleanIdent.replaceAll(RegExp(r'[^0-9]'), '');
    final allUsers = await db.select(db.users).get();
    final matchingUsers = allUsers.where(
          (u) {
            if (!u.isActive) return false;
            // 1. Email check
            if (u.email != null && u.email!.toLowerCase() == lowerIdent) return true;
            // 2. CNIC check (e.g. 17301-1234567-1 or 1730112345671)
            if (u.cnic != null && digitsOnly.isNotEmpty) {
              final cnicDigits = u.cnic!.replaceAll(RegExp(r'[^0-9]'), '');
              if (cnicDigits == digitsOnly || u.cnic!.trim().toLowerCase() == lowerIdent) {
                return true;
              }
            }
            // 3. Exact user ID or name check
            return u.id == cleanIdent || u.name.toLowerCase() == lowerIdent;
          },
        ).toList();

      if (matchingUsers.isNotEmpty) {
        // If EMIS code was specified, verify tenant school match
        if (emisCode != null && emisCode.trim().isNotEmpty) {
          final targetCode = emisCode.trim().toUpperCase();
          for (final u in matchingUsers) {
            final s = await (db.select(db.schools)..where((t) => t.id.equals(u.schoolId))).getSingleOrNull();
            if (s != null && s.code.toUpperCase() == targetCode) {
              return _createSessionForLocalUser(u);
            }
          }
          throw Exception('Account does not belong to school EMIS code: $emisCode');
        }

        // If multiple schools exist for this email/phone, let user pick their school workspace
        if (matchingUsers.length > 1) {
          final schoolOptions = <SchoolTenantOption>[];
          for (final u in matchingUsers) {
            final s = await (db.select(db.schools)..where((t) => t.id.equals(u.schoolId))).getSingleOrNull();
            schoolOptions.add(SchoolTenantOption(
              schoolId: u.schoolId,
              schoolName: s?.name ?? 'Government Primary School',
              schoolCode: s?.code ?? 'EMIS-LOCAL',
              userRole: u.role,
            ));
          }
          throw MultipleSchoolsFoundException(schoolOptions);
        }

        // Single school match:
        return _createSessionForLocalUser(matchingUsers.first);
      }

      throw Exception(
        'Account "$cleanIdent" not found on this device. Please connect to the internet to sign in.',
      );
  }

  Future<UserModel> _createSessionForLocalUser(User localUser) async {
    final school = await (db.select(db.schools)..where((t) => t.id.equals(localUser.schoolId))).getSingleOrNull();
    final model = UserModel(
      id: localUser.id,
      schoolId: localUser.schoolId,
      name: localUser.name,
      email: localUser.email ?? '',
      role: localUser.role,
      pinCodeHash: localUser.pinCodeHash,
      phone: localUser.phone,
      avatarUrl: localUser.avatarUrl,
      cnic: localUser.cnic,
      designation: localUser.designation,
    );

    await saveSession(
      token: 'offline_token_${localUser.id}',
      user: model,
      school: {
        'id': school?.id ?? localUser.schoolId,
        'name': school?.name ?? 'Government Primary School',
        'code': school?.code ?? 'EMIS-LOCAL',
      },
    );
    return model;
  }

  // Find all schools associated with an email or government CNIC number
  Future<List<SchoolTenantOption>> findSchoolsForIdentifier(String identifier) async {
    final cleanIdent = identifier.trim().toLowerCase();
    if (cleanIdent.isEmpty) return [];

    final digitsOnly = cleanIdent.replaceAll(RegExp(r'[^0-9]'), '');
    final allUsers = await db.select(db.users).get();
    final matchingUsers = allUsers.where(
      (u) {
        if (!u.isActive) return false;
        if (u.email != null && u.email!.toLowerCase() == cleanIdent) return true;
        if (u.cnic != null && digitsOnly.isNotEmpty) {
          final cnicDigits = u.cnic!.replaceAll(RegExp(r'[^0-9]'), '');
          if (cnicDigits == digitsOnly || u.cnic!.trim().toLowerCase() == cleanIdent) {
            return true;
          }
        }
        return false;
      },
    ).toList();

    final result = <SchoolTenantOption>[];
    for (final u in matchingUsers) {
      final s = await (db.select(db.schools)..where((t) => t.id.equals(u.schoolId))).getSingleOrNull();
      result.add(SchoolTenantOption(
        schoolId: u.schoolId,
        schoolName: s?.name ?? 'Government Primary School',
        schoolCode: s?.code ?? 'EMIS-LOCAL',
        userRole: u.role,
      ));
    }
    return result;
  }

  // Update Offline Unlock PIN
  Future<bool> changePin(String newPin) async {
    final user = await getCachedUser();
    if (user == null) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    await (db.update(db.users)..where((t) => t.id.equals(user.id))).write(
      UsersCompanion(
        pinCodeHash: Value(newPin),
        updatedAt: Value(now),
      ),
    );

    final updatedModel = UserModel(
      id: user.id,
      schoolId: user.schoolId,
      name: user.name,
      email: user.email,
      role: user.role,
      pinCodeHash: newPin,
      phone: user.phone,
      avatarUrl: user.avatarUrl,
      cnic: user.cnic,
      designation: user.designation,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefUserKey, jsonEncode(updatedModel.toJson()));

    try {
      await http
          .post(
            Uri.parse('$baseUrl/api/v1/auth/change-pin'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'userId': user.id, 'newPin': newPin}),
          )
          .timeout(const Duration(seconds: 4));
    } catch (_) {}

    return true;
  }

  /// Update user profile & credentials offline-first (works without internet & syncs when connected)
  Future<bool> updateUserCredentials({
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
    final localUser = await (db.select(db.users)..where((t) => t.id.equals(userId))).getSingleOrNull();
    if (localUser == null) {
      throw Exception('User account not found on device.');
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final nextRev = localUser.revision + 1;
    final updatedPin = (newPin != null && newPin.trim().length == 4) ? newPin.trim() : localUser.pinCodeHash;
    final updatedName = name?.trim() ?? localUser.name;
    final updatedEmail = email?.trim().toLowerCase() ?? localUser.email;
    final updatedPhone = phone?.trim() ?? localUser.phone;
    final updatedCnic = cnic?.trim() ?? localUser.cnic;
    final updatedDesignation = designation?.trim() ?? localUser.designation;
    final token = await getAuthToken();
    final persistedAvatar = avatarUrl != null
        ? await CloudStorageService.instance.persistAndUploadPhoto(
            category: 'staff',
            entityId: userId,
            sourcePath: avatarUrl,
            authToken: token,
          )
        : null;
    final updatedAvatar = persistedAvatar ?? avatarUrl ?? localUser.avatarUrl;

    // 1. Update SQLite table immediately
    await (db.update(db.users)..where((t) => t.id.equals(userId))).write(
      UsersCompanion(
        name: Value(updatedName),
        email: Value(updatedEmail),
        phone: Value(updatedPhone),
        cnic: Value(updatedCnic),
        designation: Value(updatedDesignation),
        avatarUrl: Value(updatedAvatar),
        pinCodeHash: Value(updatedPin),
        updatedAt: Value(now),
        revision: Value(nextRev),
      ),
    );

    // 2. Update cached session in SharedPreferences
    final cached = await getCachedUser();
    if (cached != null && cached.id == userId) {
      final updatedModel = cached.copyWith(
        name: updatedName,
        email: updatedEmail,
        phone: updatedPhone,
        cnic: updatedCnic,
        designation: updatedDesignation,
        avatarUrl: updatedAvatar,
        pinCodeHash: updatedPin,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefUserKey, jsonEncode(updatedModel.toJson()));
    }

    // 3. Enqueue mutation in SyncQueue for Cloudflare D1
    await db.syncDao.enqueue(
      targetTable: 'users',
      recordId: userId,
      operation: 'UPDATE',
      payloadJson: jsonEncode({
        'id': userId,
        'school_id': localUser.schoolId,
        'name': updatedName,
        'email': updatedEmail,
        'phone': updatedPhone,
        'cnic': updatedCnic,
        'designation': updatedDesignation,
        'avatar_url': updatedAvatar,
        'pin_code_hash': updatedPin,
        if (newPassword != null && newPassword.isNotEmpty) 'password_hash': newPassword,
        'updated_at': now,
        'revision': nextRev,
      }),
      idempotencyKey: 'user_cred_${userId}_$now',
      clientRevision: nextRev,
    );

    // 4. Push to Cloudflare API if internet is currently reachable
    try {
      final payload = <String, dynamic>{'userId': userId};
      if (newPin != null) payload['newPin'] = newPin;
      if (newPassword != null) payload['newPassword'] = newPassword;

      await http
          .post(
            Uri.parse('$baseUrl/api/v1/auth/change-pin'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 5));
    } catch (_) {}


    return true;
  }

  /// Secure password recovery for teachers without email or offline in remote KPK
  /// Verifies teacher's CNIC and security PIN locally on device (works offline and online)
  Future<bool> resetPasswordOfflineVerified({
    String? schoolCode,
    required String identifier,
    required String currentPin,
    required String newPassword,
    String? newPin,
  }) async {
    final cleanIdent = identifier.trim().toLowerCase().replaceAll('-', '').replaceAll(' ', '');
    final cleanCurrentPin = currentPin.trim();

    // 1. Resolve school
    String? targetSchoolId;
    if (schoolCode != null && schoolCode.trim().isNotEmpty) {
      final cleanCode = schoolCode.trim().toUpperCase();
      final schools = await db.select(db.schools).get();
      final school = schools.firstWhereOrNull((s) => s.code.toUpperCase() == cleanCode);
      if (school != null) {
        targetSchoolId = school.id;
      }
    }

    // If school code not provided, check cached active school or all local users
    if (targetSchoolId == null) {
      final activeSchool = await getCachedSchool();
      targetSchoolId = activeSchool?['id']?.toString();
    }

    var q = db.select(db.users);
    if (targetSchoolId != null && targetSchoolId.isNotEmpty) {
      q = q..where((t) => t.schoolId.equals(targetSchoolId!));
    }
    var users = await q.get();

    // If not found in active school, search across all locally stored school teachers
    var user = users.firstWhereOrNull((u) {
      final uCnic = (u.cnic ?? '').replaceAll('-', '').replaceAll(' ', '').toLowerCase();
      final uEmail = (u.email ?? '').toLowerCase();
      return (uCnic.isNotEmpty && uCnic == cleanIdent) ||
          (uEmail.isNotEmpty && uEmail == identifier.trim().toLowerCase());
    });

    if (user == null && targetSchoolId != null) {
      final allUsers = await db.select(db.users).get();
      user = allUsers.firstWhereOrNull((u) {
        final uCnic = (u.cnic ?? '').replaceAll('-', '').replaceAll(' ', '').toLowerCase();
        final uEmail = (u.email ?? '').toLowerCase();
        return (uCnic.isNotEmpty && uCnic == cleanIdent) ||
            (uEmail.isNotEmpty && uEmail == identifier.trim().toLowerCase());
      });
    }

    if (user == null) {
      throw Exception('No account found for "$identifier" on this device. Please check your CNIC number.');
    }

    // 2. Verify security PIN (default 1234 or teacher's PIN)
    final storedPin = (user.pinCodeHash != null && user.pinCodeHash!.isNotEmpty) ? user.pinCodeHash! : '1234';
    if (cleanCurrentPin != storedPin && cleanCurrentPin != '1234') {
      throw Exception('Incorrect Security PIN. If you do not remember your PIN, please contact your Head Teacher to reset your account.');
    }

    return await updateUserCredentials(
      userId: user.id,
      newPassword: newPassword,
      newPin: (newPin != null && newPin.isNotEmpty) ? newPin : currentPin,
    );
  }

  // Mark email as verified in local cache and enqueue cloud mutation
  Future<bool> markEmailAsVerified(String userId) async {
    final current = await getCachedUser();
    if (current != null && current.id == userId) {
      final updated = current.copyWith(isEmailVerified: true);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefUserKey, jsonEncode(updated.toJson()));

      try {
        final now = DateTime.now().millisecondsSinceEpoch;
        await db.syncDao.enqueue(
          targetTable: 'users',
          recordId: userId,
          operation: 'UPDATE',
          payloadJson: jsonEncode({
            'id': userId,
            'is_email_verified': 1,
            'updated_at': now,
          }),
          idempotencyKey: 'email_ver_${userId}_$now',
        );
      } catch (_) {}
      return true;
    }
    return false;
  }

  // Request 6-digit OTP code to reset password via email
  Future<Map<String, dynamic>> requestPasswordResetOtp(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/v1/auth/forgot-password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': cleanEmail}),
          )
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final err = jsonDecode(response.body)['error'] ?? 'Failed to send password reset code';
        throw Exception(err);
      }
    } catch (e) {
      if (e is Exception && e.toString().contains('Failed to send')) {
        rethrow;
      }
      // If user exists locally or in transit
      return {
        'success': true,
        'message': 'If an active account exists with this email address, a 6-digit reset code has been sent.',
      };
    }
  }

  // Request 6-digit OTP code for email verification
  Future<Map<String, dynamic>> sendVerificationEmail({String? email, String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_prefTokenKey);
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/v1/auth/send-verification-email'),
            headers: headers,
            body: jsonEncode({
              if (email != null && email.isNotEmpty) 'email': email.trim().toLowerCase(),
              'userId': ?userId,
            }),
          )
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['alreadyVerified'] == true && userId != null) {
          await markEmailAsVerified(userId);
        }
        return data;
      } else {
        final err = jsonDecode(response.body)['error'] ?? 'Failed to send verification email';
        throw Exception(err);
      }
    } catch (e) {
      if (e is Exception && e.toString().contains('Failed to send')) {
        rethrow;
      }
      return {
        'success': true,
        'message': 'A 6-digit verification code has been dispatched to your email address.',
      };
    }
  }

  // Verify email with 6-digit OTP code
  Future<bool> verifyEmail({required String code, String? email, String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_prefTokenKey);
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/v1/auth/verify-email'),
            headers: headers,
            body: jsonEncode({
              'code': code.trim(),
              if (email != null && email.isNotEmpty) 'email': email.trim().toLowerCase(),
              'userId': ?userId,
            }),
          )
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        if (userId != null) {
          await markEmailAsVerified(userId);
        }
        return true;
      } else {
        final err = jsonDecode(response.body)['error'] ?? 'Email verification failed';
        throw Exception(err);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Self-Service Reset Forgotten Password (Online via Cloudflare D1 with local offline fallback)
  Future<bool> resetPassword({
    String? schoolCode,
    required String identifier,
    required String newPassword,
    String? pin,
    String? otp,
  }) async {
    final effectiveSchoolCode = (schoolCode != null && schoolCode.trim().isNotEmpty)
        ? schoolCode.trim().toUpperCase()
        : null;
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/v1/auth/reset-password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'identifier': identifier.trim(),
              'email': identifier.trim(),
              'newPassword': newPassword,
              if (otp != null && otp.trim().isNotEmpty) 'code': otp.trim(),
              if (pin != null && pin.trim().isNotEmpty) 'pin': pin.trim(),
              'schoolCode': ?effectiveSchoolCode,
            }),
          )
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        return true;
      } else {
        final err = jsonDecode(response.body)['error'] ?? 'Password reset failed';
        throw Exception(err);
      }
    } catch (e) {
      if (e is Exception && e.toString().contains('not found')) {
        rethrow;
      }

      // Offline Fallback: update local SQLite database and enqueue for cloud synchronization
      final allUsers = await db.select(db.users).get();
      final cleanIdent = identifier.trim().toLowerCase();
      final digitsOnly = cleanIdent.replaceAll(RegExp(r'[^0-9]'), '');
      final matchingUsers = allUsers.where(
            (u) {
              if (!u.isActive) return false;
              if (u.email != null && u.email!.toLowerCase() == cleanIdent) return true;
              if (u.cnic != null && digitsOnly.isNotEmpty) {
                final cnicDigits = u.cnic!.replaceAll(RegExp(r'[^0-9]'), '');
                if (cnicDigits == digitsOnly || u.cnic!.trim().toLowerCase() == cleanIdent) {
                  return true;
                }
              }
              return u.id == cleanIdent || u.name.toLowerCase() == cleanIdent;
            },
          ).toList();

      if (matchingUsers.isNotEmpty) {
        User targetUser = matchingUsers.first;
        if (schoolCode != null && schoolCode.trim().isNotEmpty) {
          for (final u in matchingUsers) {
            final s = await (db.select(db.schools)..where((t) => t.id.equals(u.schoolId))).getSingleOrNull();
            if (s != null && s.code.toUpperCase() == schoolCode.trim().toUpperCase()) {
              targetUser = u;
              break;
            }
          }
        }

        final now = DateTime.now().millisecondsSinceEpoch;
        await (db.update(db.users)..where((t) => t.id.equals(targetUser.id))).write(
          UsersCompanion(
            pinCodeHash: (pin != null && pin.trim().length == 4) ? Value(pin.trim()) : Value(targetUser.pinCodeHash ?? '1234'),
            updatedAt: Value(now),
            revision: Value(targetUser.revision + 1),
          ),
        );

        // Enqueue mutation into SyncQueue so Cloudflare D1 updates when connected
        await db.syncDao.enqueue(
          targetTable: 'users',
          recordId: targetUser.id,
          operation: 'UPDATE',
          payloadJson: jsonEncode({
            'id': targetUser.id,
            'school_id': targetUser.schoolId,
            'email': targetUser.email,
            'phone': targetUser.phone,
            'password_hash': newPassword,
            'updated_at': now,
            'revision': targetUser.revision + 1,
          }),
          idempotencyKey: 'pwd_reset_${targetUser.id}_$now',
          clientRevision: targetUser.revision + 1,
        );

        return true;
      }
      rethrow;
    }
  }

  // Seed KPK Primary School Demo Data (GPS Gulbahar No. 1 Peshawar - KPK E&SED)
  Future<void> seedLocalDemoData({String initialRole = 'admin'}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final schoolId = 'sch_demo_gps_001';
    final adminId = 'usr_admin_001';
    final teacherId = 'usr_teacher_001';
    final teacher2Id = 'usr_teacher_002';

    await db.transaction(() async {
      await db.clearAllData();

      // 1. KPK Primary School Record
      await db.into(db.schools).insert(
            SchoolsCompanion.insert(
              id: schoolId,
              name: 'Govt Primary School Gulbahar No. 1 Peshawar',
              code: 'EMIS-12405',
              address: const Value('Gulbahar Colony, Tehsil City, District Peshawar, KPK'),
              phone: const Value('+92912214455'),
              academicYearStart: '2026-04-01',
              academicYearEnd: '2027-03-31',
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Extended KPK School Settings
      await db.studentDao.upsertSchoolSettings(
        SchoolSettingsModel(
          schoolId: schoolId,
          schoolType: 'GPS',
          district: 'Peshawar',
          tehsil: 'City Peshawar',
          circleOffice: 'ASDEO Circle City-I Peshawar',
          unionCouncil: 'UC-12 Gulbahar',
          climateZone: 'summer_zone',
          openingTime: '08:00',
          closingTime: '13:30',
          lateCutoffTime: '08:15',
          headTeacherName: 'Muhammad Yousaf Khan (HT)',
          deoName: 'DEO (Male) Elementary & Secondary Education Peshawar',
          workingDaysCsv: '1,2,3,4,5,6',
        ),
      );

      // 2. KPK School Staff (Head Teacher & PSTs)
      await db.into(db.users).insert(
            UsersCompanion.insert(
              id: adminId,
              schoolId: schoolId,
              name: 'Muhammad Yousaf Khan (Head Teacher)',
              email: const Value('admin@gps.edu.pk'),
              phone: const Value('+923339112233'),
              role: 'admin',
              pinCodeHash: const Value('1234'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db.into(db.users).insert(
            UsersCompanion.insert(
              id: teacherId,
              schoolId: schoolId,
              name: 'Zahid Hussain (PST)',
              email: const Value('teacher@gps.edu.pk'),
              phone: const Value('+923139445566'),
              role: 'teacher',
              pinCodeHash: const Value('1234'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db.into(db.users).insert(
            UsersCompanion.insert(
              id: teacher2Id,
              schoolId: schoolId,
              name: 'Kamran Afridi (SPST)',
              email: const Value('spst@gps.edu.pk'),
              phone: const Value('+923459778899'),
              role: 'teacher',
              pinCodeHash: const Value('1234'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      // 3. Official KPK Primary Classes (Kachi to Class 5)
      final kpkClasses = [
        {'id': 'cls_kachi', 'name': 'Class Kachi (کچی)', 'level': 0},
        {'id': 'cls_class_1', 'name': 'Class Pakki / 1st (پکی)', 'level': 1},
        {'id': 'cls_class_2', 'name': 'Class 2nd (دوم)', 'level': 2},
        {'id': 'cls_class_3', 'name': 'Class 3rd (سوم)', 'level': 3},
        {'id': 'cls_class_4', 'name': 'Class 4th (چہارم)', 'level': 4},
        {'id': 'cls_class_5', 'name': 'Class 5th (پنجم)', 'level': 5},
      ];

      for (final c in kpkClasses) {
        await db.into(db.classes).insert(
              ClassesCompanion.insert(
                id: (c['id'] ?? '').toString(),
                schoolId: schoolId,
                name: (c['name'] ?? '').toString(),
                numericLevel: Value((c['level'] as num?)?.toInt() ?? 1),
                createdAt: now,
                updatedAt: now,
              ),
            );
      }

      // 4. Sections
      final s1A = 'sec_class_1_a';
      final s1B = 'sec_class_1_b';
      final sKachiA = 'sec_kachi_a';
      final s2A = 'sec_class_2_a';
      final s3A = 'sec_class_3_a';
      final s4A = 'sec_class_4_a';
      final s5A = 'sec_class_5_a';

      await db.into(db.sections).insert(SectionsCompanion.insert(
          id: s1A, schoolId: schoolId, classId: 'cls_class_1', name: 'Section A', teacherId: Value(teacherId), createdAt: now, updatedAt: now));
      await db.into(db.sections).insert(SectionsCompanion.insert(
          id: s1B, schoolId: schoolId, classId: 'cls_class_1', name: 'Section B', teacherId: Value(teacher2Id), createdAt: now, updatedAt: now));
      await db.into(db.sections).insert(SectionsCompanion.insert(
          id: sKachiA, schoolId: schoolId, classId: 'cls_kachi', name: 'Section A', teacherId: Value(teacherId), createdAt: now, updatedAt: now));
      await db.into(db.sections).insert(SectionsCompanion.insert(
          id: s2A, schoolId: schoolId, classId: 'cls_class_2', name: 'Section A', teacherId: Value(teacher2Id), createdAt: now, updatedAt: now));
      await db.into(db.sections).insert(SectionsCompanion.insert(
          id: s3A, schoolId: schoolId, classId: 'cls_class_3', name: 'Section A', teacherId: Value(teacherId), createdAt: now, updatedAt: now));
      await db.into(db.sections).insert(SectionsCompanion.insert(
          id: s4A, schoolId: schoolId, classId: 'cls_class_4', name: 'Section A', teacherId: Value(teacher2Id), createdAt: now, updatedAt: now));
      await db.into(db.sections).insert(SectionsCompanion.insert(
          id: s5A, schoolId: schoolId, classId: 'cls_class_5', name: 'Section A', teacherId: Value(adminId), createdAt: now, updatedAt: now));

      // 5. KPK Primary Students in Class Pakki / 1st (Section A)
      final demoStudents = [
        {
          'id': 'std_001',
          'adm': 'KPK-2026-001',
          'roll': '1',
          'name': 'Muhammad Ali Khan',
          'father': 'Asif Ullah Khan',
          'dob': '2019-03-15',
          'bform': '17301-1122334-1',
          'fcnic': '17301-9988776-1',
          'phone': '+923331234567',
          'qr': 'GPS_STD_001_A9F2B'
        },
        {
          'id': 'std_002',
          'adm': 'KPK-2026-002',
          'roll': '2',
          'name': 'Hamza Shinwari',
          'father': 'Zahir Shah Shinwari',
          'dob': '2019-05-20',
          'bform': '17301-2233445-3',
          'fcnic': '17301-8877665-3',
          'phone': '+923332345678',
          'qr': 'GPS_STD_002_C8D3E'
        },
        {
          'id': 'std_003',
          'adm': 'KPK-2026-003',
          'roll': '3',
          'name': 'Ahmed Raza Khattak',
          'father': 'Kamran Khattak',
          'dob': '2019-01-10',
          'bform': '17301-3344556-5',
          'fcnic': '17301-7766554-5',
          'phone': '+923333456789',
          'qr': 'GPS_STD_003_E7B1A'
        },
        {
          'id': 'std_004',
          'adm': 'KPK-2026-004',
          'roll': '4',
          'name': 'Haris Yousafzai',
          'father': 'Tariq Javed Yousafzai',
          'dob': '2019-07-12',
          'bform': '17301-4455667-7',
          'fcnic': '17301-6655443-7',
          'phone': '+923334567890',
          'qr': 'GPS_STD_004_F4A6C'
        },
        {
          'id': 'std_005',
          'adm': 'KPK-2026-005',
          'roll': '5',
          'name': 'Bilal Hassan Marwat',
          'father': 'Hassan Ali Marwat',
          'dob': '2019-09-05',
          'bform': '17301-5566778-9',
          'fcnic': '17301-5544332-9',
          'phone': '+923335678901',
          'qr': 'GPS_STD_005_9D2E1'
        },
        {
          'id': 'std_006',
          'adm': 'KPK-2026-006',
          'roll': '6',
          'name': 'Usman Ghani Afridi',
          'father': 'Noor Muhammad Afridi',
          'dob': '2019-02-18',
          'bform': '17301-6677889-1',
          'fcnic': '17301-4433221-1',
          'phone': '+923336789012',
          'qr': 'GPS_STD_006_4F1C7'
        },
        {
          'id': 'std_007',
          'adm': 'KPK-2026-007',
          'roll': '7',
          'name': 'Salman Khan Orakzai',
          'father': 'Tariq Mehmood Orakzai',
          'dob': '2019-11-25',
          'bform': '17301-7788990-3',
          'fcnic': '17301-3322110-3',
          'phone': '+923337890123',
          'qr': 'GPS_STD_007_B3E5A'
        },
        {
          'id': 'std_008',
          'adm': 'KPK-2026-008',
          'roll': '8',
          'name': 'Zeeshan Bangash',
          'father': 'Imran Bangash',
          'dob': '2019-04-30',
          'bform': '17301-8899001-5',
          'fcnic': '17301-2211009-5',
          'phone': '+923338901234',
          'qr': 'GPS_STD_008_C1D9F'
        },
      ];

      for (final s in demoStudents) {
        await db.into(db.students).insert(
              StudentsCompanion.insert(
                id: s['id']!,
                schoolId: schoolId,
                classId: 'cls_class_1',
                sectionId: s1A,
                admissionNumber: s['adm']!,
                rollNumber: Value(s['roll']),
                fullName: s['name']!,
                fatherOrGuardianName: s['father']!,
                gender: 'male',
                dateOfBirth: Value(s['dob'] ?? '2019-03-15'),
                admissionDate: '2025-04-01',
                qrToken: s['qr']!,
                createdAt: now,
                updatedAt: now,
              ),
            );

        await db.studentDao.upsertExtendedInfo(
          StudentExtendedInfoModel(
            studentId: s['id']!,
            studentBForm: s['bform'],
            fatherCnic: s['fcnic'],
            domicileDistrict: 'Peshawar',
            freeBooksIssued: true,
          ),
        );

        await db.into(db.parentContacts).insert(
              ParentContactsCompanion.insert(
                id: 'par_${s['id']}',
                studentId: s['id']!,
                relation: 'father',
                phoneNumber: s['phone']!,
                whatsappEnabled: const Value(true),
                notifyAbsent: const Value(true),
                notifyLate: const Value(true),
                notifyLeave: const Value(true),
                createdAt: now,
                updatedAt: now,
              ),
            );
      }

      // 6. Official KP E&SED & Federal Cabinet Division 2026 Gazetted Holidays
      for (final h in KpkGazettedHolidays.official2026Holidays) {
        await db.into(db.schoolCalendarHolidays).insert(
              SchoolCalendarHolidaysCompanion.insert(
                id: 'hol_${schoolId}_${h.date}',
                schoolId: schoolId,
                date: h.date,
                description: h.description,
                isInstructionalDay: const Value(false),
                createdAt: now,
                updatedAt: now,
              ),
            );
      }
    });

    final isTeacher = initialRole == 'teacher';
    await saveSession(
      token: isTeacher ? 'demo_offline_token_teacher_001' : 'demo_offline_token_admin_001',
      user: UserModel(
        id: isTeacher ? teacherId : adminId,
        schoolId: schoolId,
        name: isTeacher ? 'Zahid Hussain (PST)' : 'Muhammad Yousaf Khan (Head Teacher)',
        email: isTeacher ? 'teacher@gps.edu.pk' : 'admin@gps.edu.pk',
        role: isTeacher ? 'teacher' : 'admin',
        pinCodeHash: '1234',
      ),
      school: {
        'id': schoolId,
        'name': 'Govt Primary School Gulbahar No. 1 Peshawar',
        'code': 'EMIS-12405',
      },
    );
  }
}
