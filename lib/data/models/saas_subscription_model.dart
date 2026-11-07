// lib/data/models/saas_subscription_model.dart

class TenantSubscriptionModel {
  final String id;
  final String name;
  final String code;
  final String motto;
  final String themeColor;
  final String subscriptionPlan; // 'free' | 'pro' | 'enterprise'
  final String subscriptionStatus; // 'active' | 'trial' | 'past_due'
  final int maxStudents;
  final int maxStaff;
  final int currentStudents;
  final int currentStaff;
  final int studentQuotaUsagePercent;
  final Map<String, dynamic> features;

  TenantSubscriptionModel({
    required this.id,
    required this.name,
    required this.code,
    required this.motto,
    required this.themeColor,
    required this.subscriptionPlan,
    required this.subscriptionStatus,
    required this.maxStudents,
    required this.maxStaff,
    required this.currentStudents,
    required this.currentStaff,
    required this.studentQuotaUsagePercent,
    required this.features,
  });

  bool get isPro => subscriptionPlan == 'pro';
  bool get isEnterprise => subscriptionPlan == 'enterprise';
  bool get isFree => subscriptionPlan == 'free';

  factory TenantSubscriptionModel.fromJson(Map<String, dynamic> json) => TenantSubscriptionModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? 'School',
        code: json['code'] as String? ?? 'EMIS',
        motto: json['motto'] as String? ?? 'Excellence in Primary Education',
        themeColor: json['themeColor'] as String? ?? '#0F5132',
        subscriptionPlan: json['subscriptionPlan'] as String? ?? 'free',
        subscriptionStatus: json['subscriptionStatus'] as String? ?? 'active',
        maxStudents: json['maxStudents'] as int? ?? 150,
        maxStaff: json['maxStaff'] as int? ?? 15,
        currentStudents: json['currentStudents'] as int? ?? 0,
        currentStaff: json['currentStaff'] as int? ?? 0,
        studentQuotaUsagePercent: json['studentQuotaUsagePercent'] as int? ?? 0,
        features: json['features'] as Map<String, dynamic>? ?? {},
      );
}

class SaasPlanModel {
  final String id;
  final String name;
  final int pricePkr;
  final String interval;
  final int maxStudents;
  final int maxStaff;
  final String description;
  final List<String> features;

  SaasPlanModel({
    required this.id,
    required this.name,
    required this.pricePkr,
    required this.interval,
    required this.maxStudents,
    required this.maxStaff,
    required this.description,
    required this.features,
  });

  factory SaasPlanModel.fromJson(Map<String, dynamic> json) => SaasPlanModel(
        id: json['id'] as String? ?? 'free',
        name: json['name'] as String? ?? 'Free',
        pricePkr: json['pricePkr'] as int? ?? 0,
        interval: json['interval'] as String? ?? 'lifetime',
        maxStudents: json['maxStudents'] as int? ?? 150,
        maxStaff: json['maxStaff'] as int? ?? 15,
        description: json['description'] as String? ?? '',
        features: (json['features'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      );
}

class SaasPlatformOverviewModel {
  final int totalSchools;
  final int totalStudents;
  final int totalStaff;
  final int todayMarkedAttendance;
  final int todayPlatformAttendanceRate;
  final List<Map<String, dynamic>> districtBreakdown;
  final List<Map<String, dynamic>> planBreakdown;

  SaasPlatformOverviewModel({
    required this.totalSchools,
    required this.totalStudents,
    required this.totalStaff,
    required this.todayMarkedAttendance,
    required this.todayPlatformAttendanceRate,
    required this.districtBreakdown,
    required this.planBreakdown,
  });

  factory SaasPlatformOverviewModel.fromJson(Map<String, dynamic> json) => SaasPlatformOverviewModel(
        totalSchools: json['totalSchools'] as int? ?? 0,
        totalStudents: json['totalStudents'] as int? ?? 0,
        totalStaff: json['totalStaff'] as int? ?? 0,
        todayMarkedAttendance: json['todayMarkedAttendance'] as int? ?? 0,
        todayPlatformAttendanceRate: json['todayPlatformAttendanceRate'] as int? ?? 0,
        districtBreakdown: (json['districtBreakdown'] as List<dynamic>?)
                ?.map((e) => e as Map<String, dynamic>)
                .toList() ??
            [],
        planBreakdown: (json['planBreakdown'] as List<dynamic>?)
                ?.map((e) => e as Map<String, dynamic>)
                .toList() ??
            [],
      );
}

class SaasSchoolTenantModel {
  final String id;
  final String name;
  final String code;
  final String district;
  final String tehsil;
  final String schoolType;
  final String subscriptionPlan;
  final String subscriptionStatus;
  final String approvalStatus;
  final int studentCount;
  final int staffCount;

  bool get isApproved => approvalStatus.toLowerCase() == 'approved';
  bool get isPending => approvalStatus.toLowerCase() == 'pending' || approvalStatus.toLowerCase() == 'pending_approval';
  bool get isSuspended => approvalStatus.toLowerCase() == 'suspended';
  bool get isRejected => approvalStatus.toLowerCase() == 'rejected';

  SaasSchoolTenantModel({
    required this.id,
    required this.name,
    required this.code,
    required this.district,
    required this.tehsil,
    required this.schoolType,
    required this.subscriptionPlan,
    required this.subscriptionStatus,
    this.approvalStatus = 'approved',
    required this.studentCount,
    required this.staffCount,
  });

  factory SaasSchoolTenantModel.fromJson(Map<String, dynamic> json) => SaasSchoolTenantModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        code: json['code'] as String? ?? '',
        district: json['district'] as String? ?? 'Peshawar',
        tehsil: json['tehsil'] as String? ?? 'City Peshawar',
        schoolType: json['school_type'] as String? ?? 'GPS',
        subscriptionPlan: json['subscription_plan'] as String? ?? 'free',
        subscriptionStatus: json['subscription_status'] as String? ?? 'active',
        approvalStatus: json['approval_status'] as String? ?? 'approved',
        studentCount: json['student_count'] as int? ?? 0,
        staffCount: json['staff_count'] as int? ?? 0,
      );
}
