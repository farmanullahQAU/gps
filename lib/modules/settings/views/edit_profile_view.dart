import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/biometric_auth_service.dart';
import '../../auth/auth_controller.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _authCtrl = Get.find<AuthController>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _cnicController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _pinController;

  String? _selectedDesignation;
  String? _selectedAvatarUrl;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _obscurePin = true;
  bool _isSaving = false;

  final List<String> _designationOptions = [
    'Head Teacher / Principal',
    'Senior Teacher',
    'Primary School Teacher (PST)',
    'Certified Teacher (CT)',
    'Arabic Teacher (AT)',
    'Theology Teacher (TT)',
    'Physical Education Teacher (PET)',
    'Drawing Master (DM)',
    'Qari / Qaria',
    'School Administrator',
    'IT Incharge / Assistant',
  ];

  final List<String> _avatarPresets = [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=250&q=80',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=250&q=80',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=250&q=80',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=250&q=80',
    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=250&q=80',
    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=250&q=80',
  ];

  @override
  void initState() {
    super.initState();
    final user = _authCtrl.currentUser.value;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _cnicController = TextEditingController(text: user?.cnic ?? '');
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _pinController = TextEditingController();

    _selectedDesignation = user?.designation;
    if (_selectedDesignation != null && !_designationOptions.contains(_selectedDesignation)) {
      _designationOptions.insert(0, _selectedDesignation!);
    }
    _selectedAvatarUrl = user?.avatarUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cnicController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Choose Profile Avatar',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Select a faculty badge avatar or clear custom photo:',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() => _selectedAvatarUrl = null);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedAvatarUrl == null ? AppColors.primary : AppColors.border,
                            width: 2,
                          ),
                          color: const Color(0xFFF1F5F9),
                        ),
                        child: const Icon(Icons.person_outline_rounded, color: AppColors.textSecondary, size: 28),
                      ),
                    ),
                    ..._avatarPresets.map((url) {
                      final isSelected = _selectedAvatarUrl == url;
                      return InkWell(
                        onTap: () {
                          setState(() => _selectedAvatarUrl = url);
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.network(
                              url,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.person),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final user = _authCtrl.currentUser.value;
    if (user == null) return;

    final newPassword = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    if (newPassword.isNotEmpty && newPassword != confirmPassword) {
      Get.snackbar(
        'Password Mismatch',
        'New password and confirmation do not match.',
        backgroundColor: const Color(0xFFFEE2E2),
        colorText: const Color(0xFF991B1B),
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final newPin = _pinController.text.trim();
    if (newPin.isNotEmpty && (newPin.length != 4 || int.tryParse(newPin) == null)) {
      Get.snackbar(
        'Invalid PIN',
        'PIN must be exactly 4 numeric digits.',
        backgroundColor: const Color(0xFFFEE2E2),
        colorText: const Color(0xFF991B1B),
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isSaving = true);
    final ok = await _authCtrl.updateUserProfileAndCredentials(
      userId: user.id,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      cnic: _cnicController.text.trim(),
      designation: _selectedDesignation,
      avatarUrl: _selectedAvatarUrl,
      newPassword: newPassword.isEmpty ? null : newPassword,
      newPin: newPin.isEmpty ? null : newPin,
    );
    setState(() => _isSaving = false);

    if (ok && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authCtrl.currentUser.value;
    final initial = (_nameController.text.trim().isNotEmpty)
        ? _nameController.text.trim()[0].toUpperCase()
        : 'T';

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Edit Faculty Profile', style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800)),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _handleSave,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            // 1. Profile Avatar Card (compact top)
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryDark,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: _selectedAvatarUrl != null && _selectedAvatarUrl!.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              _selectedAvatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Center(
                                child: Text(
                                  initial,
                                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              initial,
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
                            ),
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _showAvatarPicker,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.camera_alt_rounded, size: 15, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: InkWell(
                onTap: _showAvatarPicker,
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.photo_library_outlined, size: 14, color: AppColors.primaryDark),
                      SizedBox(width: 4),
                      Text(
                        'Change Badge Photo / Avatar',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 2. Personal Information Section
            _buildSectionHeader('PERSONAL & PROFESSIONAL DETAILS'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardBox(),
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration(
                      labelText: 'Full Name *',
                      prefixIcon: Icons.badge_outlined,
                      hintText: 'e.g. Muhammad Farman',
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Full name is required';
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedDesignation,
                    isExpanded: true,
                    decoration: _inputDecoration(
                      labelText: 'Designation / Post',
                      prefixIcon: Icons.work_outline_rounded,
                    ),
                    items: _designationOptions.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(role, style: const TextStyle(fontSize: 13.5)),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedDesignation = val),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _cnicController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9\-]')),
                      LengthLimitingTextInputFormatter(15),
                    ],
                    decoration: _inputDecoration(
                      labelText: 'CNIC Number',
                      prefixIcon: Icons.credit_card_rounded,
                      hintText: '17301-XXXXXXX-X',
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDecoration(
                      labelText: 'Contact / WhatsApp Phone',
                      prefixIcon: Icons.phone_android_rounded,
                      hintText: '03XX-XXXXXXX',
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icons.mail_outline_rounded,
                      hintText: 'teacher@kpk.edu.pk',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 3. Offline Credentials & Security Section
            _buildSectionHeader('OFFLINE CREDENTIALS & SECURITY'),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.wifi_off_rounded, size: 18, color: Color(0xFF1D4ED8)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Changes save instantly to this phone\'s offline database and sync to KPK servers when internet connects.',
                      style: TextStyle(fontSize: 11.5, color: Color(0xFF1E40AF), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardBox(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: _inputDecoration(
                      labelText: 'New Password (Leave blank to keep current)',
                      prefixIcon: Icons.lock_outline_rounded,
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, size: 18),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: _inputDecoration(
                      labelText: 'Confirm New Password',
                      prefixIcon: Icons.lock_reset_rounded,
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, size: 18),
                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    obscureText: _obscurePin,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: _inputDecoration(
                      labelText: '4-Digit Offline Security PIN',
                      prefixIcon: Icons.pin_outlined,
                      hintText: 'e.g. 1234',
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePin ? Icons.visibility_off : Icons.visibility, size: 18),
                        onPressed: () => setState(() => _obscurePin = !_obscurePin),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'The 4-digit PIN allows instantaneous local attendance entry even if cellular network is unavailable.',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 4. Biometric App Lock Toggle
            _buildSectionHeader('BIOMETRIC AUTHENTICATION'),
            const SizedBox(height: 8),
            Container(
              decoration: _cardBox(),
              child: FutureBuilder<bool>(
                future: BiometricAuthService.isBiometricsSupported(),
                builder: (context, snapshot) {
                  final isHardwareSupported = snapshot.data ?? false;
                  if (!isHardwareSupported) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.fingerprint_rounded, color: AppColors.textMuted),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Biometric sensor is not available on this device.',
                              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Obx(() {
                    final isEnabled = _authCtrl.isBiometricEnabled.value;
                    return ListTile(
                      leading: const Icon(Icons.fingerprint_rounded, color: Color(0xFF0D9488)),
                      title: const Text('Fingerprint / Face Unlock', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                      subtitle: Text(
                        isEnabled
                            ? 'Enabled for instant 1-tap offline sign-in'
                            : 'Enable to unlock attendance register with fingerprint',
                        style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                      ),
                      trailing: Switch.adaptive(
                        value: isEnabled,
                        activeTrackColor: AppColors.primary,
                        onChanged: (val) async {
                          if (val) {
                            final ok = await BiometricAuthService.authenticate(
                              reason: 'Confirm biometrics to enable instant unlock',
                            );
                            if (ok) {
                              await BiometricAuthService.setBiometricEnabled(
                                true,
                                userId: user?.id,
                                name: _nameController.text.trim(),
                                role: user?.role,
                              );
                              await _authCtrl.checkBiometricStatus();
                              Get.snackbar(
                                'Biometrics Enabled',
                                'Fingerprint/Face login is now active for this account.',
                                backgroundColor: const Color(0xFFDCFCE7),
                                colorText: const Color(0xFF166534),
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          } else {
                            await BiometricAuthService.setBiometricEnabled(false);
                            await _authCtrl.checkBiometricStatus();
                          }
                        },
                      ),
                    );
                  });
                },
              ),
            ),

            const SizedBox(height: 28),

            // Save Button
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isSaving ? null : _handleSave,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save_rounded, size: 20),
                label: Text(
                  _isSaving ? 'Saving Profile...' : 'Save Profile & Offline Credentials',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          color: AppColors.textMuted,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  BoxDecoration _cardBox() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String labelText,
    required IconData prefixIcon,
    String? hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: Icon(prefixIcon, size: 20, color: AppColors.textMuted),
      suffixIcon: suffixIcon,
      labelStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
      hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      filled: true,
      fillColor: const Color(0xFFFBFBFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}
