import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';
import 'about_us_screen.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _orgController = TextEditingController();
  final _targetUrlController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedPriority = 'P1 Critical (Active Threat // 15-min SLA)';
  String _selectedPlatform = 'Instagram / Social Media';

  bool _isSubmitting = false;
  Map<String, dynamic>? _generatedTicket;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _orgController.dispose();
    _targetUrlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSubmitIncident() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    final ticketId = 'RK-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}-SEC';
    setState(() {
      _isSubmitting = false;
      _generatedTicket = {
        'id': ticketId,
        'timestamp': DateTime.now(),
        'priority': _selectedPriority,
        'platform': _selectedPlatform,
        'targetUrl': _targetUrlController.text.trim(),
        'assignedHandler': 'SecOps Triage Team // Level-3',
        'status': 'ENCRYPTED & DISPATCHED TO PLATFORM ABUSE DESK',
      };
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.verified_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Security Incident Ticket $ticketId created and routed to Level-3 SOC!',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.purpleElectric,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final isDark = provider.isDarkMode;
    final textColor = isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary;
    final textMuted = isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090D16) : AppTheme.lightBackground,
      body: Stack(
        children: [
          // Ambient Cyber Grid
          Positioned.fill(
            child: CustomPaint(
              painter: _CyberGridPainter(isDark: isDark),
            ),
          ),

          // Main Scrollable Content
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 80),

                // Hero Header
                _buildHeroHeader(context, isDark, textColor, textMuted),

                // Main Form & Live Ticket Display
                _buildMainPortalSection(context, isDark, textColor, textMuted),

                const SizedBox(height: 60),

                // Global SOC Operating Centers
                _buildGlobalSocSection(context, isDark, textColor, textMuted),

                const SizedBox(height: 60),

                // Direct Hotline Channels
                _buildDirectChannelsSection(context, isDark, textColor, textMuted),

                const SizedBox(height: 60),

                // Footer
                _buildFooter(context, isDark, textColor, textMuted),
              ],
            ),
          ),

          // Floating Top Navbar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopNavbar(context, provider, isDark, textColor),
          ),
        ],
      ),
    );
  }

  // --- FLOATING TOP NAVBAR ---
  Widget _buildTopNavbar(BuildContext context, AppStateProvider provider, bool isDark, Color textColor) {
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
              // Back Button to Home
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.surfaceElevated : AppTheme.lightSurfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: navBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_back_rounded, size: 16, color: Color(0xFF00E5FF)),
                      const SizedBox(width: 8),
                      Text(
                        'Home',
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: textColor),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Brand Emblem
              Container(
                width: 38,
                height: 38,
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
                  child: Image.asset('assets/images/riskora_emblem.png', fit: BoxFit.contain),
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
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.6,
                      color: textColor,
                    ),
                  ),
                  Text(
                    '24/7 INCIDENT DESK',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: const Color(0xFF00E5FF),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Quick About Us Link
              TextButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutUsScreen()),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: isDark ? Colors.white70 : AppTheme.lightTextSecondary,
                ),
                icon: const Icon(Icons.info_outline_rounded, size: 16),
                label: const Text('About Riskora'),
              ),

              const SizedBox(width: 12),

              // Theme Mode Toggle
              InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () => provider.toggleTheme(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.surfaceElevated : AppTheme.lightSurfaceElevated,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: navBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        size: 15,
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
            ],
          ),
        ),
      ),
    );
  }

  // --- HERO HEADER ---
  Widget _buildHeroHeader(BuildContext context, bool isDark, Color textColor, Color textMuted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      constraints: const BoxConstraints(maxWidth: 1100),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.coralSunset.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.coralSunset.withOpacity(0.4), width: 1.2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield_outlined, color: AppTheme.coralSunset, size: 16),
                const SizedBox(width: 8),
                Text(
                  '24/7/365 EMERGENCY SEC-OPS DISPATCH & ENTERPRISE INQUIRIES',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppTheme.coralSunset,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Report Live Impersonation\nor Schedule an Enterprise Security Briefing',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.6,
              height: 1.2,
              color: textColor,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Our Level-3 threat intelligence operators dispatch legally binding takedown packets to domain registrars, cloud hosts, and app store abuse teams with guaranteed SLAs.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: textMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // --- MAIN PORTAL SECTION ---
  Widget _buildMainPortalSection(BuildContext context, bool isDark, Color textColor, Color textMuted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      constraints: const BoxConstraints(maxWidth: 1100),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 800;

          return isNarrow
              ? Column(
                  children: [
                    _buildIncidentFormCard(context, isDark, textColor, textMuted),
                    const SizedBox(height: 24),
                    _buildLiveTicketPreview(context, isDark, textColor, textMuted),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: _buildIncidentFormCard(context, isDark, textColor, textMuted)),
                    const SizedBox(width: 24),
                    Expanded(flex: 5, child: _buildLiveTicketPreview(context, isDark, textColor, textMuted)),
                  ],
                );
        },
      ),
    );
  }

  // --- INCIDENT REPORT FORM CARD ---
  Widget _buildIncidentFormCard(BuildContext context, bool isDark, Color textColor, Color textMuted) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131726) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF232A40) : AppTheme.lightBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.security_rounded, color: Color(0xFF00E5FF), size: 22),
                const SizedBox(width: 10),
                Text(
                  'Incident Dispatch Form',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Submit verified coordinates of suspect profiles, fake apps, or phishing domains.',
              style: GoogleFonts.inter(fontSize: 12, color: textMuted),
            ),
            const SizedBox(height: 20),

            // Emergency Priority Selector
            Text('Urgency Level & Response SLA:', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              dropdownColor: isDark ? const Color(0xFF181D30) : Colors.white,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'P1 Critical (Active Threat // 15-min SLA)',
                  child: Text('P1 Critical (Active Threat // 15-min SLA)'),
                ),
                DropdownMenuItem(
                  value: 'P2 High (Verified Squatter // 2-hr SLA)',
                  child: Text('P2 High (Verified Squatter // 2-hr SLA)'),
                ),
                DropdownMenuItem(
                  value: 'P3 Enterprise (General Solution Briefing)',
                  child: Text('P3 Enterprise (General Solution Briefing)'),
                ),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedPriority = val);
              },
            ),
            const SizedBox(height: 16),

            // Full Name & Corporate Email
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nameController,
                    style: GoogleFonts.inter(color: textColor, fontSize: 13),
                    decoration: const InputDecoration(
                      labelText: 'Your Name *',
                      prefixIcon: Icon(Icons.person_outline_rounded, size: 18),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _emailController,
                    style: GoogleFonts.inter(color: textColor, fontSize: 13),
                    decoration: const InputDecoration(
                      labelText: 'Corporate Email *',
                      prefixIcon: Icon(Icons.email_outlined, size: 18),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Required';
                      if (!val.contains('@') || !val.contains('.')) return 'Invalid corporate email';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Organization & Brand Domain
            TextFormField(
              controller: _orgController,
              style: GoogleFonts.inter(color: textColor, fontSize: 13),
              decoration: const InputDecoration(
                labelText: 'Organization / Protected Brand Name *',
                hintText: 'e.g. Acme FinTech Corp',
                prefixIcon: Icon(Icons.business_outlined, size: 18),
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'Organization required' : null,
            ),
            const SizedBox(height: 14),

            // Channel / Target Platform
            DropdownButtonFormField<String>(
              value: _selectedPlatform,
              dropdownColor: isDark ? const Color(0xFF181D30) : Colors.white,
              decoration: const InputDecoration(
                labelText: 'Target Platform / Attack Vector',
                prefixIcon: Icon(Icons.public_rounded, size: 18),
              ),
              items: const [
                DropdownMenuItem(value: 'Instagram / Social Media', child: Text('Instagram / Meta')),
                DropdownMenuItem(value: 'Google Play / Android APK', child: Text('Google Play / Third-Party APK')),
                DropdownMenuItem(value: 'Apple App Store / iOS', child: Text('Apple App Store (iOS)')),
                DropdownMenuItem(value: 'Telegram / Dark Web Channel', child: Text('Telegram Escrow / Channel')),
                DropdownMenuItem(value: 'Phishing Domain / TypoSquat', child: Text('Phishing Domain / Typosquat')),
                DropdownMenuItem(value: 'X (Twitter) / Social Impersonator', child: Text('X (Twitter) Handle')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedPlatform = val);
              },
            ),
            const SizedBox(height: 14),

            // Target URL
            TextFormField(
              controller: _targetUrlController,
              style: GoogleFonts.jetBrainsMono(color: textColor, fontSize: 12),
              decoration: const InputDecoration(
                labelText: 'Infringing Profile URL / Package ID *',
                hintText: 'https://instagram.com/fake_brand_official or com.fake.apk',
                prefixIcon: Icon(Icons.link_rounded, size: 18),
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'URL / package ID required' : null,
            ),
            const SizedBox(height: 14),

            // Description / Evidence
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              style: GoogleFonts.inter(color: textColor, fontSize: 13),
              decoration: const InputDecoration(
                labelText: 'Incident Notes & Evidence Description',
                hintText: 'Describe how the impersonator is mimicking your trademarks or logos...',
              ),
            ),
            const SizedBox(height: 22),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _handleSubmitIncident,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.purpleElectric,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send_rounded, size: 18),
                label: Text(
                  _isSubmitting ? 'ENCRYPTING & DISPATCHING PACKET...' : 'DISPATCH SECURITY INCIDENT PACKET',
                  style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- LIVE TICKET PREVIEW CARD ---
  Widget _buildLiveTicketPreview(BuildContext context, bool isDark, Color textColor, Color textMuted) {
    if (_generatedTicket != null) {
      return Container(
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF101C2B) : const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF00E5FF), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E5FF).withOpacity(0.2),
              blurRadius: 24,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5FF).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'ACTIVE INCIDENT DISPATCH',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: const Color(0xFF00E5FF),
                    ),
                  ),
                ),
                const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 22),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _generatedTicket!['id'] as String,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Cryptographically signed packet transmitted to Level-3 Response Desk.',
              style: GoogleFonts.inter(fontSize: 12, color: textMuted),
            ),
            const SizedBox(height: 20),
            const Divider(color: Color(0xFF00E5FF), thickness: 0.8),
            const SizedBox(height: 14),
            _buildTicketRow('Priority Tier', _generatedTicket!['priority'] as String, textColor),
            _buildTicketRow('Vector Channel', _generatedTicket!['platform'] as String, textColor),
            _buildTicketRow('Suspect Target', _generatedTicket!['targetUrl'] as String, textColor),
            _buildTicketRow('Assigned Handler', _generatedTicket!['assignedHandler'] as String, textColor),
            _buildTicketRow('SLA Status', 'Active Clock Running (15-min SLA)', const Color(0xFF10B981)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                setState(() => _generatedTicket = null);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF).withOpacity(0.15),
                foregroundColor: const Color(0xFF00E5FF),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('File Another Incident'),
            ),
          ],
        ),
      );
    }

    // Default SLA Guarantee Card
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131726) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF232A40) : AppTheme.lightBorder,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user_rounded, color: Color(0xFF00E5FF), size: 22),
              const SizedBox(width: 10),
              Text(
                'Enterprise SLA Standards',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSlaPill('15-Minute Critical Response', 'Phishing domains and malicious Android APKs are prioritized with automated abuse ticket generation within 15 minutes of submission.', const Color(0xFFFF7474)),
          const SizedBox(height: 14),
          _buildSlaPill('2-Hour Social Takedown Window', 'Direct API and escalation channels with Meta, X, and Telegram legal desks ensure rapid profile de-indexing.', AppTheme.coralSunset),
          const SizedBox(height: 14),
          _buildSlaPill('Cryptographic Chain of Custody', 'Every scraped screenshot, hash, and metadata payload is timestamped and cryptographically archived for court-admissible IP enforcement.', const Color(0xFF00E5FF)),
        ],
      ),
    );
  }

  Widget _buildTicketRow(String label, String value, Color valColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.w700, color: valColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlaPill(String title, String desc, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt_rounded, size: 16, color: accentColor),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: GoogleFonts.inter(fontSize: 12, height: 1.5, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  // --- GLOBAL SOC SECTION ---
  Widget _buildGlobalSocSection(BuildContext context, bool isDark, Color textColor, Color textMuted) {
    final hubs = [
      {'city': 'San Francisco, CA', 'label': 'Americas HQ & Legal Takedown Desk', 'tz': 'Pacific (PT)', 'phone': '+1 (415) 890-RISK', 'email': 'sf-soc@riskora.ai', 'color': const Color(0xFF00E5FF)},
      {'city': 'London, UK', 'label': 'EMEA Cyber Defense Hub', 'tz': 'GMT / BST', 'phone': '+44 (20) 7946-0921', 'email': 'london-soc@riskora.ai', 'color': AppTheme.purpleGlow},
      {'city': 'Singapore', 'label': 'APAC Threat Intelligence Lab', 'tz': 'SGT (UTC+8)', 'phone': '+65 6789 0123', 'email': 'apac-soc@riskora.ai', 'color': AppTheme.coralSunset},
      {'city': 'Hyderabad, India', 'label': 'Autonomous AI Neural R&D Center', 'tz': 'IST (UTC+5:30)', 'phone': '+91 (40) 4821-RISK', 'email': 'hyd-soc@riskora.ai', 'color': const Color(0xFF34D399)},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      constraints: const BoxConstraints(maxWidth: 1100),
      child: Column(
        children: [
          Text(
            'GLOBAL SECURITY OPERATIONS CENTERS',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.8,
              color: const Color(0xFF00E5FF),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '24/7 Follow-the-Sun Threat Intelligence',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(fontSize: 30, fontWeight: FontWeight.w800, color: textColor),
          ),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 750;
              final width = isNarrow ? constraints.maxWidth : (constraints.maxWidth - 48) / 4;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: hubs.map((h) {
                  final color = h['color'] as Color;
                  return Container(
                    width: width,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF131726) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF232A40) : AppTheme.lightBorder,
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color,
                                boxShadow: [BoxShadow(color: color, blurRadius: 6)],
                              ),
                            ),
                            Text(
                              h['tz'] as String,
                              style: GoogleFonts.jetBrainsMono(fontSize: 10, color: color, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          h['city'] as String,
                          style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: textColor),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          h['label'] as String,
                          style: GoogleFonts.inter(fontSize: 11, color: textMuted),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          h['phone'] as String,
                          style: GoogleFonts.jetBrainsMono(fontSize: 11, color: textColor, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          h['email'] as String,
                          style: GoogleFonts.jetBrainsMono(fontSize: 11, color: color),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- DIRECT CHANNELS SECTION ---
  Widget _buildDirectChannelsSection(BuildContext context, bool isDark, Color textColor, Color textMuted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      constraints: const BoxConstraints(maxWidth: 1100),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131726) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.purpleElectric.withOpacity(0.4), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.purpleElectric.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.lock_clock_rounded, color: AppTheme.purpleGlow, size: 36),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Direct Abuse Desk PGP Encrypted Inbox',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'For classified disclosures or enterprise emergency escalations, transmit PGP-encrypted intelligence to: abuse-desk@riskora.ai (Key ID: 0x9B2A7E14)',
                    style: GoogleFonts.inter(fontSize: 13, color: textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- FOOTER ---
  Widget _buildFooter(BuildContext context, bool isDark, Color textColor, Color textMuted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: isDark ? AppTheme.border : AppTheme.lightBorder)),
      ),
      child: Center(
        child: Text(
          '© 2026 RISKORA DRP PLATFORM. All rights reserved. Zero-Trust Impersonation Defense.',
          style: GoogleFonts.inter(fontSize: 12, color: textMuted),
        ),
      ),
    );
  }
}

class _CyberGridPainter extends CustomPainter {
  final bool isDark;
  const _CyberGridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark
          ? const Color(0xFF00E5FF).withOpacity(0.025)
          : const Color(0xFF5D2EE6).withOpacity(0.035)
      ..strokeWidth = 1.0;

    const step = 48.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
