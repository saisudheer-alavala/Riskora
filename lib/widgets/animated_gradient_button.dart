import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Red Points signature animated gradient button with smooth flowing gradient shifts.
/// Recreates the `@keyframes glow-gradient` from https://www.redpoints.com/
class AnimatedGradientButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;
  final EdgeInsetsGeometry padding;

  const AnimatedGradientButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 42,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  });

  @override
  State<AnimatedGradientButton> createState() => _AnimatedGradientButtonState();
}

class _AnimatedGradientButtonState extends State<AnimatedGradientButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onPressed != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // Continuous animated shift for gradient stops/angles
          final double t = _controller.value * 2 * math.pi;
          final double alignX = math.cos(t);
          final double alignY = math.sin(t);

          return AnimatedScale(
            scale: _isHovered && widget.onPressed != null ? 1.03 : 1.0,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: const [
                    AppTheme.purpleElectric,
                    AppTheme.magentaRoyal,
                    AppTheme.coralSunset,
                    AppTheme.purpleGlow,
                    AppTheme.purpleElectric,
                  ],
                  begin: Alignment(-1.0 + alignX * 0.4, -1.0 + alignY * 0.4),
                  end: Alignment(1.0 - alignX * 0.4, 1.0 - alignY * 0.4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.purpleElectric.withOpacity(_isHovered ? 0.45 : 0.25),
                    blurRadius: _isHovered ? 20 : 12,
                    offset: const Offset(0, 4),
                    spreadRadius: _isHovered ? 1 : 0,
                  ),
                  BoxShadow(
                    color: AppTheme.coralSunset.withOpacity(_isHovered ? 0.3 : 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.isLoading ? null : widget.onPressed,
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: widget.padding,
                    child: Center(
                      child: widget.isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (widget.icon != null) ...[
                                  Icon(widget.icon, size: 16, color: Colors.white),
                                  const SizedBox(width: 8),
                                ],
                                Text(
                                  widget.text,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
