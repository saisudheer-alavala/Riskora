import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

Widget createWebVideoBackground({String tag = 'default'}) {
  return const _ProceduralCyberMotionBackground();
}

class _ProceduralCyberMotionBackground extends StatefulWidget {
  const _ProceduralCyberMotionBackground();

  @override
  State<_ProceduralCyberMotionBackground> createState() => _ProceduralCyberMotionBackgroundState();
}

class _ProceduralCyberMotionBackgroundState extends State<_ProceduralCyberMotionBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _CyberGridPainter(progress: _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _CyberGridPainter extends CustomPainter {
  final double progress;
  _CyberGridPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFF0A0912);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final linePaint = Paint()
      ..color = AppTheme.purpleElectric.withOpacity(0.08)
      ..strokeWidth = 1.0;

    const spacing = 48.0;
    final yOffset = (progress * spacing) % spacing;

    for (double y = yOffset; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }

    // Glowing beam
    final beamPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          AppTheme.coralSunset.withOpacity(0.18),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, (progress * size.height) % size.height, size.width, 100));
    canvas.drawRect(
      Rect.fromLTWH(0, (progress * size.height) % size.height, size.width, 100),
      beamPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CyberGridPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
