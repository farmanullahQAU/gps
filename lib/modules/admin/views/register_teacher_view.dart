import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../attendance/attendance_controller.dart';
import '../admin_controller.dart';

/// Dedicated, professional teacher registration view with optional profile picture,
/// full employment details, Form Master class assignment, and offline PIN setup.
class RegisterTeacherView extends StatefulWidget {
  const RegisterTeacherView({super.key});

  @override
  State<RegisterTeacherView> createState() => _RegisterTeacherViewState();
}

class _RegisterTeacherViewState extends State<RegisterTeacherView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _cnicCtrl = TextEditingController();
  final TextEditingController _pinCtrl = TextEditingController(text: '1234');
  final TextEditingController _passwordCtrl = TextEditingController(text: 'Teacher@123');

  String _designation = 'Primary School Teacher (PST)';
  String _role = 'teacher'; // 'teacher' | 'admin'
  String? _selectedClassId;
  String? _avatarPath; // Local file path or preset avatar id
  bool _isSaving = false;

  final ImagePicker _picker = ImagePicker();

  static const List<String> _designationOptions = [
    'Primary School Teacher (PST)',
    'Senior Primary School Teacher (SPST)',
    'Head Teacher / Incharge (PSHT)',
    'Certified Teacher (CT)',
    'Arabic Teacher (AT)',
    'Theology Teacher (TT)',
    'Physical Education Teacher (PET)',
    'Drawing Master (DM)',
    'Qari / Arabic Teacher',
    'Class IV / Naib Qasid (نائب قاصد)',
    'Chowkidar (چوکیدار)',
    'Mali / Ground Staff (مالی)',
    'Water Carrier / Sweeper (خاک روب)',
    'School Administrator / Clerk',
    'IT Incharge / Lab Assistant',
  ];

  static const List<String> _avatarPresets = [
    'preset_male_1',
    'preset_male_2',
    'preset_female_1',
    'preset_female_2',
    'preset_senior_1',
    'preset_scholar_1',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _cnicCtrl.dispose();
    _pinCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _avatarPath = picked.path;
        });
      }
    } catch (e) {
      Get.snackbar('Image Picker', 'Could not open camera or gallery: $e');
    }
  }

  void _showAvatarOptionsSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose Profile Picture',
                style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _photoOptionButton(
                      icon: Icons.camera_alt_rounded,
                      label: 'Take Photo',
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _photoOptionButton(
                      icon: Icons.photo_library_rounded,
                      label: 'Choose Gallery',
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Or Select Professional Avatar Preset',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _avatarPresets.map((preset) {
                    final isSel = _avatarPath == preset;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _avatarPath = preset);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSel ? AppColors.primary : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: _buildPresetAvatar(preset, size: 52),
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (_avatarPath != null) ...[
                const SizedBox(height: 14),
                Center(
                  child: TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: AppColors.absent),
                    onPressed: () {
                      setState(() => _avatarPath = null);
                      Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text('Remove Photo', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _photoOptionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.bgLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 26, color: AppColors.primaryDark),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetAvatar(String preset, {double size = 80}) {
    Color bg;
    IconData icon;
    switch (preset) {
      case 'preset_female_1':
      case 'preset_female_2':
        bg = const Color(0xFFFCE7F3);
        icon = Icons.face_3_rounded;
        break;
      case 'preset_senior_1':
        bg = const Color(0xFFFEF3C7);
        icon = Icons.account_circle_rounded;
        break;
      case 'preset_scholar_1':
        bg = const Color(0xFFE0E7FF);
        icon = Icons.school_rounded;
        break;
      default:
        bg = const Color(0xFFDCFCE7);
        icon = Icons.face_rounded;
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, size: size * 0.58, color: AppColors.primaryDark),
    );
  }

  Widget _buildAvatarPreview() {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: AppColors.primary, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: _avatarPath == null
                  ? Container(
                      color: AppColors.primaryLight,
                      child: const Icon(Icons.person_add_rounded, size: 50, color: AppColors.primaryDark),
                    )
                  : _avatarPath!.startsWith('preset_')
                      ? _buildPresetAvatar(_avatarPath!, size: 100)
                      : Image.file(
                          File(_avatarPath!),
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => _buildPresetAvatar('preset_male_1', size: 100),
                        ),
            ),
          ),
          InkWell(
            onTap: _showAvatarOptionsSheet,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 6),
                ],
              ),
              child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final adminCtrl = Get.find<AdminController>();
      await adminCtrl.addTeacher(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim().isEmpty ? 'teacher_${DateTime.now().millisecondsSinceEpoch}@gps.edu.pk' : _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        role: _role,
        pinCode: _pinCtrl.text.trim().isEmpty ? '1234' : _pinCtrl.text.trim(),
        password: _passwordCtrl.text.trim().isEmpty ? 'Teacher@123' : _passwordCtrl.text.trim(),
        avatarUrl: _avatarPath,
        cnic: _cnicCtrl.text.trim(),
        designation: _designation,
        assignedClassId: _selectedClassId,
      );

      Get.back();
      Get.snackbar(
        'Staff Registered Successfully',
        '${_nameCtrl.text.trim()} added. Profile picture and assignments are synced.',
        backgroundColor: const Color(0xFFDCFCE7),
        colorText: const Color(0xFF166534),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Registration Error', e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final attCtrl = Get.find<AttendanceController>();

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Register Staff Member', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Picker Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildAvatarPreview(),
                    const SizedBox(height: 10),
                    Text(
                      _avatarPath != null ? 'Profile Picture Selected' : 'Add Optional Profile Picture',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Can be captured from camera, gallery, or updated anytime',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _showAvatarOptionsSheet,
                      icon: const Icon(Icons.add_a_photo_outlined, size: 15),
                      label: Text(_avatarPath != null ? 'Change Photo' : 'Upload / Select Photo', style: const TextStyle(fontSize: 11.5)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Employment Details Card
              _sectionCard(
                title: 'Teacher Information',
                icon: Icons.person_outline_rounded,
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Full Name *',
                      hintText: 'e.g. Zahid Hussain Shah',
                      prefixIcon: Icon(Icons.badge_outlined, size: 20),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter teacher name' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _designation,
                    decoration: const InputDecoration(
                      labelText: 'Designation / Cadre',
                      prefixIcon: Icon(Icons.work_outline_rounded, size: 20),
                    ),
                    items: _designationOptions.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _designation = val;
                          if (val.contains('Head Teacher')) {
                            _role = 'admin';
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  // Role Selector
                  const Text('System Role & Access Rights', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: _roleOption(
                          roleKey: 'teacher',
                          label: 'Primary School Teacher',
                          desc: 'Takes attendance for assigned Form Master class',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _roleOption(
                          roleKey: 'admin',
                          label: 'Head Teacher / Admin',
                          desc: 'Full school administration & all classes access',
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Contact & Identification Card
              _sectionCard(
                title: 'Contact & Verification',
                icon: Icons.contact_phone_outlined,
                children: [
                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Contact Phone Number',
                      hintText: '+92 300 1234567',
                      prefixIcon: Icon(Icons.phone_outlined, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email Address (Optional)',
                      hintText: 'teacher@gps.edu.pk',
                      prefixIcon: Icon(Icons.email_outlined, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _cnicCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'CNIC / Personal No. (Optional)',
                      hintText: '17301-XXXXXXX-X',
                      prefixIcon: Icon(Icons.credit_card_outlined, size: 20),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Form Master Class Assignment Card
              _sectionCard(
                title: 'Form Master Class Assignment',
                icon: Icons.meeting_room_outlined,
                children: [
                  const Text(
                    'Assign this teacher to lead roll call and daily attendance register for a primary class:',
                    style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  Obx(() {
                    final classes = attCtrl.classesList;
                    return DropdownButtonFormField<String?>(
                      initialValue: _selectedClassId,
                      decoration: const InputDecoration(
                        labelText: 'Assigned Primary Class',
                        prefixIcon: Icon(Icons.class_outlined, size: 20),
                      ),
                      hint: const Text('None (Assign later or roving staff)', style: TextStyle(fontSize: 13)),
                      items: [
                        const DropdownMenuItem<String?>(value: null, child: Text('None (Assign later)', style: TextStyle(fontSize: 13))),
                        ...classes.map((c) => DropdownMenuItem<String?>(
                              value: c.id,
                              child: Text('${c.name} (${attCtrl.classEnrollmentMap[c.id] ?? 0} students)', style: const TextStyle(fontSize: 13)),
                            )),
                      ],
                      onChanged: (val) => setState(() => _selectedClassId = val),
                    );
                  }),
                ],
              ),

              const SizedBox(height: 16),

              // Security & PIN Card
              _sectionCard(
                title: 'Login & Offline Quick PIN',
                icon: Icons.lock_outline_rounded,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _pinCtrl,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          decoration: const InputDecoration(
                            labelText: 'Offline PIN *',
                            hintText: '1234',
                            counterText: '',
                            prefixIcon: Icon(Icons.pin, size: 20),
                          ),
                          validator: (v) => (v == null || v.trim().length != 4) ? 'Must be 4 digits' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _passwordCtrl,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Portal Password',
                            hintText: 'Teacher@123',
                            prefixIcon: Icon(Icons.password_rounded, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Teachers use this 4-digit PIN for instant offline register access on school tablets.',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 1,
                  ),
                  onPressed: _isSaving ? null : _submit,
                  icon: _isSaving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.person_add_alt_1_rounded, size: 20),
                  label: Text(_isSaving ? 'Registering...' : 'Register Staff & Save Account', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primaryDark),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            ],
          ),
          const Divider(height: 20, color: AppColors.border),
          ...children,
        ],
      ),
    );
  }

  Widget _roleOption({required String roleKey, required String label, required String desc}) {
    final isSel = _role == roleKey;
    return GestureDetector(
      onTap: () => setState(() => _role = roleKey),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSel ? AppColors.primaryLight : AppColors.bgLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSel ? AppColors.primary : AppColors.border, width: isSel ? 1.5 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSel ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                  size: 15,
                  color: isSel ? AppColors.primary : AppColors.textMuted,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: isSel ? AppColors.primaryDark : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(desc, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.15)),
          ],
        ),
      ),
    );
  }
}
