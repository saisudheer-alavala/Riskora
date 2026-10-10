import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'video_background/video_bg.dart';

/// Fullscreen Intro Splash Screen that plays the branded animated video
/// at the very beginning (starting ala vachi), and once finished or skipped,
/// smoothly fades out so the landing page opens completely normal.
class IntroVideoSplashScreen extends StatefulWidget {
  final Widget nextScreen;
  final Duration duration;

  const IntroVideoSplashScreen({
    super.key,
    required this.nextScreen,
    this.duration = const Duration(milliseconds: 3800),
  });

  @override
  State<IntroVideoSplashScreen> createState() => _IntroVideoSplashScreenState();
}

class _IntroVideoSplashScreenState extends State<IntroVideoSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _curtainAnimation;
  Timer? _timer;
  bool _isTransitioning = false;
  bool _introFinished = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _curtainAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _timer = Timer(widget.duration, _finishIntro);
  }

  void _finishIntro() {
    if (_isTransitioning || !mounted) return;
    _isTransitioning = true;
    _timer?.cancel();
    _fadeController.forward().then((_) {
      if (mounted) {
        setState(() {
          _introFinished = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_introFinished) {
      return widget.nextScreen;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0C15),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Branded Full-Screen Animated Video (Never inside FadeTransition)
          const Positioned.fill(
            child: VideoBackgroundWidget(tag: 'intro'),
          ),

                // Top Vignette
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 120,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.85),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom Vignette
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 160,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.90),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Top-Right Skip Intro Button
                Positioned(
                  top: 28,
                  right: 28,
                  child: TextButton.icon(
                    onPressed: _finishIntro,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.12),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: BorderSide(color: Colors.white.withOpacity(0.25)),
                      ),
                    ),
                    icon: const Text(
                      'Skip Intro',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    label: const Icon(Icons.arrow_forward_rounded, size: 16),
                  ),
                ),

                // Center Branding Shield
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00E5FF).withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/images/riskora_emblem.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'RISKORA',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.0,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'DIGITAL RISK PROTECTION PLATFORM',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: const Color(0xFF00E5FF),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom Telemetry Loading Indicator
                Positioned(
                  bottom: 36,
                  left: 36,
                  right: 36,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.coralSunset,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'INITIALIZING RISKORA DEFENSE MATRIX...',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.1,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'SEC-OPS AI // v2.4',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: const LinearProgressIndicator(
                          minHeight: 3,
                          backgroundColor: Colors.white24,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.purpleElectric),
                        ),
                      ),
                    ],
                  ),
                ),

                // Smooth curtain transition when exiting intro
                if (_isTransitioning)
                  Positioned.fill(
                    child: FadeTransition(
                      opacity: _curtainAnimation,
                      child: Container(color: const Color(0xFF0D0C15)),
                    ),
                  ),
              ],
            ),
          );
  }
}
