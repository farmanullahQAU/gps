import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../auth_controller.dart';

/// Compact, Professional School Registration View
class RegisterSchoolView extends StatefulWidget {
  const RegisterSchoolView({super.key});

  @override
  State<RegisterSchoolView> createState() => _RegisterSchoolViewState();
}

class _RegisterSchoolViewState extends State<RegisterSchoolView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _schoolNameCtrl = TextEditingController();
  final TextEditingController _emisCodeCtrl = TextEditingController();
  final TextEditingController _districtCtrl = TextEditingController(text: 'Peshawar');
  final TextEditingController _tehsilCtrl = TextEditingController(text: 'City Peshawar');
  final TextEditingController _headTeacherNameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _confirmPassCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirmPass = true;

  @override
  void dispose() {
    _schoolNameCtrl.dispose();
    _emisCodeCtrl.dispose();
    _districtCtrl.dispose();
    _tehsilCtrl.dispose();
    _headTeacherNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit(AuthController controller) async {
    if (!_formKey.currentState!.validate()) return;

    final result = await controller.registerSchool(
      schoolName: _schoolNameCtrl.text.trim(),
      schoolCode: _emisCodeCtrl.text.trim().toUpperCase(),
      adminName: _headTeacherNameCtrl.text.trim(),
      adminPhone: _phoneCtrl.text.trim(),
      adminEmail: _emailCtrl.text.trim().isNotEmpty ? _emailCtrl.text.trim().toLowerCase() : null,
      adminPassword: _passCtrl.text,
      adminPin: '1234',
      district: _districtCtrl.text.trim(),
      tehsil: _tehsilCtrl.text.trim(),
    );

    if (result != null && mounted) {
      _showSuccessDialog(context, result);
    }
  }

  void _showSuccessDialog(BuildContext context, dynamic result) {
    final bool isPending = result.isPendingApproval == true;
    final String statusText = isPending ? 'Status: Pending Verification' : 'Status: Ready & Offline Enabled';
    final String bodyMessage = (result.message != null && (result.message as String).isNotEmpty)
        ? result.message as String
        : (isPending
            ? 'Your school registration has been recorded. Once verified by the administrator, you and your faculty can sign in.'
            : 'Your school and primary classes have been initialized. You can sign in and begin using the app immediately.');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        title: Row(
          children: [
            Icon(
              isPending ? Icons.schedule_rounded : Icons.check_circle_rounded,
              color: isPending ? const Color(0xFFD97706) : const Color(0xFF16A34A),
              size: 26,
            ),
            const SizedBox(width: 10),
            Text(
              isPending ? 'Registration Submitted' : 'Registration Complete',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isPending ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isPending ? const Color(0xFFFBBF24) : const Color(0xFF86EFAC)),
              ),
              child: Row(
                children: [
                  Icon(
                    isPending ? Icons.schedule_rounded : Icons.verified_rounded,
                    color: isPending ? const Color(0xFFB45309) : const Color(0xFF15803D),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${result.schoolName} (${result.schoolCode})\n$statusText',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isPending ? const Color(0xFF92400E) : const Color(0xFF166534),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              bodyMessage,
              style: const TextStyle(fontSize: 12, height: 1.4, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, {
                  'identifier': _emailCtrl.text.trim().isNotEmpty ? _emailCtrl.text.trim() : _phoneCtrl.text.trim(),
                  'emis': _emisCodeCtrl.text.trim(),
                });
              },
              child: const Text('Return to Staff Sign In', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F5132),
        foregroundColor: Colors.white,
        title: const Text(
          'Register School',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _formKey,
                child: Card(
                  elevation: 6,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        const Text(
                          'New School Registration',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Set up an account for your school or campus',
                          style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 16),

                        // Section 1: School Identity
                        _buildSectionHeader('School Information', Icons.school_outlined),
                        const SizedBox(height: 10),

                        TextFormField(
                          controller: _schoolNameCtrl,
                          textCapitalization: TextCapitalization.words,
                          decoration: _inputDeco(
                            label: 'School Name *',
                            hint: 'School name',
                            icon: Icons.domain_rounded,
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter school name' : null,
                        ),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _emisCodeCtrl,
                                textCapitalization: TextCapitalization.characters,
                                decoration: _inputDeco(
                                  label: 'School Code *',
                                  hint: 'EMIS / Code',
                                  icon: Icons.tag_rounded,
                                ),
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter code' : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _districtCtrl,
                                decoration: _inputDeco(
                                  label: 'District *',
                                  hint: 'Peshawar',
                                  icon: Icons.location_city_rounded,
                                ),
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        TextFormField(
                          controller: _tehsilCtrl,
                          decoration: _inputDeco(
                            label: 'Area / Tehsil *',
                            hint: 'Tehsil / Area',
                            icon: Icons.location_on_outlined,
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),

                        const SizedBox(height: 16),

                        // Section 2: Head Teacher
                        _buildSectionHeader('Head Teacher (Admin)', Icons.person_outline_rounded),
                        const SizedBox(height: 10),

                        TextFormField(
                          controller: _headTeacherNameCtrl,
                          textCapitalization: TextCapitalization.words,
                          decoration: _inputDeco(
                            label: 'Head Teacher Name *',
                            hint: 'Full name',
                            icon: Icons.badge_outlined,
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter name' : null,
                        ),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _phoneCtrl,
                                keyboardType: TextInputType.phone,
                                decoration: _inputDeco(
                                  label: 'Mobile *',
                                  hint: '03001234567',
                                  icon: Icons.phone_outlined,
                                ),
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter phone' : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                decoration: _inputDeco(
                                  label: 'Email',
                                  hint: 'Email',
                                  icon: Icons.email_outlined,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Section 3: Credentials
                        _buildSectionHeader('Password & Access', Icons.lock_outline_rounded),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _passCtrl,
                                obscureText: _obscurePass,
                                decoration: _inputDeco(
                                  label: 'Password *',
                                  hint: 'Min 6 chars',
                                  icon: Icons.lock_outline_rounded,
                                  suffix: IconButton(
                                    icon: Icon(_obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18),
                                    onPressed: () => setState(() => _obscurePass = !_obscurePass),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                                validator: (v) => (v == null || v.trim().length < 6) ? 'Min 6 chars' : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _confirmPassCtrl,
                                obscureText: _obscureConfirmPass,
                                decoration: _inputDeco(
                                  label: 'Confirm *',
                                  hint: 'Confirm',
                                  icon: Icons.lock_clock_outlined,
                                  suffix: IconButton(
                                    icon: Icon(_obscureConfirmPass ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18),
                                    onPressed: () => setState(() => _obscureConfirmPass = !_obscureConfirmPass),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Confirm password';
                                  if (v != _passCtrl.text) return 'Mismatch';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Compact Verification Note
                        Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF64748B)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Registrations require administrative verification before sign-in is activated.',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // Submit Button
                        Obx(() {
                          if (controller.isLoading.value) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          return SizedBox(
                            height: 46,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryDark,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 1,
                              ),
                              icon: const Icon(Icons.domain_add_rounded, size: 18),
                              onPressed: () => _handleSubmit(controller),
                              label: const Text(
                                'REGISTER SCHOOL',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: 10),

                        // Return to sign in
                        Center(
                          child: TextButton(
                            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Already registered? Sign In',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F5132)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.primaryDark),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
        ),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: Colors.grey.shade200, height: 1)),
      ],
    );
  }

  InputDecoration _inputDeco({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 18, color: Colors.grey.shade600),
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      labelStyle: const TextStyle(fontSize: 12),
      hintStyle: TextStyle(fontSize: 11, color: Colors.grey.shade400),
    );
  }
}
