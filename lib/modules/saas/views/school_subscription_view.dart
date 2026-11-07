// lib/modules/saas/views/school_subscription_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../saas_controller.dart';

class SchoolSubscriptionView extends StatelessWidget {
  const SchoolSubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SaasController>();

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('SaaS Subscription & Quotas', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => controller.loadSubscription(),
            tooltip: 'Refresh Quotas',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.tenantSubscription.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final tenant = controller.tenantSubscription.value;
        if (tenant == null) {
          return const Center(child: Text('Subscription data unavailable'));
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadSubscription(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Current Tenant Badge Card
                _buildCurrentTenantCard(tenant),

                const SizedBox(height: 18),

                // 2. Resource Quotas Section
                const Text(
                  'Tenant Resource Quotas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 10),
                _buildQuotaCard(
                  title: 'Student Enrollment Limit',
                  current: tenant.currentStudents,
                  max: tenant.maxStudents,
                  unit: 'Students',
                  icon: Icons.groups_rounded,
                  color: const Color(0xFF2563EB),
                ),
                const SizedBox(height: 10),
                _buildQuotaCard(
                  title: 'Faculty & Staff Limit',
                  current: tenant.currentStaff,
                  max: tenant.maxStaff,
                  unit: 'Staff Accounts',
                  icon: Icons.badge_rounded,
                  color: const Color(0xFF7C3AED),
                ),

                const SizedBox(height: 22),

                // 3. Unlocked SaaS Capabilities
                const Text(
                  'Included SaaS Capabilities',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 10),
                _buildFeaturesGrid(),

                const SizedBox(height: 24),

                // 4. Subscription Plan Comparison & Upgrade
                const Text(
                  'Available SaaS Plans',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Flexible multi-tenant licensing for private, model, and public schools',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),

                ...controller.availablePlans.map((plan) {
                  final isCurrent = tenant.subscriptionPlan == plan.id;
                  return _buildPlanCard(context, controller, plan, isCurrent);
                }),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCurrentTenantCard(dynamic tenant) {
    Color badgeColor;
    String badgeText;
    switch (tenant.subscriptionPlan) {
      case 'pro':
        badgeColor = const Color(0xFF2563EB);
        badgeText = 'PRO EDITION';
        break;
      case 'enterprise':
        badgeColor = const Color(0xFF7C3AED);
        badgeText = 'ENTERPRISE DEO';
        break;
      default:
        badgeColor = const Color(0xFF16A34A);
        badgeText = 'COMMUNITY FREE';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F5132), Color(0xFF064E3B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 13, color: Color(0xFF86EFAC)),
                    const SizedBox(width: 4),
                    Text(
                      tenant.subscriptionStatus.toString().toUpperCase(),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            tenant.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 3),
          Text(
            'Tenant EMIS: ${tenant.code} • ${tenant.motto}',
            style: const TextStyle(fontSize: 12, color: Color(0xFFD1FAE5)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuotaCard({
    required String title,
    required int current,
    required int max,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    final double percent = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;
    final bool isNearLimit = percent >= 0.85;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                      '$current of $max $unit used (${(percent * 100).round()}%)',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isNearLimit ? AppColors.absent : AppColors.textSecondary,
                        fontWeight: isNearLimit ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${max - current} left',
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 7,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(
                isNearLimit ? AppColors.absent : color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesGrid() {
    final items = [
      ('100% Offline SQLite Attendance', Icons.wifi_off_rounded, 'Works seamlessly without internet in rural schools'),
      ('Cloudflare D1 & WAL Delta Sync', Icons.cloud_sync_rounded, 'Automatic background sync when connectivity restores'),
      ('Official KP E&SED 3NF PDF Registers', Icons.picture_as_pdf_rounded, 'Monthly & daily government standardized reports'),
      ('WhatsApp Absentee Notifications', Icons.chat_rounded, '1-tap parental WhatsApp notices with zero SMS gateway cost'),
      ('Individual Staff Authentication', Icons.fingerprint_rounded, 'Secure PBKDF2 individual logins with 4-digit PIN unlock'),
      ('KPK Gazetted Holiday System', Icons.event_available_rounded, 'Automatic non-instructional day scheduling'),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: items.map((f) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(f.$1, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      Text(f.$3, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    SaasController controller,
    dynamic plan,
    bool isCurrent,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent ? AppColors.primary : AppColors.border,
          width: isCurrent ? 2 : 1,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                plan.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'CURRENT PLAN',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                plan.pricePkr == 0 ? 'FREE' : 'PKR ${plan.pricePkr}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: plan.pricePkr == 0 ? const Color(0xFF16A34A) : AppColors.primaryDark,
                ),
              ),
              if (plan.pricePkr > 0)
                Text(
                  ' / ${plan.interval}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(plan.description, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 6),
          ...plan.features.map<Widget>((feature) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3.5),
              child: Row(
                children: [
                  const Icon(Icons.done_rounded, size: 15, color: Color(0xFF16A34A)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature.toString(),
                      style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 16),
          if (!isCurrent)
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: controller.isUpgrading.value
                    ? null
                    : () async {
                        await controller.upgradePlan(plan.id);
                      },
                child: Text(
                  'UPGRADE TO ${plan.name.toUpperCase()}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
