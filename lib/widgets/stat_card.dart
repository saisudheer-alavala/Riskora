import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Interactive telemetry card with animated hover lift and glowing border accents.
class StatCard extends StatefulWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final String? trend;
  final bool isTrendPositive;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.accentColor = AppTheme.purpleGlow,
    this.trend,
    this.isTrendPositive = true,
    this.onTap,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -3 : 0, 0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isHovered
                      ? widget.accentColor.withOpacity(0.7)
                      : widget.accentColor.withOpacity(0.3),
                  width: _isHovered ? 1.4 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.accentColor.withOpacity(_isHovered ? 0.28 : 0.06),
                    blurRadius: _isHovered ? 24 : 14,
                    offset: Offset(0, _isHovered ? 8 : 4),
                  ),
                  ...AppTheme.cardShadow,
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.title.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: widget.accentColor.withOpacity(_isHovered ? 0.24 : 0.14),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: widget.accentColor.withOpacity(_isHovered ? 0.5 : 0.25),
                            width: 0.8,
                          ),
                        ),
                        child: Icon(
                          widget.icon,
                          size: 18,
                          color: widget.accentColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildAnimatedValue(widget.value),
                  const SizedBox(height: 6),
                  Text.rich(
                    TextSpan(
                      children: [
                        if (widget.trend != null) ...[
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Icon(
                              widget.isTrendPositive
                                  ? Icons.trending_up_rounded
                                  : Icons.trending_down_rounded,
                              size: 14,
                              color: widget.isTrendPositive
                                  ? AppTheme.coralSunset
                                  : AppTheme.purpleGlow,
                            ),
                          ),
                          const WidgetSpan(child: SizedBox(width: 3)),
                          TextSpan(
                            text: '${widget.trend}  ',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: widget.isTrendPositive
                                  ? AppTheme.coralSunset
                                  : AppTheme.purpleGlow,
                            ),
                          ),
                        ],
                        TextSpan(
                          text: widget.subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedValue(String rawValue) {
    final numValue = double.tryParse(rawValue.replaceAll(RegExp(r'[^0-9.]'), ''));
    if (numValue == null) {
      return Text(
        rawValue,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: AppTheme.textPrimary,
          letterSpacing: -0.5,
        ),
      );
    }

    final isInt = !rawValue.contains('.');
    return TweenAnimationBuilder<double>(
      key: ValueKey(rawValue),
      tween: Tween<double>(begin: 0, end: numValue),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, val, _) {
        final text = isInt ? val.toInt().toString() : val.toStringAsFixed(1);
        return Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
            letterSpacing: -0.5,
          ),
        );
      },
    );
  }
}
