import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Clean, professional cybersecurity background for RISKORA.
/// Provides a normal, solid, high-contrast, distraction-free foundation
/// for both Dark (#0D0C15) & Light (#F4F6FB) themes.
class RedPointsBackground extends StatelessWidget {
  final Widget child;
  final bool showTopGradientBar;
  final bool showAmbientOrbs;
  final bool showGrid;
  final bool enableScanLine;
  final bool enableVideoBackground;

  const RedPointsBackground({
    super.key,
    required this.child,
    this.showTopGradientBar = true,
    this.showAmbientOrbs = false,
    this.showGrid = false,
    this.enableScanLine = false,
    this.enableVideoBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.background : AppTheme.lightBackground;

    return Container(
      color: bgColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Main Screen Content
          Positioned.fill(
            child: child,
          ),

          // Red Points Signature subtle top gradient accent strip
          if (showTopGradientBar)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 2.5,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.redPointsGradient,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
