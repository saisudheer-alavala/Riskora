import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';
import 'contact_us_screen.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

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
          // Cyber Grid Ambient Canvas
          Positioned.fill(
            child: CustomPaint(
              painter: _CyberGridPainter(isDark: isDark),
            ),
          ),

          // Main Scrollable Content
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 80), // Offset for floating navbar
                // Hero Section
                _buildHeroHeader(context, isDark, textColor, textMuted),

                // Key Metric Counter Cards
                _buildMetricsRow(context, isDark),

                const SizedBox(height: 60),

                // Mission & Vision Dual Hologram Cards
                _buildMissionVisionSection(context, isDark, textColor, textMuted),

                const SizedBox(height: 60),

                // 4 Pillars of Defense Matrix
                _buildArchitectureSection(context, isDark, textColor, textMuted),

                const SizedBox(height: 60),

                // Leadership & Threat Intel Team
                _buildLeadershipSection(context, isDark, textColor, textMuted),

                const SizedBox(height: 60),

                // Compliance & Trust Accreditations
                _buildComplianceSection(context, isDark, textColor, textMuted),

                const SizedBox(height: 60),

                // Bottom Call To Action Banner
                _buildCtaBanner(context, isDark),

                const SizedBox(height: 60),

                // Footer
                _buildFooter(context, isDark, textColor, textMuted),
              ],
            ),
          ),

          // Floating Top Navigation Bar
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
                    'ABOUT OUR MISSION',
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

              // Quick Contact Us Link
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const ContactUsScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF00E5FF), width: 1.2),
                  foregroundColor: const Color(0xFF00E5FF),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.headset_mic_rounded, size: 16),
                label: const Text('Contact SecOps'),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      constraints: const BoxConstraints(maxWidth: 1100),
      child: Column(
        children: [
          // Cyber Security Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF).withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.4), width: 1.2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_user_rounded, color: Color(0xFF00E5FF), size: 16),
                const SizedBox(width: 8),
                Text(
                  'GLOBAL DIGITAL RISK PROTECTION PLATFORM',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                    color: const Color(0xFF00E5FF),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'We Defend Global Enterprises\nAgainst Digital Impersonation & Brand Piracy',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 38,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
              height: 1.2,
              color: textColor,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Riskora combines autonomous vision transformers, distributed threat crawlers, and automated legal enforcement takedown pipelines to neutralize counterfeiters, rogue apps, and credential phishing syndicates in real time.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: textMuted,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // --- METRIC COUNTERS ---
  Widget _buildMetricsRow(BuildContext context, bool isDark) {
    final metrics = [
      {'val': '1.8M+', 'label': 'Impersonation Vectors Neutralized', 'icon': Icons.shield_rounded, 'color': const Color(0xFF00E5FF)},
      {'val': '99.4%', 'label': 'Vision Logo Match Precision', 'icon': Icons.remove_red_eye_rounded, 'color': AppTheme.purpleGlow},
      {'val': '< 45 min', 'label': 'Average Takedown Resolution SLA', 'icon': Icons.bolt_rounded, 'color': AppTheme.coralSunset},
      {'val': '140+', 'label': 'Global Tier-1 Enterprise Brands', 'icon': Icons.business_rounded, 'color': const Color(0xFF34D399)},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      constraints: const BoxConstraints(maxWidth: 1100),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 700;
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: metrics.map((m) {
              final width = isNarrow ? constraints.maxWidth : (constraints.maxWidth - 48) / 4;
              return Container(
                width: width,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF131726) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF232A40) : AppTheme.lightBorder,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (m['color'] as Color).withOpacity(0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(m['icon'] as IconData, color: m['color'] as Color, size: 28),
                    const SizedBox(height: 14),
                    Text(
                      m['val'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: m['color'] as Color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      m['label'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : AppTheme.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  // --- MISSION & VISION SECTION ---
  Widget _buildMissionVisionSection(BuildContext context, bool isDark, Color textColor, Color textMuted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      constraints: const BoxConstraints(maxWidth: 1100),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 750;
          final cardWidth = isNarrow ? constraints.maxWidth : (constraints.maxWidth - 20) / 2;

          return Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              // Mission Card
              _buildFeatureCard(
                width: cardWidth,
                isDark: isDark,
                accentColor: const Color(0xFF00E5FF),
                icon: Icons.rocket_launch_rounded,
                badge: 'OUR MISSION',
                title: 'Continuous Autonomous Brand Defense',
                description:
                    'To safeguard the intellectual property, digital trust, and commercial integrity of enterprises through autonomous real-time intelligence that identifies, correlates, and eradicates brand abuse before customers are defrauded.',
              ),
              // Vision Card
              _buildFeatureCard(
                width: cardWidth,
                isDark: isDark,
                accentColor: AppTheme.purpleGlow,
                icon: Icons.all_inclusive_rounded,
                badge: 'OUR VISION',
                title: 'A Zero-Impersonation Digital Ecosystem',
                description:
                    'To establish an impenetrable digital frontier where cyber impersonators, malicious APK trojans, and phishing syndicates cannot exploit legitimate corporate identities without instant, automated takedown retribution.',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFeatureCard({
    required double width,
    required bool isDark,
    required Color accentColor,
    required IconData icon,
    required String badge,
    required String title,
    required String description,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131726) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.14),
            blurRadius: 24,
            offset: const Offset(0, 6),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 26),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: accentColor.withOpacity(0.3)),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppTheme.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.6,
              color: isDark ? Colors.white70 : AppTheme.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // --- 4 PILLARS OF DEFENSE MATRIX ---
  Widget _buildArchitectureSection(BuildContext context, bool isDark, Color textColor, Color textMuted) {
    final pillars = [
      {
        'num': '01',
        'title': 'Neural Logo Vision Transformer',
        'desc': 'Deep convolutional vision embeddings compare logos with sub-pixel sensitivity to uncover rotated, inverted, or recolored trademarks.',
        'icon': Icons.psychology_rounded,
        'color': const Color(0xFF00E5FF),
      },
      {
        'num': '02',
        'title': 'Cross-Platform Crawler Swarm',
        'desc': 'Autonomous headless worker nodes inspect Google Play, Apple AppStore, Instagram, X/Twitter, Telegram, and 12+ APK mirrors 24/7.',
        'icon': Icons.hub_rounded,
        'color': AppTheme.purpleGlow,
      },
      {
        'num': '03',
        'title': 'Levenshtein & Phonetic Heuristics',
        'desc': 'Natural language classifiers flag homoglyph substitutions (e.g., Cyrillic characters disguised as Latin), typosquats, and brand spoofing.',
        'icon': Icons.spellcheck_rounded,
        'color': AppTheme.coralSunset,
      },
      {
        'num': '04',
        'title': 'Automated Abuse Desk Takedowns',
        'desc': 'Instant generation of cryptographically signed DMCA & WIPO legal notice packets dispatched directly to hosting providers and registrars.',
        'icon': Icons.gavel_rounded,
        'color': const Color(0xFF34D399),
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      constraints: const BoxConstraints(maxWidth: 1100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'THE RISKORA DEFENSE ARCHITECTURE',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.8,
              color: const Color(0xFF00E5FF),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Four Pillars of Autonomous Brand Defense',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 36),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 750;
              final colWidth = isNarrow ? constraints.maxWidth : (constraints.maxWidth - 20) / 2;

              return Wrap(
                spacing: 20,
                runSpacing: 20,
                children: pillars.map((p) {
                  final color = p['color'] as Color;
                  return Container(
                    width: colWidth,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF131726) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF232A40) : AppTheme.lightBorder,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(p['icon'] as IconData, color: color, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      p['title'] as String,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    p['num'] as String,
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: color,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                p['desc'] as String,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  height: 1.5,
                                  color: textMuted,
                                ),
                              ),
                            ],
                          ),
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

  // --- LEADERSHIP & THREAT INTEL TEAM ---
  Widget _buildLeadershipSection(BuildContext context, bool isDark, Color textColor, Color textMuted) {
    final team = [
      {
        'name': 'Kureti Titus Karthikeya',
        'role': 'Founder & Project Lead // Chief Cyber Defense Architect',
        'cred': 'Lead Architect of Riskora Autonomous Threat Matrix (kuretitituskathikeya@gmail.com)',
        'icon': Icons.stars_rounded,
        'color': const Color(0xFF00E5FF),
      },
      {
        'name': 'Dr. Aaron Sterling',
        'role': 'Chief AI Security Architect',
        'cred': 'Ex-DARPA Cyber, Stanford PhD',
        'icon': Icons.military_tech_rounded,
        'color': AppTheme.coralSunset,
      },
      {
        'name': 'Elena Rostova',
        'role': 'VP of Global Threat Intelligence',
        'cred': 'Former Interpol Cybercrime Directorate',
        'icon': Icons.security_rounded,
        'color': AppTheme.purpleGlow,
      },
      {
        'name': 'Vikramaditya Rao',
        'role': 'Head of Autonomous Crawlers',
        'cred': 'Ex-Google Brain Security & Distributed Systems',
        'icon': Icons.terminal_rounded,
        'color': AppTheme.coralSunset,
      },
      {
        'name': 'Claire Vance',
        'role': 'Chief Trust & Compliance Officer',
        'cred': 'CISA Fellow, Harvard Law IP Specialist',
        'icon': Icons.policy_rounded,
        'color': const Color(0xFF34D399),
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      constraints: const BoxConstraints(maxWidth: 1100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'THREAT INTELLIGENCE PIONEERS',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.8,
              color: const Color(0xFF00E5FF),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Built by Veteran Cyber Defense Engineers',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 36),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 750;
              final width = isNarrow ? constraints.maxWidth : (constraints.maxWidth - 48) / 4;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: team.map((member) {
                  final color = member['color'] as Color;
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
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: color.withOpacity(0.15),
                          child: Icon(member['icon'] as IconData, color: color, size: 30),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          member['name'] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          member['role'] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          member['cred'] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: textMuted,
                          ),
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

  // --- COMPLIANCE SECTION ---
  Widget _buildComplianceSection(BuildContext context, bool isDark, Color textColor, Color textMuted) {
    final badges = [
      {'name': 'ISO/IEC 27001', 'desc': 'Information Security Management'},
      {'name': 'SOC 2 Type II', 'desc': 'Enterprise Trust & Data Integrity'},
      {'name': 'GDPR & CCPA', 'desc': 'Cryptographic Privacy Compliance'},
      {'name': 'WIPO Partner', 'desc': 'World IP Organization Enforcement'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      constraints: const BoxConstraints(maxWidth: 1100),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131726) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3), width: 1.2),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.verified_outlined, color: Color(0xFF00E5FF), size: 20),
                const SizedBox(width: 8),
                Text(
                  'GLOBAL ACCREDITATIONS & SECURITY FRAMEWORKS',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                    color: const Color(0xFF00E5FF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 24,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: badges.map((b) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0B0F1C) : AppTheme.lightSurfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isDark ? const Color(0xFF1E283D) : AppTheme.lightBorder),
                  ),
                  child: Column(
                    children: [
                      Text(
                        b['name']!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        b['desc']!,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // --- CTA BANNER ---
  Widget _buildCtaBanner(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      constraints: const BoxConstraints(maxWidth: 1100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 36),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5D2EE6), Color(0xFF783291), Color(0xFFFF9B63)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppTheme.purpleElectric.withOpacity(0.35),
              blurRadius: 28,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ready to Shield Your Brand from Impersonation?',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Deploy Riskora autonomous crawlers across your social handles and registered apps in under 5 minutes.',
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withOpacity(0.9), height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ContactUsScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF5D2EE6),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: Text(
                'Schedule Briefing',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14),
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
