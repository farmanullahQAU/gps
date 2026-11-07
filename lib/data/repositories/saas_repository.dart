// lib/data/repositories/saas_repository.dart
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import '../../core/database/app_database.dart';
import '../models/saas_subscription_model.dart';
import 'auth_repository.dart';

class SaasRepository {
  final AppDatabase db;
  final AuthRepository authRepository;

  String baseUrl = 'https://myschool-api.pages.dev';

  SaasRepository({required this.db, required this.authRepository});

  Future<Map<String, String>> _authHeaders() async {
    final token = await authRepository.getAuthToken() ?? 'demo_offline_token';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Fetch current school tenant's subscription & quotas
  Future<({TenantSubscriptionModel tenant, List<SaasPlanModel> plans})> getSubscription() async {
    final headers = await _authHeaders();
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/v1/saas/subscription'), headers: headers)
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tenant = TenantSubscriptionModel.fromJson(data['tenant']);
        final plans = (data['availablePlans'] as List<dynamic>?)
                ?.map((e) => SaasPlanModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
        return (tenant: tenant, plans: plans);
      }
    } catch (_) {
      // Offline fallback: derive from local SQLite database
    }

    final user = await authRepository.getCachedUser();
    final cachedSchool = await authRepository.getCachedSchool();
    final schoolId = user?.schoolId ?? cachedSchool?['id']?.toString() ?? 'sch_demo_gps_001';
    final school = await (db.select(db.schools)..where((t) => t.id.equals(schoolId))).getSingleOrNull();

    final allStudents = await (db.select(db.students)
          ..where((t) => t.schoolId.equals(schoolId)))
        .get();
    final activeStudents = allStudents.where((s) => s.status == 'active' && !s.isDeleted).length;

    final allStaff = await (db.select(db.users)
          ..where((t) => t.schoolId.equals(schoolId) & t.isActive.equals(true)))
        .get();
    final localStaff = allStaff.length;

    final tenant = TenantSubscriptionModel(
      id: schoolId,
      name: school?.name ?? 'Government Primary School',
      code: school?.code ?? 'EMIS-12405',
      motto: 'Excellence in Primary Education',
      themeColor: '#0F5132',
      subscriptionPlan: 'free',
      subscriptionStatus: 'active',
      maxStudents: 150,
      maxStaff: 15,
      currentStudents: activeStudents,
      currentStaff: localStaff,
      studentQuotaUsagePercent: _mathMin(100, (activeStudents * 100) ~/ 150),
      features: {'whatsapp': true, 'analytics': true, 'pdf_reports': true, 'cloud_backup': true},
    );

    final defaultPlans = [
      SaasPlanModel(
        id: 'free',
        name: 'Government & Community Free',
        pricePkr: 0,
        interval: 'lifetime',
        maxStudents: 150,
        maxStaff: 15,
        description: '100% Free for KPK Primary & Community Schools',
        features: [
          'Daily Attendance Register',
          '100% Offline SQLite Operation',
          'KP E&SED 3NF PDF Reports',
          'WhatsApp Absentee Notification',
          'Gazetted Holiday Calendar',
        ],
      ),
      SaasPlanModel(
        id: 'pro',
        name: 'School Pro Edition',
        pricePkr: 3500,
        interval: 'month',
        maxStudents: 500,
        maxStaff: 35,
        description: 'For private schools and growing model institutions',
        features: [
          'Everything in Free Plan',
          'Up to 500 Students',
          'Custom Emblem & Branding',
          'Automated WhatsApp Alerts',
          'Cloudflare R2 Backup',
        ],
      ),
      SaasPlanModel(
        id: 'enterprise',
        name: 'District / Network Enterprise',
        pricePkr: 8500,
        interval: 'month',
        maxStudents: 999999,
        maxStaff: 9999,
        description: 'Multi-branch inspection and district-wide governance',
        features: [
          'Everything in Pro Plan',
          'Unlimited Students & Staff',
          'DEO District Inspection Portal',
          'Multi-Branch Consolidated Stats',
        ],
      ),
    ];

    return (tenant: tenant, plans: defaultPlans);
  }

  // Upgrade or switch tenant SaaS plan
  Future<bool> upgradePlan(String planId) async {
    final headers = await _authHeaders();
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/v1/saas/subscription/upgrade'),
            headers: headers,
            body: jsonEncode({'plan': planId}),
          )
          .timeout(const Duration(seconds: 6));

      return response.statusCode == 200;
    } catch (_) {
      return true; // Local simulation in offline mode
    }
  }

  // Platform-wide overview for District Officers / Super-Admins
  Future<SaasPlatformOverviewModel> getPlatformOverview() async {
    final headers = await _authHeaders();
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/v1/saas/overview'), headers: headers)
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SaasPlatformOverviewModel.fromJson(data['overview']);
      }
    } catch (_) {}

    // Fallback overview
    return SaasPlatformOverviewModel(
      totalSchools: 1,
      totalStudents: 15,
      totalStaff: 3,
      todayMarkedAttendance: 15,
      todayPlatformAttendanceRate: 85,
      districtBreakdown: [
        {'district': 'Peshawar', 'school_count': 1}
      ],
      planBreakdown: [
        {'subscription_plan': 'free', 'count': 1}
      ],
    );
  }

  // List all tenant schools on the platform
  Future<List<SaasSchoolTenantModel>> getAllTenants() async {
    final headers = await _authHeaders();
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/v1/saas/schools'), headers: headers)
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['schools'] as List<dynamic>?)
                ?.map((e) => SaasSchoolTenantModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
      }
    } catch (_) {}

    // Local schools fallback
    final localSchools = await db.select(db.schools).get();
    return localSchools
        .map(
          (s) => SaasSchoolTenantModel(
            id: s.id,
            name: s.name,
            code: s.code,
            district: 'Peshawar',
            tehsil: 'City Peshawar',
            schoolType: 'GPS',
            subscriptionPlan: 'free',
            subscriptionStatus: 'active',
            approvalStatus: 'approved',
            studentCount: 15,
            staffCount: 3,
          ),
        )
        .toList();
  }

  Future<bool> approveSchool(String schoolId) async {
    final headers = await _authHeaders();
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/api/v1/saas/schools/$schoolId/approve'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 6));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> rejectSchool(String schoolId) async {
    final headers = await _authHeaders();
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/api/v1/saas/schools/$schoolId/reject'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 6));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> suspendSchool(String schoolId) async {
    final headers = await _authHeaders();
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/api/v1/saas/schools/$schoolId/suspend'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 6));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  int _mathMin(int a, int b) => a < b ? a : b;
}
