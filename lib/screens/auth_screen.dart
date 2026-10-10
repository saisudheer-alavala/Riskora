import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../models/user_account.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_gradient_button.dart';
import '../widgets/red_points_background.dart';

/// Red Points cybersecurity authentication portal with Login, Register,
/// and Forgot Password flows adhering strictly to Red Points aesthetics.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isRegisterMode = false;

  // Login Controllers
  final _loginIdentifierController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  bool _obscureLoginPassword = true;
  String? _loginError;

  // Register Controllers
  final _regNameController = TextEditingController();
  final _regEmailController = TextEditingController();
  DateTime? _selectedDob;
  final _regPasswordController = TextEditingController();
  final _regConfirmPasswordController = TextEditingController();
  bool _obscureRegPassword = true;
  bool _obscureRegConfirmPassword = true;
  String? _regError;

  @override
  void dispose() {
    _loginIdentifierController.dispose();
    _loginPasswordController.dispose();
    _regNameController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    _regConfirmPasswordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final identifier = _loginIdentifierController.text.trim();
    final password = _loginPasswordController.text;

    if (identifier.isEmpty) {
      setState(() => _loginError = 'Please enter your corporate identity or email.');
      return;
    }
    if (password.isEmpty) {
      setState(() => _loginError = 'Please enter your password.');
      return;
    }

    setState(() => _loginError = null);
    final provider = context.read<AppStateProvider>();
    final result = provider.verifyAndLogin(identifier, password);

    if (!result.success) {
      setState(() => _loginError = result.errorMessage);
      _showSecurityAlertModal(result);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.verified_user_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Access Granted: Welcome ${result.user?.name ?? identifier} (${result.user?.role ?? "SecOps"})',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.surfaceHigh,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _handleQuickDemoLogin() {
    _loginIdentifierController.text = 'analyst@riskora.ai';
    _loginPasswordController.text = 'RiskoraSecOps#2026';
    _handleLogin();
  }

  void _handleRegister() {
    final name = _regNameController.text.trim();
    final email = _regEmailController.text.trim();
    final password = _regPasswordController.text;
    final confirmPassword = _regConfirmPasswordController.text;

    if (name.isEmpty) {
      setState(() => _regError = 'Please enter your full name.');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _regError = 'Please enter a valid corporate email address.');
      return;
    }
    if (_selectedDob == null) {
      setState(() => _regError = 'Please select your Date of Birth.');
      return;
    }
    if (password.length < 6) {
      setState(() => _regError = 'Password must be at least 6 characters long.');
      return;
    }
    // "rendu match aithene theesukovaali" (Strict Password Match Validation)
    if (password != confirmPassword) {
      setState(() => _regError = 'Passwords do not match! Please verify both boxes.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match! Enter password & Re-enter password must be identical.'),
          backgroundColor: AppTheme.riskCritical,
        ),
      );
      return;
    }

    // Check disposable email blacklist early
    if (email.contains('@')) {
      final domain = email.split('@').last.toLowerCase();
      if (['tempmail.com', '10minutemail.com', 'mailinator.com', 'guerrillamail.com', 'fakemail.com', 'yopmail.com', 'trashmail.com'].contains(domain)) {
        final res = AuthResult.fail(
          AuthResultCode.disposableEmailRejected,
          'Security Block: Temporary and disposable email domains ($domain) are prohibited by Zero-Trust perimeter.',
        );
        setState(() => _regError = res.errorMessage);
        _showSecurityAlertModal(res);
        return;
      }
    }

    setState(() => _regError = null);
    // Trigger 2FA OTP Challenge dialog
    _showOtpVerificationDialog(
      name: name,
      email: email,
      password: password,
      dob: _selectedDob!,
    );
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 24, now.month, now.day),
      firstDate: DateTime(1940),
      lastDate: DateTime(now.year - 14),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: (isDark ? ThemeData.dark() : ThemeData.light()).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: AppTheme.purpleElectric,
                    onPrimary: Colors.white,
                    surface: AppTheme.darkSurfaceElevated,
                    onSurface: AppTheme.darkTextPrimary,
                  )
                : const ColorScheme.light(
                    primary: AppTheme.purpleElectric,
                    onPrimary: Colors.white,
                    surface: AppTheme.lightSurfaceElevated,
                    onSurface: AppTheme.lightTextPrimary,
                  ),
            dialogBackgroundColor: isDark ? AppTheme.surface : AppTheme.lightSurface,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        _regError = null;
      });
    }
  }

  void _showForgotPasswordDialog() {
    final resetController = TextEditingController(text: _loginIdentifierController.text);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? AppTheme.surface : AppTheme.lightSurface;
    final dialogBorder = isDark ? AppTheme.border : AppTheme.lightBorder;
    final textColor = isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary;
    final textSec = isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary;
    final fillBg = isDark ? AppTheme.surfaceElevated : AppTheme.lightSurfaceElevated;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: dialogBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: dialogBorder),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.coralSunset.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.lock_reset_rounded, color: AppTheme.coralSunset, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Reset Password',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter your registered Phone Number or Corporate Email. A secure authentication reset link and OTP will be dispatched immediately.',
                style: GoogleFonts.inter(fontSize: 12, color: textSec, height: 1.4),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: resetController,
                style: GoogleFonts.inter(color: textColor, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Phone Number or Email',
                  prefixIcon: const Icon(Icons.contact_mail_outlined, color: AppTheme.primaryTeal, size: 18),
                  filled: true,
                  fillColor: fillBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel', style: GoogleFonts.inter(color: isDark ? AppTheme.textMuted : AppTheme.lightTextMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                final target = resetController.text.trim();
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      target.isNotEmpty
                          ? 'Password reset instructions dispatched to $target.'
                          : 'Password reset link sent to your registered account.',
                    ),
                    backgroundColor: isDark ? AppTheme.surfaceHigh : AppTheme.lightSurfaceHigh,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.purpleElectric,
                foregroundColor: Colors.white,
              ),
              child: const Text('Send Reset Instructions'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.surface : AppTheme.lightSurface;
    final cardBorder = isDark ? AppTheme.border : AppTheme.lightBorder;

    return RedPointsBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: cardBg.withOpacity(isDark ? 0.94 : 0.97),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: cardBorder, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.purpleElectric.withOpacity(isDark ? 0.20 : 0.08),
                      blurRadius: 36,
                      offset: const Offset(0, 10),
                    ),
                    if (isDark) ...AppTheme.cardShadow else ...AppTheme.lightCardShadow,
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Logo & Title Header with Theme Toggle Button
                    _buildBrandHeader(isDark),

                    const SizedBox(height: 28),

                    // Animated Switcher between Login and Register widgets
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.04, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: _isRegisterMode
                          ? _buildRegisterForm(isDark)
                          : _buildLoginForm(isDark),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandHeader(bool isDark) {
    final appState = context.read<AppStateProvider>();
    final textColor = isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary;

    return Stack(
      children: [
        // Back to Home button in top-left corner
        Positioned(
          top: 0,
          left: 0,
          child: Tooltip(
            message: 'Return to Home Page',
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => appState.openHomeScreen(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.surfaceElevated : AppTheme.lightSurfaceElevated,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppTheme.border : AppTheme.lightBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_back_rounded,
                      size: 14,
                      color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Home',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Theme switch pill button in top-right corner
        Positioned(
          top: 0,
          right: 0,
          child: Tooltip(
            message: isDark ? 'Switch to Clean Light Theme' : 'Switch to Stealth Dark Theme',
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => appState.toggleTheme(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.surfaceElevated : AppTheme.lightSurfaceElevated,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppTheme.border : AppTheme.lightBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      size: 15,
                      color: isDark ? AppTheme.coralSunset : AppTheme.purpleElectric,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isDark ? 'Light' : 'Dark',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Center(
          child: Column(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withOpacity(0.4),
                      blurRadius: 22,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/riskora_emblem.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'RISKORA',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'INTELLIGENT DIGITAL RISK PROTECTION',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: isDark ? AppTheme.coralSunset : AppTheme.coralDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- LOGIN VIEW ---
  Widget _buildLoginForm(bool isDark) {
    final textColor = isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary;
    final textSecondary = isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary;
    final textMuted = isDark ? AppTheme.textMuted : AppTheme.lightTextMuted;
    final inputBg = isDark ? AppTheme.surfaceElevated : AppTheme.lightSurfaceElevated;
    final inputBorder = isDark ? AppTheme.border : AppTheme.lightBorder;

    return Column(
      key: const ValueKey('login_form'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Sign In to Security Operations Center',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'Enter registered credentials to access active telemetry and threat matrix',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: textMuted,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),

        if (_loginError != null) ...[
          _buildErrorBanner(_loginError!),
          const SizedBox(height: 16),
        ],

        // Sign in with Google (OAuth 2.0)
        OutlinedButton(
          onPressed: _showGoogleSignInModal,
          style: OutlinedButton.styleFrom(
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            side: BorderSide(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
              width: 1.2,
            ),
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildGoogleLogo(size: 20),
              const SizedBox(width: 12),
              Text(
                'Sign in with Google',
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Divider with "OR WITH RISKORA CORPORATE IDENTITY"
        Row(
          children: [
            Expanded(child: Divider(color: inputBorder)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'OR CORPORATE IDENTITY LOGIN',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: textMuted,
                ),
              ),
            ),
            Expanded(child: Divider(color: inputBorder)),
          ],
        ),

        const SizedBox(height: 16),

        // Phone Number or Email Input
        Text(
          'Corporate Email or Identity',
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _loginIdentifierController,
          keyboardType: TextInputType.emailAddress,
          style: GoogleFonts.inter(color: textColor, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'e.g. analyst@riskora.ai or admin@riskora.com',
            prefixIcon: const Icon(Icons.alternate_email_rounded, color: AppTheme.primaryTeal, size: 18),
            filled: true,
            fillColor: inputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: inputBorder),
            ),
          ),
          onSubmitted: (_) => _handleLogin(),
        ),

        const SizedBox(height: 18),

        // Password Input
        Text(
          'Password',
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _loginPasswordController,
          obscureText: _obscureLoginPassword,
          style: GoogleFonts.inter(color: textColor, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Enter account password',
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.primaryTeal, size: 18),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureLoginPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: textMuted,
                size: 18,
              ),
              onPressed: () => setState(() => _obscureLoginPassword = !_obscureLoginPassword),
            ),
            filled: true,
            fillColor: inputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: inputBorder),
            ),
          ),
          onSubmitted: (_) => _handleLogin(),
        ),

        const SizedBox(height: 14),

        // Row under Password: Forgot Password & Register Option
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: _showForgotPasswordDialog,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Text(
                  'Forgot Password?',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.coralSunset : AppTheme.coralDark,
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  _isRegisterMode = true;
                  _regError = null;
                });
              },
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Row(
                  children: [
                    Text(
                      'Register Now',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.purpleGlow,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_rounded, size: 14, color: AppTheme.purpleGlow),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Sign In Action Button (Red Points Gradient)
        AnimatedGradientButton(
          onPressed: _handleLogin,
          icon: Icons.login_rounded,
          text: 'Sign In to SecOps Matrix',
        ),

        const SizedBox(height: 18),

        // Zero-Trust Evaluator Test Accounts Panel
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0D131F) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.security_rounded, size: 14, color: AppTheme.primaryTeal),
                  const SizedBox(width: 6),
                  Text(
                    'ZERO-TRUST EVALUATOR ACCOUNTS:',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppTheme.coralSunset : AppTheme.coralDark,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildQuickChip(
                    label: 'Analyst (Verified)',
                    email: 'analyst@riskora.ai',
                    pass: 'RiskoraSecOps#2026',
                    color: AppTheme.primaryTeal,
                    isDark: isDark,
                  ),
                  _buildQuickChip(
                    label: 'Admin (Verified)',
                    email: 'admin@riskora.com',
                    pass: 'Admin@Riskora2026!',
                    color: AppTheme.purpleElectric,
                    isDark: isDark,
                  ),
                  _buildQuickChip(
                    label: 'Director (Verified)',
                    email: 'director@cyberdefense.org',
                    pass: 'Director@Defense2026',
                    color: const Color(0xFF38BDF8),
                    isDark: isDark,
                  ),
                  _buildQuickChip(
                    label: 'Fake Domain (Blocked)',
                    email: 'hacker@tempmail.com',
                    pass: '123456',
                    color: AppTheme.riskCritical,
                    isDark: isDark,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- REGISTER VIEW ("Next page ki widgets change avvaali") ---
  Widget _buildRegisterForm(bool isDark) {
    final password = _regPasswordController.text;
    final confirmPassword = _regConfirmPasswordController.text;
    final hasConfirm = confirmPassword.isNotEmpty;
    final passwordsMatch = password.isNotEmpty && password == confirmPassword;

    final textColor = isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary;
    final textSecondary = isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary;
    final textMuted = isDark ? AppTheme.textMuted : AppTheme.lightTextMuted;
    final inputBg = isDark ? AppTheme.surfaceElevated : AppTheme.lightSurfaceElevated;
    final inputBorder = isDark ? AppTheme.border : AppTheme.lightBorder;

    return Column(
      key: const ValueKey('register_form'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Create SecOps Analyst Account',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'Register brand entity or analyst profile for active telemetry monitoring',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: textMuted,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 22),

        if (_regError != null) ...[
          _buildErrorBanner(_regError!),
          const SizedBox(height: 14),
        ],

        // 1. Name Field
        Text(
          'Full Name',
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _regNameController,
          style: GoogleFonts.inter(color: textColor, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'e.g. Sai Sudheer',
            prefixIcon: const Icon(Icons.badge_outlined, color: AppTheme.primaryTeal, size: 18),
            filled: true,
            fillColor: inputBg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),

        const SizedBox(height: 14),

        // 2. Mail Field
        Text(
          'Corporate Email Address',
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _regEmailController,
          keyboardType: TextInputType.emailAddress,
          style: GoogleFonts.inter(color: textColor, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'e.g. analyst@company.com',
            prefixIcon: const Icon(Icons.mail_outline_rounded, color: AppTheme.primaryTeal, size: 18),
            filled: true,
            fillColor: inputBg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),

        const SizedBox(height: 14),

        // 3. Date of Birth Picker Field
        Text(
          'Date of Birth',
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: _pickDateOfBirth,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: inputBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _selectedDob == null ? inputBorder : AppTheme.purpleElectric.withOpacity(0.5),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, color: AppTheme.primaryTeal, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedDob != null
                        ? DateFormat('dd MMMM yyyy').format(_selectedDob!)
                        : 'Select Date of Birth (DD / MM / YYYY)',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: _selectedDob != null ? textColor : textMuted,
                      fontWeight: _selectedDob != null ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                Icon(
                  Icons.event_available_rounded,
                  size: 18,
                  color: _selectedDob != null ? (isDark ? AppTheme.coralSunset : AppTheme.coralDark) : textMuted,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        // 4. Password (Box 1: Enter Password)
        Text(
          'Enter Password',
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _regPasswordController,
          obscureText: _obscureRegPassword,
          onChanged: (_) => setState(() {}),
          style: GoogleFonts.inter(color: textColor, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Enter new password (min. 6 characters)',
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.primaryTeal, size: 18),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureRegPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: textMuted,
                size: 18,
              ),
              onPressed: () => setState(() => _obscureRegPassword = !_obscureRegPassword),
            ),
            filled: true,
            fillColor: inputBg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),

        const SizedBox(height: 14),

        // 5. Password (Box 2: Re-enter Password)
        Text(
          'Re-enter Password',
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _regConfirmPasswordController,
          obscureText: _obscureRegConfirmPassword,
          onChanged: (_) => setState(() {}),
          style: GoogleFonts.inter(color: textColor, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Re-enter your password to confirm',
            prefixIcon: const Icon(Icons.lock_reset_rounded, color: AppTheme.primaryTeal, size: 18),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureRegConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: textMuted,
                size: 18,
              ),
              onPressed: () => setState(() => _obscureRegConfirmPassword = !_obscureRegConfirmPassword),
            ),
            filled: true,
            fillColor: inputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: hasConfirm
                    ? (passwordsMatch ? AppTheme.purpleGlow : AppTheme.riskCritical)
                    : inputBorder,
              ),
            ),
          ),
        ),

        // Live Match Feedback Indicator ("rendu match aithene theesukovaali")
        if (hasConfirm) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                passwordsMatch ? Icons.check_circle_rounded : Icons.cancel_rounded,
                size: 14,
                color: passwordsMatch ? (isDark ? AppTheme.coralSunset : AppTheme.coralDark) : AppTheme.riskCritical,
              ),
              const SizedBox(width: 6),
              Text(
                passwordsMatch
                    ? 'Passwords match verified!'
                    : 'Passwords do not match! Verify both entries.',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: passwordsMatch ? (isDark ? AppTheme.coralSunset : AppTheme.coralDark) : AppTheme.riskCritical,
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 24),

        // Register Action Button
        AnimatedGradientButton(
          onPressed: _handleRegister,
          icon: Icons.person_add_alt_1_rounded,
          text: 'Register & Launch SecOps',
        ),

        const SizedBox(height: 16),

        // Switch Back to Login
        Center(
          child: TextButton.icon(
            onPressed: () {
              setState(() {
                _isRegisterMode = false;
                _loginError = null;
              });
            },
            icon: const Icon(Icons.arrow_back_rounded, size: 16),
            label: const Text('Already registered? Back to Sign In'),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.riskCritical.withOpacity(0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.riskCritical.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppTheme.riskCritical, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.riskCritical,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip({
    required String label,
    required String email,
    required String pass,
    required Color color,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          _loginIdentifierController.text = email;
          _loginPasswordController.text = pass;
          _loginError = null;
        });
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSecurityAlertModal(AuthResult result) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF130E14) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final textMuted = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: dialogBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppTheme.riskCritical, width: 1.5),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.riskCritical.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.gpp_bad_rounded, color: AppTheme.riskCritical, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  result.code == AuthResultCode.disposableEmailRejected
                      ? 'Threat Block: Disposable Email'
                      : (result.code == AuthResultCode.userNotFound
                          ? 'Zero-Trust: Account Not Found'
                          : 'Security Check: Access Denied'),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.riskCritical.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'SECURITY PROTOCOL: ZERO_TRUST_ENFORCEMENT',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.riskCritical,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                result.errorMessage ?? 'Access denied by Riskora identity gateway.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: textMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1420) : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.riskCritical.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_moon_rounded, size: 16, color: AppTheme.coralSunset),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Riskora validates all identities against registered corporate SOC directories to prevent fake account infiltration.',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Dismiss'),
            ),
            if (result.code == AuthResultCode.userNotFound) ...[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.purpleElectric,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _isRegisterMode = true;
                    _regEmailController.text = _loginIdentifierController.text;
                    _regError = null;
                  });
                },
                child: const Text('Register Account'),
              ),
            ],
          ],
        );
      },
    );
  }

  void _showOtpVerificationDialog({
    required String name,
    required String email,
    required String password,
    required DateTime dob,
  }) {
    final otpController = TextEditingController(text: '202688');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: dialogBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: isDark ? AppTheme.border : AppTheme.lightBorder),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.purpleElectric.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.shield_outlined, color: AppTheme.purpleElectric, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                'SecOps 2FA Verification',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'A 6-digit cryptographic security code was generated for:',
                style: GoogleFonts.inter(fontSize: 12, color: textMuted),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.coralSunset : AppTheme.coralDark,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 22,
                  letterSpacing: 8,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '202688',
                  filled: true,
                  fillColor: isDark ? AppTheme.surfaceElevated : AppTheme.lightSurfaceElevated,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 14, color: AppTheme.primaryTeal),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Default SecOps demo verification code is pre-filled: 202688',
                      style: GoogleFonts.inter(fontSize: 11, color: AppTheme.primaryTeal),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.purpleElectric,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                if (otpController.text.trim().length != 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid 6-digit code.')),
                  );
                  return;
                }
                Navigator.pop(ctx);
                final provider = context.read<AppStateProvider>();
                final result = provider.registerNewUser(
                  name: name,
                  email: email,
                  dob: dob,
                  password: password,
                );

                if (result.success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Registration Approved! Corporate identity activated for $email.',
                              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: AppTheme.surfaceHigh,
                    ),
                  );
                } else {
                  setState(() => _regError = result.errorMessage);
                  _showSecurityAlertModal(result);
                }
              },
              child: const Text('Verify & Activate'),
            ),
          ],
        );
      },
    );
  }

  void _showGoogleSignInModal() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF111827) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final textMuted = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final borderCol = isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);

    final customGoogleEmailController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: dialogBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: borderCol, width: 1.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: borderCol,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _buildGoogleLogo(size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sign in with Google',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                            Text(
                              'Choose an account to continue to Riskora SecOps',
                              style: GoogleFonts.inter(fontSize: 12, color: textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),
                  _buildGoogleAccountTile(
                    ctx: ctx,
                    name: 'Sai Sudheer (Riskora Lead)',
                    email: 'saisudheer@riskora.ai',
                    avatarLetter: 'S',
                    avatarColor: const Color(0xFF4285F4),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  _buildGoogleAccountTile(
                    ctx: ctx,
                    name: 'Senior Threat Analyst',
                    email: 'analyst.riskora@gmail.com',
                    avatarLetter: 'A',
                    avatarColor: const Color(0xFF34A853),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  _buildGoogleAccountTile(
                    ctx: ctx,
                    name: 'Corporate SecOps Sentinel',
                    email: 'sentinel.ops@defense-corp.com',
                    avatarLetter: 'C',
                    avatarColor: const Color(0xFFEA4335),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  Text(
                    'Or authenticate with another Google Workspace account:',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: customGoogleEmailController,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.inter(color: textColor, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'name@organization.com or @gmail.com',
                            hintStyle: GoogleFonts.inter(color: textMuted, fontSize: 12),
                            prefixIcon: const Icon(Icons.account_circle_outlined, size: 18),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4285F4),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          final email = customGoogleEmailController.text.trim();
                          if (email.isEmpty || !email.contains('@')) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter a valid Google account email.')),
                            );
                            return;
                          }
                          Navigator.pop(ctx);
                          final namePart = email.split('@').first.replaceAll('.', ' ');
                          final capitalized = namePart
                              .split(' ')
                              .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
                              .join(' ');
                          context.read<AppStateProvider>().loginWithGoogleAccount(
                                name: capitalized.isEmpty ? 'Google User' : capitalized,
                                email: email,
                                avatarUrl: 'https://lh3.googleusercontent.com/a/default-user',
                              );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Google OAuth successful! Logged in as $email'),
                              backgroundColor: AppTheme.surfaceHigh,
                            ),
                          );
                        },
                        child: const Text('Verify & Go'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGoogleAccountTile({
    required BuildContext ctx,
    required String name,
    required String email,
    required String avatarLetter,
    required Color avatarColor,
    required bool isDark,
  }) {
    final textColor = isDark ? Colors.white : const Color(0xFF1F2937);
    final textMuted = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final hoverBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF3F4F6);

    return InkWell(
      onTap: () {
        Navigator.pop(ctx);
        context.read<AppStateProvider>().loginWithGoogleAccount(
              name: name,
              email: email,
              avatarUrl: 'https://lh3.googleusercontent.com/a/default-user',
            );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google OAuth successful! Logged in as $name ($email)'),
            backgroundColor: AppTheme.surfaceHigh,
          ),
        );
      },
      borderRadius: BorderRadius.circular(10),
      hoverColor: hoverBg,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: avatarColor,
              child: Text(
                avatarLetter,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: textColor,
                    ),
                  ),
                  Text(
                    email,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleLogo({double size = 20}) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      padding: EdgeInsets.all(size * 0.12),
      child: CustomPaint(
        painter: _GoogleGLogoPainter(),
      ),
    );
  }
}

class _GoogleGLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = size.width * 0.22;
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    final paintBlue = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final paintRed = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final paintYellow = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final paintGreen = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Red: Top arc
    canvas.drawArc(rect, 3.14159 * 1.1, 3.14159 * 0.55, false, paintRed);
    // Blue: Right-top arc
    canvas.drawArc(rect, 3.14159 * 1.65, 3.14159 * 0.45, false, paintBlue);
    // Yellow: Left arc
    canvas.drawArc(rect, 3.14159 * 0.65, 3.14159 * 0.45, false, paintYellow);
    // Green: Bottom arc
    canvas.drawArc(rect, 3.14159 * 0.1, 3.14159 * 0.55, false, paintGreen);

    // Blue horizontal bar
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(center.dx - 2, center.dy - strokeWidth / 2, radius + 2, strokeWidth),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
