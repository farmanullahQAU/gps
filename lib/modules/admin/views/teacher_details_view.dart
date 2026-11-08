import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/app_theme.dart';
import '../../attendance/attendance_controller.dart';
import '../../auth/auth_controller.dart';
import '../admin_controller.dart';

/// Professional, Modern Faculty Profile & Staff Management View:
/// Features clean material architecture, sticky save action, inline photo update,
/// Form Master primary class assignments, role privileges, and credentials management.
class TeacherDetailsView extends StatefulWidget {
  final User teacher;

  const TeacherDetailsView({super.key, required this.teacher});

  @override
  State<TeacherDetailsView> createState() => _TeacherDetailsViewState();
}

class _TeacherDetailsViewState extends State<TeacherDetailsView> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _cnicCtrl;
  late TextEditingController _pinCtrl;
  late String _designation;
  late String _role;
  String? _assignedClassId;
  String? _avatarPath;
  bool _isSaving = false;

  // Goshwara Service Particulars (کوائف سروس و گوشوارہ)
  late TextEditingController _fatherNameCtrl;
  late TextEditingController _personalNoCtrl;
  late TextEditingController _dobCtrl;
  late TextEditingController _acadQualCtrl;
  late TextEditingController _profQualCtrl;
  late TextEditingController _apptDateCtrl;
  late TextEditingController _transferDateCtrl;
  late TextEditingController _bpsCtrl;
  late TextEditingController _bpsDateCtrl;
  late TextEditingController _basicPayCtrl;
  late TextEditingController _villageCtrl;
  late TextEditingController _unionCouncilCtrl;
  late TextEditingController _districtCtrl;
  String _employmentType = 'permanent';
  TeacherGoshwaraProfile? _initialGoshwaraProfile;
  bool _isLoadingGoshwara = true;

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
  void initState() {
    super.initState();
    final t = widget.teacher;
    _nameCtrl = TextEditingController(text: t.name);
    _emailCtrl = TextEditingController(text: t.email ?? '');
    _phoneCtrl = TextEditingController(text: t.phone ?? '');
    _cnicCtrl = TextEditingController(text: t.cnic ?? '');
    _pinCtrl = TextEditingController(text: t.pinCodeHash ?? '1234');
    _designation = t.designation ?? 'Primary School Teacher (PST)';
    _role = t.role;
    _avatarPath = t.avatarUrl;

    _fatherNameCtrl = TextEditingController();
    _personalNoCtrl = TextEditingController();
    _dobCtrl = TextEditingController();
    _acadQualCtrl = TextEditingController();
    _profQualCtrl = TextEditingController();
    _apptDateCtrl = TextEditingController();
    _transferDateCtrl = TextEditingController();
    _bpsCtrl = TextEditingController(text: '14');
    _bpsDateCtrl = TextEditingController();
    _basicPayCtrl = TextEditingController();
    _villageCtrl = TextEditingController();
    _unionCouncilCtrl = TextEditingController();
    _districtCtrl = TextEditingController();

    // Resolve assigned class
    final attCtrl = Get.find<AttendanceController>();
    for (final entry in attCtrl.classFormMasterIdMap.entries) {
      if (entry.value == t.id) {
        _assignedClassId = entry.key;
        break;
      }
    }

    _loadGoshwaraParticulars();
  }

  Future<void> _loadGoshwaraParticulars() async {
    try {
      final adminCtrl = Get.find<AdminController>();
      final prof = await adminCtrl.studentRepository.getTeacherGoshwaraProfile(widget.teacher.id);
      _initialGoshwaraProfile = prof;
      if (mounted) {
        setState(() {
          _fatherNameCtrl.text = prof.fatherName;
          _personalNoCtrl.text = prof.personalNo;
          _dobCtrl.text = prof.dob;
          _acadQualCtrl.text = prof.academicQualification;
          _profQualCtrl.text = prof.professionalQualification;
          _apptDateCtrl.text = prof.appointmentDate;
          _transferDateCtrl.text = prof.transferInDate;
          _bpsCtrl.text = prof.currentBps.isNotEmpty ? prof.currentBps : '14';
          _bpsDateCtrl.text = prof.bpsAwardDate;
          _basicPayCtrl.text = prof.basicPay > 0 ? prof.basicPay.toStringAsFixed(0) : '';
          _villageCtrl.text = prof.village;
          _unionCouncilCtrl.text = prof.unionCouncil;
          _districtCtrl.text = prof.district;
          _employmentType = prof.employmentType;
          _isLoadingGoshwara = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingGoshwara = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _cnicCtrl.dispose();
    _pinCtrl.dispose();
    _fatherNameCtrl.dispose();
    _personalNoCtrl.dispose();
    _dobCtrl.dispose();
    _acadQualCtrl.dispose();
    _profQualCtrl.dispose();
    _apptDateCtrl.dispose();
    _transferDateCtrl.dispose();
    _bpsCtrl.dispose();
    _bpsDateCtrl.dispose();
    _basicPayCtrl.dispose();
    _villageCtrl.dispose();
    _unionCouncilCtrl.dispose();
    _districtCtrl.dispose();
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
        setState(() => _avatarPath = picked.path);
        await _saveAvatarOnly(picked.path);
      }
    } catch (e) {
      Get.snackbar('Image Picker', 'Could not access photo: $e');
    }
  }

  Future<void> _saveAvatarOnly(String newPath) async {
    final adminCtrl = Get.find<AdminController>();
    await adminCtrl.updateTeacherAvatar(
      teacherId: widget.teacher.id,
      avatarUrl: newPath,
    );
    Get.snackbar(
      'Profile Picture Updated',
      'Teacher profile photo updated and queued for cloud sync.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFDCFCE7),
      colorText: const Color(0xFF166534),
    );
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
                'Update Profile Picture',
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
                'Or Choose Preset Avatar',
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
                        _saveAvatarOnly(preset);
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
                      _saveAvatarOnly('');
                    },
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text('Remove Picture', style: TextStyle(fontWeight: FontWeight.w700)),
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

  Widget _buildHeroHeader({required bool canEdit}) {
    final avatar = _avatarPath?.trim() ?? '';
    final rawUrl = avatar.startsWith('/') ? 'https://myschool-api.pages.dev$avatar' : avatar;
    final isNetwork = rawUrl.startsWith('http://') || rawUrl.startsWith('https://');
    final isHT = _role == 'admin';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile Avatar with edit overlay badge
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: AppColors.primaryDark, width: 2),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                ),
                child: ClipOval(
                  child: avatar.isEmpty
                      ? Container(
                          color: AppColors.primaryLight,
                          alignment: Alignment.center,
                          child: Text(
                            widget.teacher.name.isNotEmpty ? widget.teacher.name[0].toUpperCase() : 'T',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primaryDark),
                          ),
                        )
                      : avatar.startsWith('preset_')
                          ? _buildPresetAvatar(avatar, size: 78)
                          : isNetwork
                              ? Image.network(
                                  rawUrl,
                                  width: 78,
                                  height: 78,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => _buildPresetAvatar('preset_male_1', size: 78),
                                )
                              : Image.file(
                                  File(avatar),
                                  width: 78,
                                  height: 78,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => _buildPresetAvatar('preset_male_1', size: 78),
                                ),
                ),
              ),
              if (canEdit)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: _showAvatarOptionsSheet,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_rounded, size: 13, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),

          // Name, Designation, and Role Badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.teacher.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: isHT ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isHT ? 'ADMIN' : 'FACULTY',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: isHT ? const Color(0xFF92400E) : const Color(0xFF166534),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  _designation,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                if (canEdit)
                  GestureDetector(
                    onTap: _showAvatarOptionsSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.photo_camera_outlined, size: 12.5, color: AppColors.primaryDark),
                          SizedBox(width: 4),
                          Text(
                            'Change Photo',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                          ),
                        ],
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

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    try {
      final adminCtrl = Get.find<AdminController>();
      await adminCtrl.updateTeacherProfile(
        teacherId: widget.teacher.id,
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        role: _role,
        pinCode: _pinCtrl.text.trim(),
        avatarUrl: _avatarPath,
        cnic: _cnicCtrl.text.trim(),
        designation: _designation,
        assignedClassId: _assignedClassId,
      );

      // Persist Goshwara Service Particulars (کوائف سروس و گوشوارہ)
      final currentProf = _initialGoshwaraProfile ?? TeacherGoshwaraProfile(userId: widget.teacher.id);
      final updatedProf = currentProf.copyWith(
        fatherName: _fatherNameCtrl.text.trim(),
        personalNo: _personalNoCtrl.text.trim(),
        dob: _dobCtrl.text.trim(),
        academicQualification: _acadQualCtrl.text.trim(),
        professionalQualification: _profQualCtrl.text.trim(),
        appointmentDate: _apptDateCtrl.text.trim(),
        transferInDate: _transferDateCtrl.text.trim(),
        currentBps: _bpsCtrl.text.trim(),
        bpsAwardDate: _bpsDateCtrl.text.trim(),
        basicPay: double.tryParse(_basicPayCtrl.text.trim()) ?? 0.0,
        village: _villageCtrl.text.trim(),
        unionCouncil: _unionCouncilCtrl.text.trim(),
        district: _districtCtrl.text.trim(),
        employmentType: _employmentType,
      );
      await adminCtrl.studentRepository.saveTeacherGoshwaraProfile(updatedProf);

      Get.back();
    } catch (e) {
      Get.snackbar('Error Updating Teacher', e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final attCtrl = Get.find<AttendanceController>();
    final authCtrl = Get.find<AuthController>();
    final currentUser = authCtrl.currentUser.value;
    final isAdmin = currentUser?.isAdmin ?? false;
    final isOwnProfile = currentUser?.id == widget.teacher.id;
    final canEdit = isAdmin || isOwnProfile;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          canEdit ? 'Faculty Profile & Assignment' : 'Faculty Profile',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16.5),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      bottomNavigationBar: canEdit ? _buildStickySaveBar() : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Sleek Profile Hero Header
            _buildHeroHeader(canEdit: canEdit),

            const SizedBox(height: 14),

            // 2. Personal & Cadre Information Card
            _cardSection(
              title: 'Personal & Cadre Information',
              icon: Icons.person_outline_rounded,
              children: [
                TextField(
                  controller: _nameCtrl,
                  enabled: isAdmin,
                  decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.badge_outlined, size: 20)),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _designationOptions.contains(_designation) ? _designation : _designationOptions.first,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Designation / Cadre', prefixIcon: Icon(Icons.work_outline_rounded, size: 20)),
                  items: _designationOptions.map((d) => DropdownMenuItem(
                    value: d,
                    child: Text(
                      d,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  )).toList(),
                  onChanged: isAdmin
                      ? (val) {
                          if (val != null) setState(() => _designation = val);
                        }
                      : null,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _phoneCtrl,
                  enabled: canEdit,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Contact Phone', prefixIcon: Icon(Icons.phone_outlined, size: 20)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _emailCtrl,
                  enabled: isAdmin,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined, size: 20)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _cnicCtrl,
                  enabled: isAdmin,
                  decoration: const InputDecoration(labelText: 'CNIC / Staff Code', prefixIcon: Icon(Icons.credit_card_outlined, size: 20)),
                ),
              ],
            ),

            if (isAdmin) ...[
              const SizedBox(height: 14),
              // 3. Institutional Privileges & Delegation
              _cardSection(
                title: 'Institutional Role & Access Level',
                icon: Icons.admin_panel_settings_outlined,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: _role == 'admin' ? const Color(0xFFFEF3C7).withValues(alpha: 0.5) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _role == 'admin' ? const Color(0xFFFBBF24) : const Color(0xFFE2E8F0),
                        width: _role == 'admin' ? 1.5 : 1,
                      ),
                    ),
                    child: SwitchListTile.adaptive(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      secondary: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: _role == 'admin' ? const Color(0xFFFEF3C7) : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.verified_user_rounded,
                          color: _role == 'admin' ? const Color(0xFFB45309) : Colors.grey.shade600,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        _role == 'admin' ? 'Administrator Privileges Enabled' : 'Standard Faculty Access',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: _role == 'admin' ? const Color(0xFF92400E) : AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        _role == 'admin'
                            ? 'Full administrative control: calendar, class assignments, and staff roster.'
                            : 'Standard access: daily attendance register and basic reports.',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      value: _role == 'admin',
                      activeTrackColor: AppColors.primary,
                      onChanged: (bool enableAdmin) {
                        setState(() {
                          _role = enableAdmin ? 'admin' : 'teacher';
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 14),

            // 4. Form Master Assignment
            _cardSection(
              title: 'Form Master Primary Class',
              icon: Icons.meeting_room_outlined,
              children: [
                Text(
                  isAdmin
                      ? 'Assign this teacher to lead the daily attendance register for a specific primary class:'
                      : 'Assigned primary class for daily attendance register:',
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 10),
                Obx(() {
                  final classes = attCtrl.classesList;
                  return DropdownButtonFormField<String?>(
                    initialValue: _assignedClassId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Assigned Primary Class', prefixIcon: Icon(Icons.class_outlined, size: 20)),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('None (Unassigned)', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13)),
                      ),
                      ...classes.map((c) => DropdownMenuItem<String?>(
                            value: c.id,
                            child: Text(
                              '${c.name} (${attCtrl.classEnrollmentMap[c.id] ?? 0} students)',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                          )),
                    ],
                    onChanged: isAdmin ? (val) => setState(() => _assignedClassId = val) : null,
                  );
                }),
              ],
            ),
            const SizedBox(height: 14),

            // 5. Goshwara Service Particulars Card (Teaching & Non-Teaching)
            _cardSection(
              title: 'Service & Goshwara Particulars (کوائف سروس و ماہانہ رپورٹ)',
              icon: Icons.history_edu_rounded,
              children: [
                const Text(
                  'These details automatically populate the official KPK Monthly Goshwara report for both teaching faculty and support staff.',
                  style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                if (_isLoadingGoshwara)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _fatherNameCtrl,
                          enabled: canEdit,
                          decoration: const InputDecoration(
                            labelText: "Father's Name (ولدیت)",
                            prefixIcon: Icon(Icons.person_outline_rounded, size: 18),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _personalNoCtrl,
                          enabled: canEdit,
                          decoration: const InputDecoration(
                            labelText: 'Personal # (پرسنل نمبر)',
                            prefixIcon: Icon(Icons.numbers_rounded, size: 18),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _dobCtrl,
                          enabled: canEdit,
                          decoration: const InputDecoration(
                            labelText: 'DOB (پیدائش: DD-MM-YYYY)',
                            prefixIcon: Icon(Icons.cake_outlined, size: 18),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _basicPayCtrl,
                          enabled: canEdit,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Basic Pay (تنخواہ PKR)',
                            prefixIcon: Icon(Icons.payments_outlined, size: 18),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _bpsCtrl,
                          enabled: canEdit,
                          decoration: const InputDecoration(
                            labelText: 'Current BPS (اسکیل)',
                            prefixIcon: Icon(Icons.military_tech_outlined, size: 18),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _bpsDateCtrl,
                          enabled: canEdit,
                          decoration: const InputDecoration(
                            labelText: 'BPS Award Date (تاریخ)',
                            prefixIcon: Icon(Icons.event_available_outlined, size: 18),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _acadQualCtrl,
                          enabled: canEdit,
                          decoration: const InputDecoration(
                            labelText: 'Academic (تعلیمی قابلیت)',
                            prefixIcon: Icon(Icons.school_outlined, size: 18),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _profQualCtrl,
                          enabled: canEdit,
                          decoration: const InputDecoration(
                            labelText: 'Professional (پیشہ ورانہ)',
                            prefixIcon: Icon(Icons.card_membership_outlined, size: 18),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _apptDateCtrl,
                          enabled: canEdit,
                          decoration: const InputDecoration(
                            labelText: 'Appt Date (آغاز ملازمت)',
                            prefixIcon: Icon(Icons.calendar_today_outlined, size: 18),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _transferDateCtrl,
                          enabled: canEdit,
                          decoration: const InputDecoration(
                            labelText: 'School Date (آمد اسکول)',
                            prefixIcon: Icon(Icons.login_rounded, size: 18),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _villageCtrl,
                          enabled: canEdit,
                          decoration: const InputDecoration(
                            labelText: 'Village (گاؤں)',
                            prefixIcon: Icon(Icons.home_outlined, size: 18),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _employmentType,
                          decoration: const InputDecoration(
                            labelText: 'Employment Type',
                            isDense: true,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'permanent', child: Text('Permanent (مستقل)', style: TextStyle(fontSize: 12.5))),
                            DropdownMenuItem(value: 'fixed', child: Text('Fixed / Contract (معاہدہ)', style: TextStyle(fontSize: 12.5))),
                          ],
                          onChanged: canEdit ? (v) => setState(() => _employmentType = v ?? 'permanent') : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),

            if (isAdmin || isOwnProfile) ...[
              const SizedBox(height: 14),
              // 5. Security & Offline PIN
              _cardSection(
                title: 'Security & Offline PIN',
                icon: Icons.lock_outline_rounded,
                children: [
                  TextField(
                    controller: _pinCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    decoration: const InputDecoration(
                      labelText: '4-Digit Offline PIN',
                      hintText: '1234',
                      counterText: '',
                      prefixIcon: Icon(Icons.pin, size: 20),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text('Used for instant PIN unlock during roll call on school devices.', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  if (isAdmin) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFD97706),
                          side: const BorderSide(color: Color(0xFFD97706), width: 1.2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => _showResetPasswordDialog(context),
                        icon: const Icon(Icons.lock_reset_rounded, size: 18),
                        label: const Text('Reset Teacher Password / PIN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStickySaveBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
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
          height: 46,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _isSaving ? null : _saveChanges,
            icon: _isSaving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.check_rounded, size: 20),
            label: Text(
              _isSaving ? 'Saving Changes...' : 'Save Profile Changes',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardSection({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primaryDark),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          ...children,
        ],
      ),
    );
  }

  void _showResetPasswordDialog(BuildContext context) {
    final passCtrl = TextEditingController(text: 'Teacher@123');
    final pinCtrl = TextEditingController(text: _pinCtrl.text);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.lock_reset_rounded, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Reset Password',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set a new login password or 4-digit PIN for ${widget.teacher.name}.',
              style: const TextStyle(fontSize: 12, height: 1.4, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: passCtrl,
              decoration: const InputDecoration(
                labelText: 'New Password',
                prefixIcon: Icon(Icons.password_rounded, size: 20),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pinCtrl,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: const InputDecoration(
                labelText: 'New 4-Digit Offline PIN',
                counterText: '',
                prefixIcon: Icon(Icons.pin, size: 20),
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final adminCtrl = Get.find<AdminController>();
              await adminCtrl.resetTeacherCredentials(
                teacherId: widget.teacher.id,
                teacherName: widget.teacher.name,
                newPassword: passCtrl.text.trim(),
                newPin: pinCtrl.text.trim(),
              );
              setState(() => _pinCtrl.text = pinCtrl.text.trim());
            },
            child: const Text('Save New Password'),
          ),
        ],
      ),
    );
  }
}
