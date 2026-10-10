import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
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
      setState(() => _loginError = 'Please enter your phone number or email.');
      return;
    }
    if (password.isEmpty) {
      setState(() => _loginError = 'Please enter your password.');
      return;
    }

    setState(() => _loginError = null);
    final provider = context.read<AppStateProvider>();
    final success = provider.login(identifier, password);
    if (!success) {
      setState(() => _loginError = 'Invalid credentials. Please verify and retry.');
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
      setState(() => _regError = 'Please enter a valid email address.');
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

    setState(() => _regError = null);
    final provider = context.read<AppStateProvider>();
    final success = provider.register(
      name: name,
      email: email,
      dob: _selectedDob!,
      password: password,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('SecOps account created successfully for $name!'),
          backgroundColor: AppTheme.surfaceHigh,
        ),
      );
    }
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
        const SizedBox(height: 24),

        if (_loginError != null) ...[
          _buildErrorBanner(_loginError!),
          const SizedBox(height: 16),
        ],

        // Phone Number or Email Input
        Text(
          'Phone Number or Email',
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _loginIdentifierController,
          keyboardType: TextInputType.emailAddress,
          style: GoogleFonts.inter(color: textColor, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Enter phone (+91...) or email address',
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

        const SizedBox(height: 16),

        // One-click Demo Account Login
        OutlinedButton.icon(
          onPressed: _handleQuickDemoLogin,
          icon: const Icon(Icons.bolt_rounded, size: 16),
          label: const Text('Quick Demo Login (admin@riskora.ai)'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
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
}
