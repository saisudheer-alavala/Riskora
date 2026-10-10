import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Red Points style animated rotating ticker banner with pulsing radar telemetry.
class CyberTickerBanner extends StatefulWidget {
  const CyberTickerBanner({super.key});

  @override
  State<CyberTickerBanner> createState() => _CyberTickerBannerState();
}

class _CyberTickerBannerState extends State<CyberTickerBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  Timer? _timer;
  int _currentIndex = 0;

  static const List<String> _threatTracks = [
    'Eliminate Counterfeit Profiles Across Social Networks',
    'Detect & De-index Rogue Android & iOS Cloned Apps',
    'Neutralize Fake Phishing Domains & Squatted URLs',
    'Autonomous 24/7 DMCA & Trademark Enforcement Engine',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _threatTracks.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.purpleGlow.withOpacity(0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.purpleElectric.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
          ...AppTheme.cardShadow,
        ],
      ),
      child: Row(
        children: [
          // Live Pulse Beacon Dot
          SizedBox(
            width: 22,
            height: 22,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, _) {
                    return Container(
                      width: 20 * _pulseController.value,
                      height: 20 * _pulseController.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.coralSunset.withOpacity(
                            (1.0 - _pulseController.value).clamp(0.0, 1.0),
                          ),
                          width: 1.5,
                        ),
                      ),
                    );
                  },
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.coralSunset,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Badge Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.purpleElectric.withOpacity(0.35),
                  AppTheme.magentaRoyal.withOpacity(0.35),
                ],
              ),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.purpleGlow.withOpacity(0.5), width: 0.8),
            ),
            child: Text(
              'LIVE MATRIX',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppTheme.coralSunset,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Animated Switcher Text
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 450),
              transitionBuilder: (child, animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.4),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: Text(
                _threatTracks[_currentIndex],
                key: ValueKey<int>(_currentIndex),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                  letterSpacing: 0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Red Points mini AI icon tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome_rounded, size: 12, color: AppTheme.purpleGlow),
                const SizedBox(width: 4),
                Text(
                  'Red Points AI Powered',
                  style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
