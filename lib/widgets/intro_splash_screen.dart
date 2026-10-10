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
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _logoAnimController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  Timer? _timer;
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _logoAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    _logoScale = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(parent: _logoAnimController, curve: Curves.easeOutCubic),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoAnimController, curve: Curves.easeIn),
    );

    _timer = Timer(widget.duration, _finishIntro);
  }

  void _finishIntro() {
    if (_isTransitioning || !mounted) return;
    _isTransitioning = true;
    _timer?.cancel();
    _fadeController.forward().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    _logoAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_fadeController.isCompleted) {
      return widget.nextScreen;
    }

    return Stack(
      children: [
        // The normal next screen rendered underneath
        widget.nextScreen,

        // The Intro Video Splash Overlay (Starting ala vachi, fade out aipoyi vellipotundi)
        FadeTransition(
          opacity: _fadeAnimation,
          child: Scaffold(
            backgroundColor: const Color(0xFF0D0C15),
            body: Stack(
              fit: StackFit.expand,
              children: [
                // Branded Full-Screen Animated Video
                const Positioned.fill(
                  child: VideoBackgroundWidget(),
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

                // Center Official Brand Identity (Seamlessly floating with ambient cyber glow)
                Center(
                  child: AnimatedBuilder(
                    animation: _logoAnimController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00E5FF).withOpacity(0.28),
                                  blurRadius: 75,
                                  spreadRadius: 25,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/riskora_logo_transparent.png',
                              width: 330,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    },
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
                          Row(
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
                              Text(
                                'INITIALIZING RISKORA DEFENSE MATRIX...',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.1,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'SEC-OPS AI // v2.4',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}
