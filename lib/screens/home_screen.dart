import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_gradient_button.dart';
import '../widgets/red_points_background.dart';
import 'about_us_screen.dart';
import 'contact_us_screen.dart';

/// Red Points-inspired public Landing / Home Page for RISKORA.
/// Features:
/// - Looping animated cyber motion video background (338222_medium.mp4)
/// - Top Navbar: Home, About us, Contact us, Login
/// - Top-Right Dark and Light theme toggle
/// - Smooth scroll navigation to sections
/// - Red Points cybersecurity palette (Electric Purple & Sunset Coral)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

  // Contact Form Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _companyController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmittingContact = false;

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _scrollTo(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _handleContactSubmit() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final company = _companyController.text.trim();

    if (name.isEmpty || email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide your name and a valid corporate email.'),
          backgroundColor: AppTheme.riskCritical,
        ),
      );
      return;
    }

    setState(() => _isSubmittingContact = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _isSubmittingContact = false;
        _nameController.clear();
        _emailController.clear();
        _companyController.clear();
        _messageController.clear();
      });

      showDialog(
        context: context,
        builder: (ctx) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          return AlertDialog(
            backgroundColor: isDark ? AppTheme.surface : AppTheme.lightSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: isDark ? AppTheme.border : AppTheme.lightBorder),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.coralSunset.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.verified_user_rounded, color: AppTheme.coralSunset, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  'Threat Brief Dispatched',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                  ),
                ),
              ],
            ),
            content: Text(
              'Thank you, $name. A RISKORA SecOps threat specialist has received your inquiry for $company and will initialize your enterprise perimeter assessment within 15 minutes.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                height: 1.5,
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.purpleElectric,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Acknowledge'),
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 680 && screenWidth < 1024;

    return RedPointsBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Scrollable Page Content
            Positioned.fill(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    const SizedBox(height: 80), // Navbar spacer

                    // 1. HERO SECTION (Home)
                    Container(
                      key: _homeKey,
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 64 : (isTablet ? 36 : 20),
                        vertical: isDesktop ? 64 : 40,
                      ),
                      constraints: const BoxConstraints(maxWidth: 1280),
                      child: _buildHeroSection(isDark, isDesktop),
                    ),

                    // Metrics Banner
                    _buildMetricsBanner(isDark, isDesktop),

                    const SizedBox(height: 48),

                    // 2. ABOUT US SECTION
                    Container(
                      key: _aboutKey,
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 64 : (isTablet ? 36 : 20),
                        vertical: isDesktop ? 64 : 48,
                      ),
                      constraints: const BoxConstraints(maxWidth: 1280),
                      child: _buildAboutSection(isDark, isDesktop),
                    ),

                    const SizedBox(height: 32),

                    // Live Threat Simulation Preview Card
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 64 : (isTablet ? 36 : 20),
                        vertical: 24,
                      ),
                      constraints: const BoxConstraints(maxWidth: 1280),
                      child: _buildLiveThreatPreviewCard(isDark, isDesktop),
                    ),

                    const SizedBox(height: 48),

                    // 3. CONTACT US SECTION
                    Container(
                      key: _contactKey,
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 64 : (isTablet ? 36 : 20),
                        vertical: isDesktop ? 64 : 48,
                      ),
                      constraints: const BoxConstraints(maxWidth: 1280),
                      child: _buildContactSection(isDark, isDesktop),
                    ),

                    // 4. FOOTER
                    _buildFooter(isDark, isDesktop),
                  ],
                ),
              ),
            ),

            // Sticky Top Navigation Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildTopNavbar(isDark, isDesktop),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // --- TOP NAVBAR ---
  // ==========================================
  Widget _buildTopNavbar(bool isDark, bool isDesktop) {
    final provider = context.watch<AppStateProvider>();
    final textColor = isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary;
    final navBg = isDark ? const Color(0xFF0D0C15) : Colors.white;
    final navBorder = isDark ? AppTheme.border : AppTheme.lightBorder;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: navBg.withOpacity(isDark ? 0.88 : 0.94),
            border: Border(bottom: BorderSide(color: navBorder, width: 1.0)),
          ),
          child: Row(
            children: [
              // Brand Logo (Clicking scrolls to top)
              InkWell(
                onTap: () => _scrollTo(_homeKey),
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00E5FF).withOpacity(0.35),
                            blurRadius: 14,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/images/riskora_emblem.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RISKORA',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.6,
                            color: textColor,
                          ),
                        ),
                        Text(
                          'SEC-OPS AI',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: isDark ? AppTheme.coralSunset : AppTheme.coralDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Center Nav Links (Desktop & Tablet)
              if (isDesktop) ...[
                _buildNavLink('Home', () => _scrollTo(_homeKey), textColor, isActive: true),
                const SizedBox(width: 8),
                _buildNavLink(
                  'About us',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutUsScreen()),
                  ),
                  textColor,
                ),
                const SizedBox(width: 8),
                _buildNavLink(
                  'Contact us',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ContactUsScreen()),
                  ),
                  textColor,
                ),
                const SizedBox(width: 24),
              ],

              // TOP-RIGHT THEME TOGGLE (Requested by user)
              Tooltip(
                message: isDark ? 'Switch to Clean Light Theme' : 'Switch to Stealth Dark Theme',
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () => provider.toggleTheme(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.surfaceElevated : AppTheme.lightSurfaceElevated,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isDark ? AppTheme.border : AppTheme.lightBorder,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                          size: 16,
                          color: isDark ? AppTheme.coralSunset : AppTheme.purpleElectric,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isDark ? 'Light' : 'Dark',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // LOGIN BUTTON IN NAVBAR (Requested by user)
              ElevatedButton.icon(
                key: const ValueKey('nav_login_btn'),
                onPressed: () => provider.openAuthScreen(),
                icon: const Icon(Icons.login_rounded, size: 16),
                label: const Text('Login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.purpleElectric,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),

              // Mobile Menu Button
              if (!isDesktop) ...[
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  color: textColor,
                  onPressed: () => _showMobileNavSheet(isDark),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavLink(String title, VoidCallback onTap, Color textColor, {bool isActive = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? AppTheme.purpleGlow : textColor.withOpacity(0.85),
          ),
        ),
      ),
    );
  }

  void _showMobileNavSheet(bool isDark) {
    final provider = context.read<AppStateProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.surface : AppTheme.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  leading: const Icon(Icons.home_rounded, color: AppTheme.purpleGlow),
                  title: const Text('Home'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _scrollTo(_homeKey);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded, color: AppTheme.coralSunset),
                  title: const Text('About us'),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutUsScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.mail_outline_rounded, color: AppTheme.primaryTeal),
                  title: const Text('Contact us'),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ContactUsScreen()),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.login_rounded, color: AppTheme.purpleElectric),
                  title: const Text('Login to SecOps Matrix', style: TextStyle(fontWeight: FontWeight.w700)),
                  onTap: () {
                    Navigator.pop(ctx);
                    provider.openAuthScreen();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // --- 1. HERO SECTION ---
  // ==========================================
  Widget _buildHeroSection(bool isDark, bool isDesktop) {
    final provider = context.read<AppStateProvider>();
    final textColor = isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary;
    final textMuted = isDark ? AppTheme.textMuted : AppTheme.lightTextMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Live Status Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.purpleElectric.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.purpleElectric.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.coralSunset,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'AUTONOMOUS DIGITAL RISK & BRAND DEFENSE',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: isDark ? AppTheme.coralSunset : AppTheme.coralDark,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Main Headline
        Text(
          'Eliminate Digital Threats & Impersonators at Machine Speed',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: isDesktop ? 48 : 32,
            fontWeight: FontWeight.w900,
            height: 1.15,
            letterSpacing: -1.0,
            color: textColor,
          ),
        ),

        const SizedBox(height: 18),

        // Subtitle
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 780),
          child: Text(
            'RISKORA continuously monitors social channels, global app repositories, and domain registrars. Our AI computer vision and automated takedown workflows neutralize copyright infringement and phishing before damage occurs.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: isDesktop ? 16 : 14,
              color: textMuted,
              height: 1.6,
            ),
          ),
        ),

        const SizedBox(height: 36),

        // Dual CTA Buttons
        Wrap(
          spacing: 16,
          runSpacing: 14,
          alignment: WrapAlignment.center,
          children: [
            AnimatedGradientButton(
              onPressed: () => provider.openAuthScreen(),
              icon: Icons.shield_rounded,
              text: 'Access SecOps Portal (Login)',
            ),
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactUsScreen()),
              ),
              icon: const Icon(Icons.calendar_month_rounded, size: 16),
              label: const Text('Request Enterprise Assessment'),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? AppTheme.textPrimary : AppTheme.purpleElectric,
                side: BorderSide(
                  color: isDark ? AppTheme.border : AppTheme.purpleElectric,
                  width: 1.4,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // --- METRICS BANNER ---
  // ==========================================
  Widget _buildMetricsBanner(bool isDark, bool isDesktop) {
    final cardBg = isDark ? AppTheme.surface : AppTheme.lightSurface;
    final cardBorder = isDark ? AppTheme.border : AppTheme.lightBorder;

    final metrics = [
      {'val': '99.4%', 'label': 'AI Detection Accuracy', 'sub': 'Neural vision matching'},
      {'val': '< 2.4h', 'label': 'Avg. Takedown SLA', 'sub': 'Automated legal notices'},
      {'val': '10M+', 'label': 'Digital Assets Scanned', 'sub': 'Continuous 24/7 telemetry'},
      {'val': '120+', 'label': 'Marketplaces Covered', 'sub': 'Social, App stores & Web'},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      constraints: const BoxConstraints(maxWidth: 1200),
      decoration: BoxDecoration(
        color: cardBg.withOpacity(isDark ? 0.85 : 0.95),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardBorder),
        boxShadow: isDark ? AppTheme.cardShadow : AppTheme.lightCardShadow,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 700;
          if (isNarrow) {
            return Column(
              children: metrics.map((m) => _buildMetricItem(m, isDark)).toList(),
            );
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: metrics.map((m) => Expanded(child: _buildMetricItem(m, isDark))).toList(),
          );
        },
      ),
    );
  }

  Widget _buildMetricItem(Map<String, String> m, bool isDark) {
    final textColor = isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary;
    final textMuted = isDark ? AppTheme.textMuted : AppTheme.lightTextMuted;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => AppTheme.redPointsGradient.createShader(bounds),
            child: Text(
              m['val']!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            m['label']!,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            m['sub']!,
            style: GoogleFonts.inter(fontSize: 11, color: textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // --- 2. ABOUT US SECTION ---
  // ==========================================
  Widget _buildAboutSection(bool isDark, bool isDesktop) {
    final textColor = isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary;
    final textMuted = isDark ? AppTheme.textMuted : AppTheme.lightTextMuted;

    final features = [
      {
        'icon': Icons.people_alt_rounded,
        'title': 'Social Media Impersonation Defense',
        'desc': 'Track Instagram, TikTok, Telegram, X, and Facebook. Spot cloned handles, fake brand customer support handles, and malicious account squatting.',
        'tag': 'SOCIAL MONITORING',
        'color': AppTheme.purpleElectric,
      },
      {
        'icon': Icons.install_mobile_rounded,
        'title': 'Rogue Mobile App Delisting',
        'desc': 'Monitor Google Play and third-party APK sources for malicious clones, trojanized binaries, and unauthorized publisher brand abuse.',
        'tag': 'APP STORE SHIELD',
        'color': AppTheme.coralSunset,
      },
      {
        'icon': Icons.gavel_rounded,
        'title': 'Automated Legal & API Takedowns',
        'desc': 'Generate timestamped cryptographic evidence packages. Dispatch automated DMCA takedown requests with registrar & platform escalation.',
        'tag': 'LEGAL AUTOMATION',
        'color': AppTheme.purpleGlow,
      },
      {
        'icon': Icons.visibility_rounded,
        'title': 'AI Trademark & Computer Vision',
        'desc': 'Deep neural networks identify cropped, inverted, and altered brand logos with 99.4% precision, bypassing keyword evasion techniques.',
        'tag': 'NEURAL VISION',
        'color': AppTheme.coralDark,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Section Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.coralSunset.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.coralSunset.withOpacity(0.4)),
          ),
          child: Text(
            'ABOUT RISKORA INTELLIGENCE',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: isDark ? AppTheme.coralSunset : AppTheme.coralDark,
            ),
          ),
        ),

        const SizedBox(height: 16),

        Text(
          'Next-Generation Digital Asset Protection',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: isDesktop ? 36 : 26,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),

        const SizedBox(height: 12),

        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Text(
            'Traditional copyright enforcement is too slow for the digital age. Riskora integrates continuous crawlers, AI computer vision, and legal enforcement into a single autonomous workflow.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: textMuted, height: 1.5),
          ),
        ),

        const SizedBox(height: 48),

        // Features Grid
        LayoutBuilder(
          builder: (context, constraints) {
            final is2Col = constraints.maxWidth > 720;
            return Wrap(
              spacing: 20,
              runSpacing: 20,
              children: features.map((f) {
                final width = is2Col ? (constraints.maxWidth - 20) / 2 : constraints.maxWidth;
                return SizedBox(
                  width: width,
                  child: _buildFeatureCard(f, isDark),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeatureCard(Map<String, dynamic> f, bool isDark) {
    final cardBg = isDark ? AppTheme.surface : AppTheme.lightSurface;
    final cardBorder = isDark ? AppTheme.border : AppTheme.lightBorder;
    final textColor = isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary;
    final textMuted = isDark ? AppTheme.textMuted : AppTheme.lightTextMuted;
    final Color iconColor = f['color'] as Color;

    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: cardBg.withOpacity(isDark ? 0.88 : 0.96),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
        boxShadow: isDark ? AppTheme.cardShadow : AppTheme.lightCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: iconColor.withOpacity(0.3)),
                ),
                child: Icon(f['icon'] as IconData, color: iconColor, size: 22),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  f['tag'] as String,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            f['title'] as String,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            f['desc'] as String,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: textMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // --- LIVE THREAT PREVIEW CARD ---
  // ==========================================
  Widget _buildLiveThreatPreviewCard(bool isDark, bool isDesktop) {
    final cardBg = isDark ? AppTheme.surfaceElevated : AppTheme.lightSurfaceElevated;
    final cardBorder = isDark ? AppTheme.border : AppTheme.lightBorder;
    final textColor = isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: cardBg.withOpacity(isDark ? 0.92 : 0.96),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.purpleElectric.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.coralSunset.withOpacity(0.2),
                ),
                child: const Icon(Icons.radar_rounded, color: AppTheme.coralSunset, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LIVE THREAT INTERCEPTION MATRIX',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: textColor,
                    ),
                  ),
                  Text(
                    'Real-time simulation connected to active threat crawler nodes',
                    style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.mintGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '● FEEDS ONLINE',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.mintGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 14),
          _buildSimulationFeedRow(
            channel: 'INSTAGRAM',
            handle: '@riskora_official_rewards',
            infringement: 'Impersonation & Phishing Link',
            status: 'Delisted & Suspended',
            statusColor: AppTheme.riskCritical,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _buildSimulationFeedRow(
            channel: 'GOOGLE PLAY',
            handle: 'com.riskora.security.fakeapk',
            infringement: 'Trojanized APK Package Clone',
            status: 'DMCA Takedown Dispatched',
            statusColor: AppTheme.coralSunset,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _buildSimulationFeedRow(
            channel: 'TELEGRAM',
            handle: 't.me/riskora_crypto_support',
            infringement: 'Brand Logo Typosquatting',
            status: 'Evidence Pack Dispatched',
            statusColor: AppTheme.purpleGlow,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSimulationFeedRow({
    required String channel,
    required String handle,
    required String infringement,
    required String status,
    required Color statusColor,
    required bool isDark,
  }) {
    final textColor = isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141322) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? AppTheme.borderSubtle : AppTheme.lightBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.purpleElectric.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              channel,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppTheme.purpleGlow,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  handle,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                Text(
                  infringement,
                  style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Text(
              status,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // --- 3. CONTACT US SECTION ---
  // ==========================================
  Widget _buildContactSection(bool isDark, bool isDesktop) {
    final cardBg = isDark ? AppTheme.surface : AppTheme.lightSurface;
    final cardBorder = isDark ? AppTheme.border : AppTheme.lightBorder;
    final textColor = isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary;
    final textMuted = isDark ? AppTheme.textMuted : AppTheme.lightTextMuted;
    final inputBg = isDark ? AppTheme.surfaceElevated : AppTheme.lightSurfaceElevated;
    final inputBorder = isDark ? AppTheme.border : AppTheme.lightBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Section Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.purpleElectric.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.purpleElectric.withOpacity(0.4)),
          ),
          child: Text(
            'CONNECT WITH SECOPS',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppTheme.purpleGlow,
            ),
          ),
        ),

        const SizedBox(height: 16),

        Text(
          'Request an Enterprise Threat Assessment',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: isDesktop ? 36 : 26,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),

        const SizedBox(height: 12),

        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Text(
            'Speak with a certified brand protection engineer. We will scan your digital perimeter and provide a confidential threat dossier within 15 minutes.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: textMuted, height: 1.5),
          ),
        ),

        const SizedBox(height: 40),

        // Contact Container (Form + Info)
        Container(
          padding: EdgeInsets.all(isDesktop ? 36 : 22),
          decoration: BoxDecoration(
            color: cardBg.withOpacity(isDark ? 0.90 : 0.96),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cardBorder),
            boxShadow: isDark ? AppTheme.cardShadow : AppTheme.lightCardShadow,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final is2Col = constraints.maxWidth > 760;

              if (is2Col) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: Form
                    Expanded(
                      flex: 6,
                      child: _buildContactForm(isDark, inputBg, inputBorder, textColor),
                    ),
                    const SizedBox(width: 40),
                    // Right: Direct Info
                    Expanded(
                      flex: 4,
                      child: _buildContactInfoSide(isDark, textColor, textMuted),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  _buildContactForm(isDark, inputBg, inputBorder, textColor),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 24),
                  _buildContactInfoSide(isDark, textColor, textMuted),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContactForm(bool isDark, Color inputBg, Color inputBorder, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Confidential Threat Inquiry',
          style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: textColor),
        ),
        const SizedBox(height: 20),

        TextField(
          controller: _nameController,
          style: GoogleFonts.inter(color: textColor, fontSize: 13),
          decoration: InputDecoration(
            labelText: 'Full Name',
            hintText: 'e.g. Sai Sudheer',
            prefixIcon: const Icon(Icons.person_outline_rounded, color: AppTheme.primaryTeal, size: 18),
            filled: true,
            fillColor: inputBg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 14),

        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: GoogleFonts.inter(color: textColor, fontSize: 13),
          decoration: InputDecoration(
            labelText: 'Corporate Email',
            hintText: 'e.g. analyst@company.com',
            prefixIcon: const Icon(Icons.mail_outline_rounded, color: AppTheme.primaryTeal, size: 18),
            filled: true,
            fillColor: inputBg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 14),

        TextField(
          controller: _companyController,
          style: GoogleFonts.inter(color: textColor, fontSize: 13),
          decoration: InputDecoration(
            labelText: 'Company / Brand Entity',
            hintText: 'e.g. Enterprise Corp',
            prefixIcon: const Icon(Icons.business_outlined, color: AppTheme.primaryTeal, size: 18),
            filled: true,
            fillColor: inputBg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 14),

        TextField(
          controller: _messageController,
          maxLines: 3,
          style: GoogleFonts.inter(color: textColor, fontSize: 13),
          decoration: InputDecoration(
            labelText: 'Threat Context / Perimeter Notes',
            hintText: 'Tell us which social handles or fake apps to inspect...',
            filled: true,
            fillColor: inputBg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 24),

        ElevatedButton(
          onPressed: _isSubmittingContact ? null : _handleContactSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.purpleElectric,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: _isSubmittingContact
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text(
                  'Submit Assessment Request',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
        ),
      ],
    );
  }

  Widget _buildContactInfoSide(bool isDark, Color textColor, Color textMuted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SecOps Direct Channels',
          style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: textColor),
        ),
        const SizedBox(height: 16),
        _buildContactDetailItem(Icons.email_outlined, 'Direct Email', 'security@riskora.ai', textColor, textMuted),
        const SizedBox(height: 14),
        _buildContactDetailItem(Icons.phone_in_talk_outlined, 'Emergency Hotline', '+1 (800) 747-5672 (24/7 Desk)', textColor, textMuted),
        const SizedBox(height: 14),
        _buildContactDetailItem(Icons.speed_rounded, 'Response SLA', '< 15 Minutes for Critical Threats', textColor, textMuted),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.coralSunset.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.coralSunset.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ENTERPRISE COMPLIANCE',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppTheme.coralSunset : AppTheme.coralDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Compliant with SOC 2 Type II, ISO/IEC 27001, and GDPR Article 32 cryptographic standards.',
                style: GoogleFonts.inter(fontSize: 12, color: textMuted, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactDetailItem(IconData icon, String title, String val, Color textColor, Color textMuted) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppTheme.purpleGlow),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 11, color: textMuted)),
              Text(val, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // --- 4. FOOTER ---
  // ==========================================
  Widget _buildFooter(bool isDark, bool isDesktop) {
    final footerBg = isDark ? const Color(0xFF0A0912) : const Color(0xFFEBF0F8);
    final footerBorder = isDark ? AppTheme.borderSubtle : AppTheme.lightBorder;
    final textColor = isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary;
    final textMuted = isDark ? AppTheme.textMuted : AppTheme.lightTextMuted;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 24,
        vertical: 36,
      ),
      decoration: BoxDecoration(
        color: footerBg,
        border: Border(top: BorderSide(color: footerBorder)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E5FF).withOpacity(0.35),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/riskora_emblem.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'RISKORA',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 16,
                children: [
                  InkWell(
                    onTap: () => _scrollTo(_homeKey),
                    child: Text('Home', style: GoogleFonts.inter(fontSize: 12, color: textMuted)),
                  ),
                  InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutUsScreen()),
                    ),
                    child: Text('About us', style: GoogleFonts.inter(fontSize: 12, color: textMuted)),
                  ),
                  InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ContactUsScreen()),
                    ),
                    child: Text('Contact us', style: GoogleFonts.inter(fontSize: 12, color: textMuted)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          Text(
            '© 2026 RISKORA Technologies. Built with intelligent Red Points-inspired cybersecurity architecture.',
            style: GoogleFonts.inter(fontSize: 11, color: textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
