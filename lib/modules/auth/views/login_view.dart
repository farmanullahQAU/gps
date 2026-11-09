import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/auth_repository.dart';
import '../auth_controller.dart';
import '../../home/views/main_navigation_shell.dart';
import 'register_school_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool _obscurePassword = true;

  bool _useFullSignIn = false;
  final _signInFormKey = GlobalKey<FormState>();
  final TextEditingController _loginIdentifierCtrl = TextEditingController();
  final TextEditingController _loginEmisCtrl = TextEditingController();
  final TextEditingController _loginPassCtrl = TextEditingController();
  final TextEditingController _quickPinCtrl = TextEditingController();

  @override
  void dispose() {
    _loginIdentifierCtrl.dispose();
    _loginEmisCtrl.dispose();
    _loginPassCtrl.dispose();
    _quickPinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F5132), Color(0xFF064E3B), Color(0xFF022C22)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Modern Professional Header
                    _buildHeader(),

                    const SizedBox(height: 22),

                    // Main Sign In Card: Quick PIN / Biometrics if returning user, or Full Sign-in form
                    Card(
                      elevation: 10,
                      shadowColor: Colors.black38,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Obx(() {
                          final cachedUser = controller.currentUser.value;
                          final hasCached = cachedUser != null && cachedUser.name.isNotEmpty;

                          if (hasCached && !_useFullSignIn) {
                            return _buildQuickPinUnlockCard(context, controller, cachedUser);
                          }
                          return _buildSignInForm(context, controller, showSwitchBack: hasCached);
                        }),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Discreet Demo Access & Footer
                    _buildFooter(context, controller),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Fast, effortless offline PIN & Biometric unlock for returning school staff
  Widget _buildQuickPinUnlockCard(BuildContext context, AuthController controller, UserModel user) {
    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : 'T';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // User Avatar & Welcome Badge
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Welcome Back, ${user.name}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          user.designation?.isNotEmpty == true
              ? '${user.designation} • ${user.role.toUpperCase()}'
              : 'Institutional Staff • ${user.role.toUpperCase()}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),

        const SizedBox(height: 20),

        // 4-Digit Quick PIN Input Field
        TextFormField(
          controller: _quickPinCtrl,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, letterSpacing: 10, fontWeight: FontWeight.w800),
          decoration: InputDecoration(
            labelText: '4-Digit Offline PIN',
            hintText: '••••',
            counterText: '',
            prefixIcon: const Icon(Icons.pin_rounded, color: AppColors.primary, size: 22),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            isDense: true,
          ),
        ),

        const SizedBox(height: 16),

        // Submit PIN Unlock
        Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()));
          }
          return SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 2,
              ),
              icon: const Icon(Icons.lock_open_rounded, size: 20),
              label: const Text(
                'UNLOCK PORTAL',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, letterSpacing: 0.5),
              ),
              onPressed: () async {
                final pin = _quickPinCtrl.text.trim();
                if (pin.length < 4) {
                  Get.snackbar(
                    'Invalid PIN',
                    'Please enter your 4-digit PIN (default: 1234)',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFFFEF3C7),
                    colorText: const Color(0xFF92400E),
                  );
                  return;
                }
                final ok = await controller.unlockWithPin(pin);
                if (ok) {
                  Get.offAll(() => const MainNavigationShell());
                } else {
                  Get.snackbar(
                    'Incorrect PIN',
                    'The PIN entered is incorrect. Default is 1234 or tap Switch User below.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFFFEE2E2),
                    colorText: const Color(0xFF991B1B),
                  );
                }
              },
            ),
          );
        }),

        // Biometric Quick Unlock (Fingerprint / Face)
        Obx(() {
          final enabled = controller.isBiometricEnabled.value;
          if (!enabled) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0F766E),
                  side: const BorderSide(color: Color(0xFF0F766E), width: 1.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  backgroundColor: const Color(0xFFF0FDFA),
                ),
                icon: const Icon(Icons.fingerprint_rounded, size: 22),
                label: const Text(
                  'UNLOCK WITH FINGERPRINT',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, letterSpacing: 0.3),
                ),
                onPressed: () async {
                  final ok = await controller.loginWithBiometrics();
                  if (ok) {
                    Get.offAll(() => const MainNavigationShell());
                  }
                },
              ),
            ),
          );
        }),

        const SizedBox(height: 16),

        // Switch User / Use Full Password Option
        TextButton.icon(
          onPressed: () {
            setState(() {
              _useFullSignIn = true;
              _loginIdentifierCtrl.text = user.email.isNotEmpty ? user.email : (user.phone ?? '');
            });
          },
          icon: const Icon(Icons.switch_account_rounded, size: 16, color: AppColors.primary),
          label: const Text(
            'Switch User or Sign In with Password',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.school_rounded, size: 30, color: AppColors.primaryDark),
        ),
        const SizedBox(height: 14),
        const Text(
          'School Attendance Portal',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Smart Attendance & Student Management',
          style: TextStyle(fontSize: 12.5, color: Colors.white.withValues(alpha: 0.8)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSignInForm(BuildContext context, AuthController controller, {bool showSwitchBack = false}) {
    return Form(
      key: _signInFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sign In to School',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              if (showSwitchBack)
                TextButton(
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                  onPressed: () => setState(() => _useFullSignIn = false),
                  child: const Text('Back to PIN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            'Please enter your credentials to sign in',
            style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),

          // User Identifier (Email or CNIC Number)
          TextFormField(
            controller: _loginIdentifierCtrl,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: 'Email or CNIC',
              hintText: 'Email or CNIC',
              prefixIcon: const Icon(Icons.person_pin_rounded, color: AppColors.primary, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              isDense: true,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Please enter your Email or CNIC';
              }
              final val = v.trim();
              final isEmail = val.contains('@');
              final digits = val.replaceAll(RegExp(r'[^0-9]'), '');

              // If entered email format, check basic email structure
              if (isEmail && (!val.contains('.') || val.length < 5)) {
                return 'Please enter a valid email address';
              }
              // If entered CNIC or ID
              if (!isEmail && digits.length < 5 && val.length < 3) {
                return 'Please enter a valid CNIC or Username';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Password Field with Show/Hide Toggle
          TextFormField(
            controller: _loginPassCtrl,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              isDense: true,
            ),
            validator: (v) {
              if (v == null || v.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.only(top: 4, bottom: 2),
              ),
              onPressed: () => _openForgotPasswordDialog(context, controller),
              child: const Text(
                'Forgot password?',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Sign In Submit Button
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 2,
                ),
                icon: const Icon(Icons.login_rounded, size: 19),
                onPressed: () async {
                  if (!_signInFormKey.currentState!.validate()) return;

                  final email = _loginIdentifierCtrl.text.trim();
                  final pass = _loginPassCtrl.text;

                  final ok = await controller.login(
                    identifier: email,
                    password: pass,
                  );
                  if (ok) {
                    Get.offAll(() => const MainNavigationShell());
                  } else if (controller.multipleSchoolTenants.isNotEmpty) {
                    if (context.mounted) {
                      _showSchoolWorkspaceSelector(context, controller, email, pass);
                    }
                  }
                },
                label: const Text(
                  'SIGN IN TO PORTAL',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, letterSpacing: 0.5),
                ),
              ),
            );
          }),

          // Biometric Quick Unlock (Fingerprint / Face)
          Obx(() {
            final enabled = controller.isBiometricEnabled.value;
            final userMeta = controller.biometricUserInfo;
            if (!enabled) return const SizedBox.shrink();

            final userName = userMeta['name'];
            final displayName = (userName != null && userName.isNotEmpty)
                ? ' ($userName)'
                : '';

            return Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F766E),
                    side: const BorderSide(color: Color(0xFF0F766E), width: 1.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    backgroundColor: const Color(0xFFF0FDFA),
                  ),
                  icon: const Icon(Icons.fingerprint_rounded, size: 24),
                  label: Text(
                    'UNLOCK WITH BIOMETRICS$displayName',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.3),
                    overflow: TextOverflow.ellipsis,
                  ),
                  onPressed: () async {
                    final ok = await controller.loginWithBiometrics();
                    if (ok) {
                      Get.offAll(() => const MainNavigationShell());
                    }
                  },
                ),
              ),
            );
          }),

          const SizedBox(height: 22),

          // Simple, Professional Register Link
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.push<Map<String, String>>(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterSchoolView()),
                  );
                  if (result != null) {
                    setState(() {
                      if (result['identifier'] != null) _loginIdentifierCtrl.text = result['identifier']!;
                      if (result['emis'] != null) _loginEmisCtrl.text = result['emis']!;
                    });
                  }
                },
                child: const Text(
                  'Register your school',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Multi-Tenant School Workspace Selector Modal
  void _showSchoolWorkspaceSelector(
    BuildContext context,
    AuthController controller,
    String identifier,
    String password,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.domain_rounded, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select School Workspace',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    Text(
                      'Your account is enrolled in multiple institutions:',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: controller.multipleSchoolTenants.length,
                separatorBuilder: (ctx, _) => const Divider(height: 1),
                itemBuilder: (ctx, index) {
                  final school = controller.multipleSchoolTenants[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryLight,
                      child: const Icon(Icons.school_outlined, color: AppColors.primaryDark),
                    ),
                    title: Text(
                      school.schoolName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                    ),
                    subtitle: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            school.schoolCode,
                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          school.userRole.toUpperCase(),
                          style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                    onTap: () async {
                      Navigator.pop(ctx);
                      final ok = await controller.login(
                        identifier: identifier,
                        emisCode: school.schoolCode,
                        password: password,
                      );
                      if (ok) {
                        Get.offAll(() => const MainNavigationShell());
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, AuthController controller) {
    return Column(
      children: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFD1FAE5),
            visualDensity: VisualDensity.compact,
          ),
          onPressed: () => _confirmLoadDemo(context, controller),
          child: const Text(
            'Explore with Sample Demo School',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '© 2026 School Management System • All rights reserved',
          style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.6)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _confirmLoadDemo(BuildContext context, AuthController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.school_rounded, color: AppColors.primary),
            SizedBox(width: 10),
            Text('Load Sample School?'),
          ],
        ),
        content: const Text(
          'This will initialize sample classes, teachers, and student attendance records for demonstration.',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await controller.seedDemoData(initialRole: 'admin');
              Get.offAll(() => const MainNavigationShell());
            },
            child: const Text('Load Demo'),
          ),
        ],
      ),
    );
  }

  void _openForgotPasswordDialog(BuildContext context, AuthController controller) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Forgot Password',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (ctx, anim1, anim2) {
        return _ForgotPasswordDialog(
          initialIdentifier: _loginIdentifierCtrl.text.trim(),
          initialEmis: _loginEmisCtrl.text.trim(),
          controller: controller,
          onPasswordResetSuccess: (identifier, newPassword) {
            setState(() {
              _loginIdentifierCtrl.text = identifier;
              _loginPassCtrl.text = newPassword;
            });
          },
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        final curve = CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic);
        return AnimatedBuilder(
          animation: curve,
          builder: (context, _) {
            final blurVal = 10.0 * curve.value;
            return BackdropFilter(
              filter: ui.ImageFilter.blur(
                sigmaX: blurVal > 0 ? blurVal : 0.001,
                sigmaY: blurVal > 0 ? blurVal : 0.001,
              ),
              child: FadeTransition(
                opacity: curve,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.90, end: 1.0).animate(curve),
                  child: child,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Industry-Standard Professional Multi-Tenant Password Recovery Dialog
class _ForgotPasswordDialog extends StatefulWidget {
  final String initialIdentifier;
  final String initialEmis;
  final AuthController controller;
  final Function(String identifier, String newPassword) onPasswordResetSuccess;

  const _ForgotPasswordDialog({
    required this.initialIdentifier,
    required this.initialEmis,
    required this.controller,
    required this.onPasswordResetSuccess,
  });

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  // Mode: 0 = Via Email (OTP), 1 = Via CNIC & Security PIN
  int _recoveryMode = 0;

  // Email Flow Step: 0 = Enter Email, 1 = Verify Code & Set Password, 2 = Success
  int _emailStep = 0;
  bool _isLoading = false;

  // Resend Countdown Timer for Email OTP
  Timer? _resendTimer;
  int _resendCountdown = 60;
  bool _canResend = false;

  // Multi-School Options (if user exists in multiple schools)
  List<SchoolTenantOption> _matchingSchools = [];
  SchoolTenantOption? _selectedSchool;

  final _emailStep1FormKey = GlobalKey<FormState>();
  final _emailStep2FormKey = GlobalKey<FormState>();
  final _cnicFormKey = GlobalKey<FormState>();

  late TextEditingController _emisCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _cnicCtrl;
  final TextEditingController _otpCtrl = TextEditingController();
  final TextEditingController _newPassCtrl = TextEditingController();
  final TextEditingController _confirmPassCtrl = TextEditingController();
  final TextEditingController _currentPinCtrl = TextEditingController();
  final TextEditingController _cnicNewPassCtrl = TextEditingController();
  final TextEditingController _cnicConfirmPassCtrl = TextEditingController();

  bool _obscureNewPass = true;
  bool _obscureConfirmPass = true;
  bool _obscureCurrentPin = true;
  bool _obscureCnicNewPass = true;
  bool _obscureCnicConfirmPass = true;

  @override
  void initState() {
    super.initState();
    _emisCtrl = TextEditingController(text: widget.initialEmis);
    
    final initial = widget.initialIdentifier.trim();
    final isEmail = initial.contains('@');
    _emailCtrl = TextEditingController(text: isEmail ? initial : '');
    _cnicCtrl = TextEditingController(text: !isEmail ? initial : '');
    
    // Automatically default to CNIC tab if the user typed a CNIC or numeric identifier in login
    if (!isEmail && initial.isNotEmpty) {
      _recoveryMode = 1;
    }
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() {
      _resendCountdown = 60;
      _canResend = false;
    });
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 1) {
        setState(() => _resendCountdown--);
      } else {
        _resendTimer?.cancel();
        setState(() => _canResend = true);
      }
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _emisCtrl.dispose();
    _emailCtrl.dispose();
    _cnicCtrl.dispose();
    _otpCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    _currentPinCtrl.dispose();
    _cnicNewPassCtrl.dispose();
    _cnicConfirmPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSuccess = _emailStep == 2;

    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 20,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      insetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      actionsOverflowButtonSpacing: 8,
      actionsOverflowDirection: VerticalDirection.down,
      titlePadding: const EdgeInsets.fromLTRB(18, 16, 14, 0),
      contentPadding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
      actionsPadding: const EdgeInsets.fromLTRB(18, 4, 18, 14),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isSuccess
                  ? Icons.check_circle_rounded
                  : _recoveryMode == 1
                      ? Icons.badge_outlined
                      : Icons.lock_reset_rounded,
              color: isSuccess ? const Color(0xFF15803D) : AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isSuccess
                  ? 'Password Updated'
                  : 'Reset Password',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Colors.grey),
            onPressed: () => Navigator.pop(context),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [
              if (!isSuccess) ...[
                // Clean Method Selector Segmented Tabs
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            if (_recoveryMode != 0) {
                              setState(() {
                                _recoveryMode = 0;
                                _emailStep = 0;
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _recoveryMode == 0 ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: _recoveryMode == 0
                                  ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 1))]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.email_outlined,
                                  size: 15,
                                  color: _recoveryMode == 0 ? AppColors.primaryDark : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Via Email',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: _recoveryMode == 0 ? FontWeight.bold : FontWeight.w500,
                                    color: _recoveryMode == 0 ? AppColors.primaryDark : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            if (_recoveryMode != 1) {
                              setState(() {
                                _recoveryMode = 1;
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _recoveryMode == 1 ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: _recoveryMode == 1
                                  ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 1))]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.badge_outlined,
                                  size: 15,
                                  color: _recoveryMode == 1 ? AppColors.primaryDark : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Via CNIC & PIN',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: _recoveryMode == 1 ? FontWeight.bold : FontWeight.w500,
                                    color: _recoveryMode == 1 ? AppColors.primaryDark : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Content based on tab & step
              if (isSuccess)
                _buildSuccessView()
              else if (_recoveryMode == 0)
                _emailStep == 0 ? _buildEmailStep1() : _buildEmailStep2()
              else
                _buildCnicRecoveryForm(),
            ],
          ),
        ),
      ),
      actions: _buildActions(),
    );
  }

  // --- METHOD 1: VIA EMAIL (OTP) ---
  Widget _buildEmailStep1() {
    return Form(
      key: _emailStep1FormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter your registered email address to receive a 6-digit security code.',
            style: TextStyle(fontSize: 12, height: 1.4, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              labelText: 'Email *',
              hintText: 'Email address',
              labelStyle: const TextStyle(fontSize: 12.5),
              prefixIcon: const Icon(Icons.email_outlined, size: 18, color: AppColors.primary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Please enter your email address';
              }
              if (!v.contains('@')) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          if (_matchingSchools.length > 1) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Your School',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Color(0xFF166534)),
                  ),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<SchoolTenantOption>(
                    initialValue: _selectedSchool,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                    items: _matchingSchools.map((s) {
                      return DropdownMenuItem<SchoolTenantOption>(
                        value: s,
                        child: Text('${s.schoolName} (${s.schoolCode})', style: const TextStyle(fontSize: 12)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedSchool = val;
                        if (val != null) _emisCtrl.text = val.schoolCode;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmailStep2() {
    return Form(
      key: _emailStep2FormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              children: [
                const Icon(Icons.mark_email_read_outlined, size: 16, color: Color(0xFF2563EB)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Code sent to: ${_emailCtrl.text.trim()}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF1E40AF), fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _emailStep = 0),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Change', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _otpCtrl,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 6),
            decoration: InputDecoration(
              labelText: '6-Digit Code *',
              hintText: '• • • • • •',
              counterText: '',
              prefixIcon: const Icon(Icons.security_rounded, size: 18, color: AppColors.primary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              isDense: true,
            ),
            validator: (v) {
              if (v == null || v.trim().length != 6) {
                return 'Enter complete 6-digit code';
              }
              return null;
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _canResend ? _handleResendOtp : null,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                _canResend ? 'Resend Code' : 'Resend code in ${_resendCountdown}s',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _canResend ? AppColors.primary : Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _newPassCtrl,
            obscureText: _obscureNewPass,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              labelText: 'New Password *',
              hintText: 'Min 6 chars',
              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.primary),
              suffixIcon: IconButton(
                icon: Icon(_obscureNewPass ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 16),
                onPressed: () => setState(() => _obscureNewPass = !_obscureNewPass),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
            ),
            validator: (v) => (v == null || v.trim().length < 6) ? 'Must be at least 6 characters' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _confirmPassCtrl,
            obscureText: _obscureConfirmPass,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              labelText: 'Confirm Password *',
              hintText: 'Confirm',
              prefixIcon: const Icon(Icons.lock_clock_outlined, size: 18, color: AppColors.primary),
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirmPass ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 16),
                onPressed: () => setState(() => _obscureConfirmPass = !_obscureConfirmPass),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please confirm new password';
              if (v != _newPassCtrl.text) return 'Passwords do not match';
              return null;
            },
          ),
        ],
      ),
    );
  }

  // --- METHOD 2: VIA CNIC & SECURITY PIN (Instant & Works Offline/Online) ---
  Widget _buildCnicRecoveryForm() {
    return Form(
      key: _cnicFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_outlined, size: 16, color: Color(0xFF334155)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'For staff without email or when offline. Enter your CNIC and your 4-digit Security PIN to instantly reset.',
                    style: TextStyle(fontSize: 11, color: Colors.blueGrey.shade800, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cnicCtrl,
            keyboardType: TextInputType.text,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              labelText: 'CNIC *',
              hintText: 'CNIC number',
              prefixIcon: const Icon(Icons.badge_outlined, size: 18, color: AppColors.primary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Enter your CNIC number';
              final digits = v.replaceAll(RegExp(r'\D'), '');
              if (digits.length < 5) return 'Please enter a valid CNIC';
              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _currentPinCtrl,
            keyboardType: TextInputType.number,
            maxLength: 4,
            obscureText: _obscureCurrentPin,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              labelText: '4-Digit PIN *',
              hintText: '4-digit PIN',
              counterText: '',
              prefixIcon: const Icon(Icons.pin_outlined, size: 18, color: AppColors.primary),
              suffixIcon: IconButton(
                icon: Icon(_obscureCurrentPin ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 16),
                onPressed: () => setState(() => _obscureCurrentPin = !_obscureCurrentPin),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
            ),
            validator: (v) => (v == null || v.trim().length != 4) ? 'Enter your 4-digit security PIN' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _cnicNewPassCtrl,
            obscureText: _obscureCnicNewPass,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              labelText: 'New Password *',
              hintText: 'Min 6 chars',
              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.primary),
              suffixIcon: IconButton(
                icon: Icon(_obscureCnicNewPass ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 16),
                onPressed: () => setState(() => _obscureCnicNewPass = !_obscureCnicNewPass),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
            ),
            validator: (v) => (v == null || v.trim().length < 6) ? 'Must be at least 6 characters' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _cnicConfirmPassCtrl,
            obscureText: _obscureCnicConfirmPass,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              labelText: 'Confirm New Password *',
              prefixIcon: const Icon(Icons.lock_clock_outlined, size: 18, color: AppColors.primary),
              suffixIcon: IconButton(
                icon: Icon(_obscureCnicConfirmPass ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 16),
                onPressed: () => setState(() => _obscureCnicConfirmPass = !_obscureCnicConfirmPass),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please confirm new password';
              if (v != _cnicNewPassCtrl.text) return 'Passwords do not match';
              return null;
            },
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Forgot your PIN? Your Head Teacher can reset your credentials from Staff Settings.',
                  style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600, height: 1.25),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- STEP 3: SUCCESS ---
  Widget _buildSuccessView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Color(0xFFDCFCE7),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_rounded, color: Color(0xFF15803D), size: 40),
        ),
        const SizedBox(height: 12),
        const Text(
          'Password Reset Successful',
          style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'Your password has been updated. You can now sign in with your new credentials.',
          style: TextStyle(fontSize: 12, height: 1.4, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  List<Widget> _buildActions() {
    if (_emailStep == 2) {
      return [
        SizedBox(
          width: double.infinity,
          height: 38,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final activeIdentifier = _recoveryMode == 0 ? _emailCtrl.text.trim() : _cnicCtrl.text.trim();
              final activePass = _recoveryMode == 0 ? _newPassCtrl.text : _cnicNewPassCtrl.text;
              widget.onPasswordResetSuccess(activeIdentifier, activePass);
              Navigator.pop(context);
            },
            child: const Text('Sign In Now', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ),
      ];
    }

    if (_recoveryMode == 1) {
      // Via CNIC & PIN
      return [
        TextButton(
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            foregroundColor: Colors.grey.shade700,
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(fontSize: 12.5)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: _isLoading ? null : _handleCnicResetSubmit,
          child: _isLoading
              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Update Password', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
        ),
      ];
    }

    // Email Step 0
    if (_emailStep == 0) {
      return [
        TextButton(
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            foregroundColor: Colors.grey.shade700,
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(fontSize: 12.5)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: _isLoading ? null : _handleRequestCode,
          child: _isLoading
              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Send Code', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
        ),
      ];
    }

    // Email Step 1: Verify & Reset
    return [
      TextButton(
        style: TextButton.styleFrom(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          foregroundColor: Colors.grey.shade700,
        ),
        onPressed: () => setState(() => _emailStep = 0),
        child: const Text('Back', style: TextStyle(fontSize: 12.5)),
      ),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: _isLoading ? null : _handleEmailResetSubmit,
        child: _isLoading
            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Reset Password', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
      ),
    ];
  }

  Future<void> _handleCnicResetSubmit() async {
    if (!_cnicFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final emis = _emisCtrl.text.trim();
    final cnic = _cnicCtrl.text.trim();
    final currentPin = _currentPinCtrl.text.trim();
    final newPass = _cnicNewPassCtrl.text;

    final ok = await widget.controller.resetPasswordOffline(
      schoolCode: emis.isNotEmpty ? emis : null,
      identifier: cnic,
      currentPin: currentPin,
      newPassword: newPass,
    );

    setState(() => _isLoading = false);

    if (ok) {
      setState(() {
        _emailStep = 2; // Show success view
      });
    }
  }

  Future<void> _handleRequestCode() async {
    if (!_emailStep1FormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final email = _emailCtrl.text.trim();
    // Multi-tenant check
    final schools = await widget.controller.findSchoolsForIdentifier(email);
    if (schools.length > 1 && _emisCtrl.text.trim().isEmpty) {
      setState(() {
        _isLoading = false;
        _matchingSchools = schools;
        _selectedSchool = schools.first;
        _emisCtrl.text = schools.first.schoolCode;
      });
      return;
    }

    try {
      final res = await widget.controller.requestPasswordResetOtp(email);
      final msg = res['message'] as String? ?? 'A 6-digit verification code has been dispatched to $email.';

      Get.snackbar(
        'Code Dispatched',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEFF6FF),
        colorText: const Color(0xFF1E40AF),
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      Get.snackbar(
        'Notice',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    setState(() {
      _isLoading = false;
      _emailStep = 1;
      _otpCtrl.clear();
    });
    _startResendTimer();
  }

  Future<void> _handleResendOtp() async {
    final email = _emailCtrl.text.trim();
    _startResendTimer();
    try {
      final res = await widget.controller.requestPasswordResetOtp(email);
      final msg = res['message'] as String? ?? 'A fresh 6-digit verification code has been dispatched to $email.';

      Get.snackbar(
        'Code Sent',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEFF6FF),
        colorText: const Color(0xFF1E40AF),
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      Get.snackbar(
        'Notice',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _handleEmailResetSubmit() async {
    if (!_emailStep2FormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final school = _emisCtrl.text.trim().isNotEmpty ? _emisCtrl.text.trim() : null;
    final email = _emailCtrl.text.trim();
    final newPass = _newPassCtrl.text;
    final otp = _otpCtrl.text.trim();

    final ok = await widget.controller.resetPassword(
      schoolCode: school,
      identifier: email,
      newPassword: newPass,
      otp: otp,
    );

    setState(() => _isLoading = false);

    if (ok) {
      _resendTimer?.cancel();
      setState(() => _emailStep = 2);
    }
  }
}
