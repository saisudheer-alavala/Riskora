import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Red Points signature dynamic 360-degree Cyber Threat Radar Visualizer.
/// Features a continuously rotating radar beam, concentric perimeter rings,
/// pinging impersonation blips, and real-time telemetry metrics.
class CyberRadarWidget extends StatefulWidget {
  final VoidCallback? onScanTriggered;

  const CyberRadarWidget({super.key, this.onScanTriggered});

  @override
  State<CyberRadarWidget> createState() => _CyberRadarWidgetState();
}

class _CyberRadarWidgetState extends State<CyberRadarWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _radarController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? AppTheme.purpleElectric.withOpacity(0.6)
                : AppTheme.border,
            width: _isHovered ? 1.4 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.purpleGlow.withOpacity(_isHovered ? 0.22 : 0.08),
              blurRadius: _isHovered ? 26 : 14,
              offset: const Offset(0, 6),
            ),
            ...AppTheme.cardShadow,
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 720;
            if (isWide) {
              return Row(
                children: [
                  // Circular Radar Screen
                  SizedBox(
                    width: 220,
                    height: 220,
                    child: _buildRadarDisplay(),
                  ),
                  const SizedBox(width: 28),
                  // Telemetry Details & Action
                  Expanded(
                    child: _buildTelemetryDetails(),
                  ),
                ],
              );
            }

            return Column(
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: _buildRadarDisplay(),
                ),
                const SizedBox(height: 20),
                _buildTelemetryDetails(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRadarDisplay() {
    return AnimatedBuilder(
      animation: _radarController,
      builder: (context, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(220, 220),
              painter: _RadarScreenPainter(
                angle: _radarController.value * 2 * math.pi,
                glowProgress: _radarController.value,
              ),
            ),
            // Central Verified Shield Core
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.redPointsGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.purpleElectric.withOpacity(0.6),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.shield_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTelemetryDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.coralSunset,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.coralSunset.withOpacity(0.8),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '360° LIVE PERIMETER DEFENSE',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: AppTheme.coralSunset,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Text(
                'NEURAL ENGINE v4.2',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Continuous Brand Impersonation Radar',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Scanning social media graphs, third-party APK app stores, lookalike domains, and rogue web stores with sub-second neural similarity scoring.',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppTheme.textSecondary,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 16),
        // Metric Micro-badges
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _buildTelemetryPill(
              label: 'Detection Accuracy',
              value: '99.4%',
              color: AppTheme.purpleGlow,
            ),
            _buildTelemetryPill(
              label: 'Sweep Rate',
              value: '14.8k endpoints/sec',
              color: AppTheme.coralSunset,
            ),
            _buildTelemetryPill(
              label: 'Auto-Takedown SLA',
              value: '< 4 hours',
              color: AppTheme.magentaRoyal,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTelemetryPill({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
          ),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarScreenPainter extends CustomPainter {
  final double angle;
  final double glowProgress;

  _RadarScreenPainter({required this.angle, required this.glowProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = const Color(0xFF14131E)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Concentric grid rings
    final ringPaint = Paint()
      ..color = AppTheme.purpleElectric.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, radius * 0.35, ringPaint);
    canvas.drawCircle(center, radius * 0.65, ringPaint);
    canvas.drawCircle(center, radius * 0.95, ringPaint);

    // Crosshair axes
    final axisPaint = Paint()
      ..color = AppTheme.purpleElectric.withOpacity(0.12)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(center.dx - radius * 0.95, center.dy),
        Offset(center.dx + radius * 0.95, center.dy), axisPaint);
    canvas.drawLine(Offset(center.dx, center.dy - radius * 0.95),
        Offset(center.dx, center.dy + radius * 0.95), axisPaint);

    // Rotating Radar Sweep Cone
    final sweepRect = Rect.fromCircle(center: center, radius: radius * 0.95);
    final sweepGradient = SweepGradient(
      center: Alignment.center,
      startAngle: 0,
      endAngle: 0.8,
      colors: [
        AppTheme.purpleElectric.withOpacity(0.0),
        AppTheme.purpleElectric.withOpacity(0.28),
      ],
      transform: GradientRotation(angle - 0.8),
    );

    final sweepPaint = Paint()
      ..shader = sweepGradient.createShader(sweepRect)
      ..style = PaintingStyle.fill;

    canvas.drawArc(sweepRect, angle - 0.8, 0.8, true, sweepPaint);

    // Leading Sweep Laser Beam line
    final sweepLinePaint = Paint()
      ..color = AppTheme.coralSunset.withOpacity(0.7)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final sweepEndX = center.dx + radius * 0.95 * math.cos(angle);
    final sweepEndY = center.dy + radius * 0.95 * math.sin(angle);
    canvas.drawLine(center, Offset(sweepEndX, sweepEndY), sweepLinePaint);

    // Outer border rim
    final rimPaint = Paint()
      ..color = AppTheme.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, radius * 0.95, rimPaint);

    // Draw Simulated Threat Blip Nodes
    _drawBlip(canvas, center, radius * 0.52, 0.7, AppTheme.riskCritical, 'APK Cloned');
    _drawBlip(canvas, center, radius * 0.78, 2.3, AppTheme.riskHigh, 'Rogue IG');
    _drawBlip(canvas, center, radius * 0.40, 4.2, AppTheme.coralSunset, 'Lookalike');
    _drawBlip(canvas, center, radius * 0.85, 5.4, AppTheme.purpleGlow, 'Phish Domain');
  }

  void _drawBlip(
    Canvas canvas,
    Offset center,
    double distance,
    double blipAngle,
    Color color,
    String label,
  ) {
    final x = center.dx + distance * math.cos(blipAngle);
    final y = center.dy + distance * math.sin(blipAngle);
    final blipPos = Offset(x, y);

    // Compute angular distance from current sweep beam
    double diff = (angle - blipAngle) % (2 * math.pi);
    if (diff < 0) diff += 2 * math.pi;

    // If beam just passed over (within 0.8 rad), ping flare
    final isPinging = diff < 0.8;
    final pingIntensity = isPinging ? (1.0 - diff / 0.8) : 0.0;

    if (pingIntensity > 0) {
      final ringPaint = Paint()
        ..color = color.withOpacity(0.5 * pingIntensity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawCircle(blipPos, 4.0 + 8.0 * pingIntensity, ringPaint);
    }

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(blipPos, 3.2, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _RadarScreenPainter oldDelegate) => true;
}
