import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../modules/admin/admin_controller.dart';
import '../../modules/attendance/attendance_controller.dart';
import '../../modules/auth/auth_controller.dart';
import '../database/app_database.dart';
import '../theme/app_theme.dart';

/// Shared bottom sheet for choosing the active class (Kachi – Class 5).
Future<void> showClassPickerSheet(BuildContext context, AttendanceController controller) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.75,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Obx(() {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Class',
                        style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${controller.classesList.length} Classes',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: controller.classesList.map((c) {
                          final isSelected = controller.selectedClass.value?.id == c.id;
                          final count = controller.classEnrollmentMap[c.id] ?? 0;
                          final fmName = controller.classFormMasterNameMap[c.id] ?? 'Unassigned';
                          final auth = Get.find<AuthController>();
                          final user = auth.currentUser.value;
                          final isAdmin = user?.isAdmin ?? false;
                          final isMyClass = !isAdmin && (controller.classFormMasterIdMap[c.id] == user?.id);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 7),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFF8FAFC) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.border,
                                width: isSelected ? 1.6 : 1.0,
                              ),
                            ),
                            child: InkWell(
                              onTap: () async {
                                Navigator.pop(ctx);
                                await controller.switchClassById(c.id);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                child: Row(
                                  children: [
                                    // Class Badge
                                    Container(
                                      width: 36,
                                      height: 36,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isSelected ? AppColors.primary : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(9),
                                      ),
                                      child: Text(
                                        c.numericLevel == 0 ? 'K' : '${c.numericLevel}',
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w900,
                                          color: isSelected ? Colors.white : AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Title and Form Master
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            c.name,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            isMyClass ? 'Form Master: You' : 'Form Master: $fmName',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              color: isMyClass ? const Color(0xFF166534) : AppColors.textSecondary,
                                              fontWeight: isMyClass ? FontWeight.w600 : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Notification badge for student count
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                                      decoration: BoxDecoration(
                                        color: count > 0 ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: count > 0 ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.people_outline_rounded,
                                            size: 13,
                                            color: count > 0 ? const Color(0xFF1E40AF) : AppColors.textMuted,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '$count',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              color: count > 0 ? const Color(0xFF1E40AF) : AppColors.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected) ...[
                                      const SizedBox(width: 6),
                                      const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      );
    },
  );
}








/// Bottom sheet for Head Teacher (Admin) to assign or change a class's Form Master.
Future<void> showAssignFormMasterSheet(BuildContext context, ClassesData cls) async {
  final authCtrl = Get.find<AuthController>();
  final isAdmin = authCtrl.currentUser.value?.isAdmin ?? false;
  if (!isAdmin) {
    Get.snackbar(
      'Head Teacher Permission Required',
      'Only the Head Teacher can assign or change class Form Masters.',
    );
    return;
  }

  final adminCtrl = Get.find<AdminController>();
  final attCtrl = Get.find<AttendanceController>();
  if (adminCtrl.teachers.isEmpty) {
    await adminCtrl.loadAllAdminData();
  }
  if (!context.mounted) return;

  final currentTeacherId = attCtrl.classFormMasterIdMap[cls.id];

  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Obx(() {
            final teachers = adminCtrl.teachers;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 2),
                  child: Text(
                    'Assign Form Master — ${cls.name}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 12),
                  child: Text(
                    'Select the teacher responsible for daily attendance & records for this class:',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
                ...teachers.map((t) {
                  final isAssigned = t.id == currentTeacherId;
                  final isHT = t.role == 'admin';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: isAssigned ? AppColors.primaryLight : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isAssigned ? AppColors.primary.withValues(alpha: 0.4) : AppColors.border,
                        width: isAssigned ? 1.5 : 1,
                      ),
                    ),
                    child: ListTile(
                      dense: true,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: isAssigned ? AppColors.primaryDark : const Color(0xFFF1F5F9),
                        child: Icon(
                          isHT ? Icons.admin_panel_settings_rounded : Icons.person_rounded,
                          size: 18,
                          color: isAssigned ? Colors.white : AppColors.primaryDark,
                        ),
                      ),
                      title: Text(
                        t.name,
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      subtitle: Text(
                        isHT ? 'Administrator / Head Teacher' : (t.designation ?? 'Teacher'),
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      trailing: isAssigned
                          ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryDark, size: 22)
                          : Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.bgLight,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Text(
                                'Assign',
                                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                              ),
                            ),
                      onTap: () async {
                        Navigator.pop(ctx);
                        await adminCtrl.assignClassFormMaster(
                          classId: cls.id,
                          className: cls.name,
                          teacherId: t.id,
                          teacherName: t.name,
                        );
                      },
                    ),
                  );
                }),
              ],
            );
          }),
        ),
      );
    },
  );
}
