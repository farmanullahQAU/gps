import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/class_picker_sheet.dart';
import '../../../core/widgets/student_avatar.dart';
import '../students_controller.dart';
import '../../attendance/attendance_controller.dart';
import 'student_id_card_view.dart';

/// Highly Professional, Unified Student Enrollment & Edit Profile Screen
/// Supports both:
/// 1. New student enrollment (with auto-generated KPK admission & roll numbers)
/// 2. Editing existing student (pre-populated, status switching, historical attendance preservation)
/// 3. Student Avatar / Photo picker with Camera & Gallery options.
class EnrollStudentView extends StatefulWidget {
  final Student? studentToEdit;

  const EnrollStudentView({super.key, this.studentToEdit});

  @override
  State<EnrollStudentView> createState() => _EnrollStudentViewState();
}

class _EnrollStudentViewState extends State<EnrollStudentView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _admissionCtrl;
  late TextEditingController _rollCtrl;
  late TextEditingController _nameCtrl;
  late TextEditingController _fatherCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _bFormCtrl;
  late TextEditingController _fatherCnicCtrl;
  late TextEditingController _admissionDateCtrl;
  late TextEditingController _dobCtrl;
  late TextEditingController _firstDoseCtrl;
  late TextEditingController _secondDoseCtrl;
  late TextEditingController _slcCtrl;

  String _gender = 'male';
  String _status = 'active'; // 'active', 'transferred', 'graduated', 'inactive'
  bool _isVaccinated = false;
  bool _isSubmitting = false;
  String? _photoPath;

  bool get isEditing => widget.studentToEdit != null;

  @override
  void initState() {
    super.initState();
    final studentsCtrl = Get.find<StudentsController>();
    final s = widget.studentToEdit;

    if (s != null) {
      _admissionCtrl = TextEditingController(text: s.admissionNumber);
      _rollCtrl = TextEditingController(text: s.rollNumber ?? '');
      _nameCtrl = TextEditingController(text: s.fullName);
      _fatherCtrl = TextEditingController(text: s.fatherOrGuardianName);
      _bFormCtrl = TextEditingController(text: s.studentCnic ?? '');
      _fatherCnicCtrl = TextEditingController(text: s.fatherCnic ?? '');
      _admissionDateCtrl = TextEditingController(text: s.admissionDate);
      _dobCtrl = TextEditingController(text: s.dateOfBirth ?? '');
      _firstDoseCtrl = TextEditingController(text: s.vaccineFirstDoseDate ?? '');
      _secondDoseCtrl = TextEditingController(text: s.vaccineSecondDoseDate ?? '');
      _slcCtrl = TextEditingController();
      _phoneCtrl = TextEditingController();

      _gender = s.gender.toLowerCase() == 'female' ? 'female' : 'male';
      _status = s.status;
      _isVaccinated = s.isVaccinated;
      _photoPath = s.photoUrl;

      // Asynchronously fetch parent phone for pre-filling
      studentsCtrl.studentRepository.getParentContact(s.id).then((parent) {
        if (mounted && parent != null && parent.phoneNumber.isNotEmpty) {
          _phoneCtrl.text = parent.phoneNumber;
        }
      });
    } else {
      final count = studentsCtrl.students.length;
      final nextAdmNum = 'KPK-${DateTime.now().year}-${(count + 1).toString().padLeft(3, '0')}';
      final nextRoll = '${count + 1}';
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

      _admissionCtrl = TextEditingController(text: nextAdmNum);
      _rollCtrl = TextEditingController(text: nextRoll);
      _nameCtrl = TextEditingController();
      _fatherCtrl = TextEditingController();
      _phoneCtrl = TextEditingController(text: '+923');
      _bFormCtrl = TextEditingController();
      _fatherCnicCtrl = TextEditingController();
      _admissionDateCtrl = TextEditingController(text: todayStr);
      _dobCtrl = TextEditingController();
      _firstDoseCtrl = TextEditingController();
      _secondDoseCtrl = TextEditingController();
      _slcCtrl = TextEditingController();
      _gender = 'male';
      _status = 'active';
      _isVaccinated = false;
      _photoPath = null;
    }
  }

  @override
  void dispose() {
    _admissionCtrl.dispose();
    _rollCtrl.dispose();
    _nameCtrl.dispose();
    _fatherCtrl.dispose();
    _phoneCtrl.dispose();
    _bFormCtrl.dispose();
    _fatherCnicCtrl.dispose();
    _admissionDateCtrl.dispose();
    _dobCtrl.dispose();
    _firstDoseCtrl.dispose();
    _secondDoseCtrl.dispose();
    _slcCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() => _photoPath = picked.path);
      }
    } catch (e) {
      Get.snackbar(
        'Photo Selection',
        'Could not access image: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Student Profile Photo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF2563EB)),
                ),
                title: const Text('Take Photo with Camera', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: Color(0xFF16A34A)),
                ),
                title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_photoPath != null)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626)),
                  ),
                  title: const Text('Remove Photo', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: Color(0xFFDC2626))),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _photoPath = null);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final studentsCtrl = Get.find<StudentsController>();
    final attendanceCtrl = Get.find<AttendanceController>();

    final cls = attendanceCtrl.selectedClass.value;
    final sec = attendanceCtrl.selectedSection.value;
    if (cls == null || sec == null) {
      Get.snackbar(
        'Class Selection Required',
        'Please select a class and section before saving student profile.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.amber.shade900,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      if (isEditing) {
        final existing = widget.studentToEdit!;
        final success = await studentsCtrl.updateExistingStudent(
          existing: existing,
          classId: cls.id,
          sectionId: sec.id,
          admissionNumber: _admissionCtrl.text.trim(),
          rollNumber: _rollCtrl.text.trim().isEmpty ? null : _rollCtrl.text.trim(),
          fullName: _nameCtrl.text.trim(),
          fatherName: _fatherCtrl.text.trim(),
          gender: _gender,
          dateOfBirth: _dobCtrl.text.trim().isEmpty ? null : _dobCtrl.text.trim(),
          status: _status,
          parentPhone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
          studentCnic: _bFormCtrl.text.trim().isEmpty ? null : _bFormCtrl.text.trim(),
          studentBForm: _bFormCtrl.text.trim().isEmpty ? null : _bFormCtrl.text.trim(),
          fatherCnic: _fatherCnicCtrl.text.trim().isEmpty ? null : _fatherCnicCtrl.text.trim(),
          photoUrl: _photoPath,
          isVaccinated: _isVaccinated,
          vaccineFirstDoseDate: _firstDoseCtrl.text.trim().isEmpty ? null : _firstDoseCtrl.text.trim(),
          vaccineSecondDoseDate: _secondDoseCtrl.text.trim().isEmpty ? null : _secondDoseCtrl.text.trim(),
          slcNumber: _slcCtrl.text.trim().isEmpty ? null : _slcCtrl.text.trim(),
        );

        if (success && mounted) {
          Get.back();
        }
      } else {
        final success = await studentsCtrl.registerStudent(
          admissionNumber: _admissionCtrl.text.trim(),
          rollNumber: _rollCtrl.text.trim().isEmpty ? null : _rollCtrl.text.trim(),
          fullName: _nameCtrl.text.trim(),
          fatherName: _fatherCtrl.text.trim(),
          gender: _gender,
          dateOfBirth: _dobCtrl.text.trim().isEmpty ? null : _dobCtrl.text.trim(),
          admissionDate: _admissionDateCtrl.text.trim(),
          parentPhone: _phoneCtrl.text.trim(),
          studentCnic: _bFormCtrl.text.trim().isEmpty ? null : _bFormCtrl.text.trim(),
          studentBForm: _bFormCtrl.text.trim().isEmpty ? null : _bFormCtrl.text.trim(),
          fatherCnic: _fatherCnicCtrl.text.trim().isEmpty ? null : _fatherCnicCtrl.text.trim(),
          photoUrl: _photoPath,
          isVaccinated: _isVaccinated,
          vaccineFirstDoseDate: _firstDoseCtrl.text.trim().isEmpty ? null : _firstDoseCtrl.text.trim(),
          vaccineSecondDoseDate: _secondDoseCtrl.text.trim().isEmpty ? null : _secondDoseCtrl.text.trim(),
        );

        if (success && mounted) {
          final newStudent = studentsCtrl.students.firstWhereOrNull(
            (s) => s.admissionNumber.toLowerCase() == _admissionCtrl.text.trim().toLowerCase(),
          );

          Get.back();

          if (newStudent != null) {
            Get.to(() => StudentIdCardView(
                  student: newStudent,
                  schoolName: 'Govt Primary School Gulbahar No. 1 Peshawar',
                  className: cls.name,
                  sectionName: sec.name,
                ));
          }
        }
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendanceCtrl = Get.find<AttendanceController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Student Profile' : 'Student Admission & Enrollment',
          style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800),
        ),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: isEditing ? const Color(0xFF0F766E) : AppColors.primaryDark,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Icon(isEditing ? Icons.check_circle_rounded : Icons.qr_code_2_rounded, size: 20),
            label: Text(
              _isSubmitting
                  ? (isEditing ? 'Saving Changes...' : 'Registering Student...')
                  : (isEditing ? 'Save Changes & Update Record' : 'Enroll & Generate QR ID Badge'),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
            ),
            onPressed: _isSubmitting ? null : _submitForm,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
          children: [
            // -------------------------------------------------------------
            // Photo & Quick Avatar Card
            // -------------------------------------------------------------
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  GestureDetector(
                    onTap: _showPhotoOptions,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: StudentAvatar(
                        name: _nameCtrl.text.isNotEmpty ? _nameCtrl.text : 'Student',
                        photoUrl: _photoPath,
                        gender: _gender,
                        radius: 46,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: _showPhotoOptions,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: _showPhotoOptions,
                icon: const Icon(Icons.add_a_photo_outlined, size: 16),
                label: Text(
                  _photoPath == null ? 'Add Student Photo' : 'Change Photo',
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // -------------------------------------------------------------
            // Class & Section Selector Card
            // -------------------------------------------------------------
            Obx(() {
              final cls = attendanceCtrl.selectedClass.value?.name ?? 'Select Class';
              final sec = attendanceCtrl.selectedSection.value?.name;
              final formMaster = attendanceCtrl.currentClassFormMaster;

              return InkWell(
                onTap: () => showClassPickerSheet(context, attendanceCtrl),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: const Icon(Icons.school_rounded, color: AppColors.primaryDark, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ASSIGNED CLASS & SECTION',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF64748B),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              sec == null ? cls : '$cls • $sec',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              'Form Master: $formMaster',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F5132),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Switch',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF475569),
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(Icons.unfold_more_rounded, size: 15, color: Color(0xFF64748B)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),

            // -------------------------------------------------------------
            // Section 1: Academic & Register Credentials
            // -------------------------------------------------------------
            _sectionLabel(
              icon: Icons.app_registration_rounded,
              color: const Color(0xFF2563EB),
              title: 'Academic Credentials',
              urdu: 'داخلہ و حاضری نمبر',
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: _cardStyle(),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _fieldWrapper(
                          label: 'Admission Number *',
                          child: TextFormField(
                            controller: _admissionCtrl,
                            textCapitalization: TextCapitalization.characters,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            decoration: _fieldDeco(hint: 'e.g. KPK-2026-001'),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: _fieldWrapper(
                          label: 'Roll No',
                          child: TextFormField(
                            controller: _rollCtrl,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            decoration: _fieldDeco(hint: 'e.g. 1'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _fieldWrapper(
                    label: 'Date of Admission',
                    child: TextFormField(
                      controller: _admissionDateCtrl,
                      readOnly: true,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(DateTime.now().year - 10),
                          lastDate: DateTime.now(),
                          helpText: 'Select Admission Date',
                        );
                        if (picked != null) {
                          _admissionDateCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
                        }
                      },
                      decoration: _fieldDeco(
                        suffixIcon: const Icon(Icons.calendar_month_rounded, size: 18, color: Color(0xFF64748B)),
                      ),
                    ),
                  ),

                  // If editing, provide status selector (Active / Transferred / Graduated / Struck off)
                  if (isEditing) ...[
                    const SizedBox(height: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Enrollment Status',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _statusPill('active', 'Active Enrolled', const Color(0xFF16A34A)),
                            _statusPill('transferred', 'Transferred (SLC)', const Color(0xFFD97706)),
                            _statusPill('graduated', 'Graduated (Class 5)', const Color(0xFF2563EB)),
                            _statusPill('inactive', 'Struck Off', const Color(0xFFDC2626)),
                          ],
                        ),
                        if (_status == 'transferred') ...[
                          const SizedBox(height: 10),
                          _fieldWrapper(
                            label: 'School Leaving Certificate (SLC) No.',
                            child: TextFormField(
                              controller: _slcCtrl,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              decoration: _fieldDeco(hint: 'e.g. SLC-KPK-8842'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // -------------------------------------------------------------
            // Section 2: Student Identity
            // -------------------------------------------------------------
            _sectionLabel(
              icon: Icons.person_rounded,
              color: const Color(0xFF0F5132),
              title: 'Student Identity',
              urdu: 'طالب علم کی معلومات',
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: _cardStyle(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldWrapper(
                    label: 'Full Name *',
                    child: TextFormField(
                      controller: _nameCtrl,
                      textCapitalization: TextCapitalization.words,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      decoration: _fieldDeco(hint: 'e.g. Ahmad Khan'),
                      onChanged: (_) => setState(() {}),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter student name' : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _fieldWrapper(
                    label: 'Father / Guardian Name *',
                    child: TextFormField(
                      controller: _fatherCtrl,
                      textCapitalization: TextCapitalization.words,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      decoration: _fieldDeco(hint: 'e.g. Muhammad Tariq'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter father name' : null,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Gender Selector Pills
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gender',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: _genderPill(
                              label: 'Male (Boy)',
                              icon: Icons.male_rounded,
                              isSelected: _gender == 'male',
                              color: const Color(0xFF2563EB),
                              onTap: () => setState(() => _gender = 'male'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _genderPill(
                              label: 'Female (Girl)',
                              icon: Icons.female_rounded,
                              isSelected: _gender == 'female',
                              color: const Color(0xFFE11D48),
                              onTap: () => setState(() => _gender = 'female'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _fieldWrapper(
                          label: 'Date of Birth (DOB)',
                          child: TextFormField(
                            controller: _dobCtrl,
                            readOnly: true,
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                            decoration: _fieldDeco(
                              hint: 'YYYY-MM-DD',
                              suffixIcon: const Icon(Icons.cake_rounded, size: 16, color: Color(0xFF64748B)),
                            ),
                            onTap: () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: DateTime(DateTime.now().year - 6),
                                firstDate: DateTime(2005),
                                lastDate: DateTime.now(),
                              );
                              if (d != null) {
                                _dobCtrl.text = DateFormat('yyyy-MM-dd').format(d);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _fieldWrapper(
                    label: 'Form-B / Child CNIC (Optional)',
                    child: TextFormField(
                      controller: _bFormCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      decoration: _fieldDeco(hint: '17301-XXXXXXX-X'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // -------------------------------------------------------------
            // Section 3: Guardian & Contact
            // -------------------------------------------------------------
            _sectionLabel(
              icon: Icons.phone_android_rounded,
              color: const Color(0xFF7C3AED),
              title: 'Guardian & Parent Contact',
              urdu: 'رابطہ برائے واٹس ایپ',
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: _cardStyle(),
              child: Column(
                children: [
                  _fieldWrapper(
                    label: 'Guardian Mobile / WhatsApp Number *',
                    child: TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      decoration: _fieldDeco(
                        hint: '+923001234567',
                        suffixIcon: const Icon(Icons.chat_bubble_outline_rounded, size: 17, color: Color(0xFF16A34A)),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Mobile number is required for attendance alerts';
                        if (v.trim().length < 10) return 'Enter a valid mobile number';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  _fieldWrapper(
                    label: 'Father CNIC (Optional)',
                    child: TextFormField(
                      controller: _fatherCnicCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      decoration: _fieldDeco(hint: '17301-XXXXXXX-X'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // -------------------------------------------------------------
            // Section 4: Health & Vaccination
            // -------------------------------------------------------------
            _sectionLabel(
              icon: Icons.health_and_safety_rounded,
              color: const Color(0xFF0284C7),
              title: 'Health & Vaccination',
              urdu: 'حفاظتی ٹیکہ جات',
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: _cardStyle(),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vaccinated Status',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                          ),
                          Text(
                            'Has the student received immunization?',
                            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                      Switch.adaptive(
                        value: _isVaccinated,
                        activeTrackColor: const Color(0xFF0284C7),
                        onChanged: (val) => setState(() => _isVaccinated = val),
                      ),
                    ],
                  ),
                  if (_isVaccinated) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _fieldWrapper(
                            label: 'First Dose Date',
                            child: TextFormField(
                              controller: _firstDoseCtrl,
                              readOnly: true,
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                              decoration: _fieldDeco(
                                hint: 'YYYY-MM-DD',
                                suffixIcon: const Icon(Icons.calendar_today_rounded, size: 16),
                              ),
                              onTap: () async {
                                final d = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2010),
                                  lastDate: DateTime.now(),
                                );
                                if (d != null) {
                                  _firstDoseCtrl.text = DateFormat('yyyy-MM-dd').format(d);
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _fieldWrapper(
                            label: 'Second Dose Date',
                            child: TextFormField(
                              controller: _secondDoseCtrl,
                              readOnly: true,
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                              decoration: _fieldDeco(
                                hint: 'YYYY-MM-DD',
                                suffixIcon: const Icon(Icons.calendar_today_rounded, size: 16),
                              ),
                              onTap: () async {
                                final d = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2010),
                                  lastDate: DateTime.now(),
                                );
                                if (d != null) {
                                  _secondDoseCtrl.text = DateFormat('yyyy-MM-dd').format(d);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            // -------------------------------------------------------------
            // Informational Security Note
            // -------------------------------------------------------------
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, size: 18, color: Color(0xFF1D4ED8)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Unique offline QR attendance credential and records are securely synced across all teacher devices.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF1E40AF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusPill(String statusKey, String label, Color color) {
    final isSelected = _status == statusKey;
    return InkWell(
      onTap: () => setState(() => _status = statusKey),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 1.2),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }

  Widget _genderPill({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isSelected ? color : const Color(0xFF64748B)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? color : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel({
    required IconData icon,
    required Color color,
    required String title,
    required String urdu,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFF334155),
          ),
        ),
        const Spacer(),
        Text(
          urdu,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Widget _fieldWrapper({
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 5),
        child,
      ],
    );
  }

  BoxDecoration _cardStyle() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE2E8F0)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }

  InputDecoration _fieldDeco({
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      suffixIcon: suffixIcon,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.normal),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primaryDark, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDC2626)),
      ),
    );
  }
}
