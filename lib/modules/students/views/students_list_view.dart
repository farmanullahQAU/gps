import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/class_picker_sheet.dart';
import '../../../core/widgets/student_avatar.dart';
import '../students_controller.dart';
import '../../attendance/attendance_controller.dart';
import 'student_id_card_view.dart';
import 'enroll_student_view.dart';
import 'whatsapp_parent_alert_view.dart';

class StudentsListView extends StatelessWidget {
  final bool showAppBar;
  const StudentsListView({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StudentsController>();
    final attendanceCtrl = Get.find<AttendanceController>();

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: showAppBar
          ? AppBar(
              title: const Text(
                'Students & QR ID Cards',
                style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800),
              ),
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              elevation: 0,
            )
          : null,
      body: Column(
        children: [
          // 1. Class Switcher Header, Search & Status Filter Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: Column(
              children: [
                Row(
                  children: [
                    // Precise, professional Class Selection Dropdown (No heavy background, just class name & chevron)
                    Obx(() {
                      final cls = attendanceCtrl.selectedClass.value?.name ?? 'Class';
                      final sec = attendanceCtrl.selectedSection.value?.name;
                      final label = sec == null ? cls : '$cls · $sec';

                      return InkWell(
                        onTap: () async {
                          await showClassPickerSheet(context, attendanceCtrl);
                          await controller.loadStudents();
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border, width: 1.2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                label,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_drop_down_rounded, size: 20, color: AppColors.textSecondary),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: TextField(
                          onChanged: (val) {
                            controller.searchQuery.value = val;
                            controller.loadStudents();
                          },
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Search roll, name, admission...',
                            hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            prefixIcon: const Icon(Icons.search_rounded, size: 18),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                            filled: true,
                            fillColor: AppColors.bgLight,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Obx(() => SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _statusChip(controller, 'active', 'Active Enrolled'),
                          _statusChip(controller, 'transferred', 'Transferred (SLC)'),
                          _statusChip(controller, 'graduated', 'Class 5 Graduated'),
                          _statusChip(controller, 'inactive', 'Struck Off'),
                          _statusChip(controller, 'all', 'All Records'),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // 2. Student List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.students.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline_rounded, size: 52, color: Colors.grey.shade400),
                        const SizedBox(height: 10),
                        const Text(
                          'No students found in this filter.\nUse the bottom bar to enroll or import students.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                itemCount: controller.students.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (ctx, index) {
                  final s = controller.students[index];
                  final isActive = s.status == 'active';

                  return Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _showStudentQuickViewSheet(context, controller, attendanceCtrl, s),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            // Avatar
                            StudentAvatar(
                              name: s.fullName,
                              photoUrl: s.photoUrl,
                              gender: s.gender,
                              radius: 22,
                              badgeText: s.rollNumber ?? '${index + 1}',
                              badgeColor: isActive ? AppColors.primaryDark : Colors.grey.shade600,
                            ),
                            const SizedBox(width: 12),

                            // Middle Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          s.fullName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                                        ),
                                      ),
                                      if (!isActive)
                                        Container(
                                          margin: const EdgeInsets.only(left: 6),
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEF3C7),
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: Text(
                                            s.status.toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF92400E),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'S/O: ${s.fatherOrGuardianName}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Action Buttons (Edit Profile + QR ID Card)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 19, color: AppColors.textSecondary),
                                  tooltip: 'Edit Student Profile',
                                  padding: const EdgeInsets.all(6),
                                  constraints: const BoxConstraints(),
                                  onPressed: () => Get.to(() => EnrollStudentView(studentToEdit: s)),
                                ),
                                const SizedBox(width: 6),
                                InkWell(
                                  onTap: () {
                                    final className = attendanceCtrl.selectedClass.value?.name ?? 'Class 1';
                                    final sectionName = attendanceCtrl.selectedSection.value?.name ?? 'Section A';

                                    Get.to(() => StudentIdCardView(
                                          student: s,
                                          schoolName: 'Govt Primary School Gulbahar No. 1 Peshawar',
                                          className: className,
                                          sectionName: sectionName,
                                        ));
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.qr_code_2_rounded, size: 15, color: AppColors.primaryDark),
                                        SizedBox(width: 4),
                                        Text(
                                          'ID',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primaryDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),

          // 3. Sticky Bottom Action Bar (CSV Import + Enroll Student)
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              10,
              16,
              MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 46,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryDark,
                        side: const BorderSide(color: AppColors.border, width: 1.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.upload_file_rounded, size: 18),
                      label: const Text(
                        'CSV Import',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
                      ),
                      onPressed: () => _showBulkCsvImportSheet(context, controller),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 5,
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.person_add_alt_1_rounded, size: 19),
                      label: const Text(
                        'Enroll New Student',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                      ),
                      onPressed: () => Get.to(() => const EnrollStudentView()),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(StudentsController controller, String statusKey, String label) {
    final isSelected = controller.statusFilter.value == statusKey;
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: InkWell(
        onTap: () {
          controller.statusFilter.value = statusKey;
          controller.loadStudents();
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryDark : AppColors.bgLight,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? AppColors.primaryDark : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  /// Professional Student Details Quick-View Bottom Sheet
  void _showStudentQuickViewSheet(
    BuildContext context,
    StudentsController controller,
    AttendanceController attendanceCtrl,
    Student student,
  ) {
    final className = attendanceCtrl.selectedClass.value?.name ?? 'Class';
    final sectionName = attendanceCtrl.selectedSection.value?.name ?? 'Section A';
    final isActive = student.status == 'active';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle pill
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header with Avatar and Basic Info
                  Row(
                    children: [
                      StudentAvatar(
                        name: student.fullName,
                        photoUrl: student.photoUrl,
                        gender: student.gender,
                        radius: 34,
                        badgeText: student.rollNumber,
                        badgeColor: isActive ? AppColors.primaryDark : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.fullName,
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'S/O: ${student.fatherOrGuardianName}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '$className • $sectionName',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isActive ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    student.status.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: isActive ? const Color(0xFF166534) : const Color(0xFF92400E),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Information Cards
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        _infoRow('Admission Number', student.admissionNumber, icon: Icons.badge_outlined),
                        const Divider(height: 18, color: Color(0xFFE2E8F0)),
                        _infoRow('Roll Number', student.rollNumber ?? 'Not Assigned', icon: Icons.format_list_numbered_rounded),
                        const Divider(height: 18, color: Color(0xFFE2E8F0)),
                        _infoRow('Date of Admission', student.admissionDate, icon: Icons.calendar_today_rounded),
                        const Divider(height: 18, color: Color(0xFFE2E8F0)),
                        _infoRow('Date of Birth', student.dateOfBirth ?? 'Not Recorded', icon: Icons.cake_outlined),
                        const Divider(height: 18, color: Color(0xFFE2E8F0)),
                        _infoRow('Student B-Form / CNIC', student.studentCnic ?? 'Not Provided', icon: Icons.credit_card_rounded),
                        const Divider(height: 18, color: Color(0xFFE2E8F0)),
                        _infoRow('Father CNIC', student.fatherCnic ?? 'Not Provided', icon: Icons.person_outline_rounded),
                        const Divider(height: 18, color: Color(0xFFE2E8F0)),
                        _infoRow(
                          'Vaccination',
                          student.isVaccinated ? 'Immunized ✓' : 'Not Recorded',
                          icon: Icons.health_and_safety_outlined,
                          valueColor: student.isVaccinated ? const Color(0xFF16A34A) : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Action Row: Quick Navigation (Edit Profile & QR ID Card)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryDark,
                            side: const BorderSide(color: AppColors.primaryDark),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.edit_outlined, size: 17),
                          label: const Text(
                            'Edit Profile',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            Get.to(() => EnrollStudentView(studentToEdit: student));
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryDark,
                            side: const BorderSide(color: AppColors.primaryDark),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.qr_code_2_rounded, size: 18),
                          label: const Text(
                            'QR ID Card',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            Get.to(() => StudentIdCardView(
                                  student: student,
                                  schoolName: 'Govt Primary School Gulbahar No. 1 Peshawar',
                                  className: className,
                                  sectionName: sectionName,
                                ));
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Action: WhatsApp Parent (Clean, focused single action)
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.chat_rounded, size: 19),
                      label: const Text(
                        'Send WhatsApp to Parent',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        Get.to(() => WhatsAppParentAlertView(
                              student: student,
                              className: className,
                              initialType: 'absent',
                            ));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value, {required IconData icon, Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  void _showBulkCsvImportSheet(BuildContext context, StudentsController controller) {
    final csvCtrl = TextEditingController();
    String? pickedFileName;
    int pickedRowCount = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Import Student Roster',
                      style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Upload an Excel/CSV file from your phone storage or paste rows below.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),

                // 1. Phone Storage File Picker Button
                InkWell(
                  onTap: () async {
                    try {
                      final file = await FilePicker.pickFile(
                        type: FileType.custom,
                        allowedExtensions: ['csv', 'txt'],
                      );

                      if (file != null && file.path != null) {
                        final ioFile = File(file.path!);
                        final content = await ioFile.readAsString();
                        final lineCount = content
                            .split(RegExp(r'\r?\n'))
                            .where((l) => l.trim().isNotEmpty)
                            .length;

                        setModalState(() {
                          pickedFileName = file.name;
                          pickedRowCount = lineCount;
                          csvCtrl.text = content;
                        });

                        Get.snackbar(
                          'File Loaded',
                          'Loaded ${file.name} ($lineCount lines ready to import).',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFFDCFCE7),
                          colorText: const Color(0xFF166534),
                        );
                      }
                    } catch (e) {
                      Get.snackbar(
                        'File Error',
                        'Could not read file: $e',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: pickedFileName != null ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: pickedFileName != null ? const Color(0xFF86EFAC) : const Color(0xFFCBD5E1),
                        width: 1.4,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: pickedFileName != null ? const Color(0xFFDCFCE7) : AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            pickedFileName != null ? Icons.check_circle_rounded : Icons.file_open_rounded,
                            color: pickedFileName != null ? const Color(0xFF16A34A) : AppColors.primaryDark,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pickedFileName ?? 'Select File from Phone Storage',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: pickedFileName != null ? const Color(0xFF166534) : AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                pickedFileName != null
                                    ? '$pickedRowCount lines detected • Tap to choose another file'
                                    : 'Supported: .csv and exported spreadsheet text files',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: pickedFileName != null ? const Color(0xFF15803D) : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                const Row(
                  children: [
                    Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'OR PASTE DATA',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8)),
                      ),
                    ),
                    Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                  ],
                ),

                const SizedBox(height: 10),

                const Text(
                  'Expected CSV Format / Columns:',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 3),
                const Text(
                  'AdmissionNo, RollNo, FullName, FatherName, Gender, Phone, BForm',
                  style: TextStyle(fontSize: 10.5, fontFamily: 'monospace', color: Color(0xFF0F766E), fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),

                TextField(
                  controller: csvCtrl,
                  maxLines: 4,
                  style: const TextStyle(fontSize: 11.5, fontFamily: 'monospace'),
                  decoration: InputDecoration(
                    hintText: 'Paste CSV rows here...\n'
                        'KPK-2026-101, 1, Muhammad Ali, Tariq Mehmood, male, +923001234567, 17301-1010101-1\n'
                        'KPK-2026-102, 2, Fatima Bibi, Abdul Rasheed, female, +923001234568, 17301-2020202-3',
                    hintStyle: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: const Color(0xFFFAFAFA),
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.upload_file_rounded, size: 20),
                    label: const Text(
                      'Import & Register Students',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                    ),
                    onPressed: () async {
                      final raw = csvCtrl.text.trim();
                      if (raw.isEmpty) {
                        Get.snackbar('Input Required', 'Please choose a file or paste CSV rows to import.');
                        return;
                      }
                      Navigator.pop(ctx);
                      await controller.importStudentsFromCsv(raw);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
