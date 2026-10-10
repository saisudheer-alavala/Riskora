import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/threat_item.dart';

class RiskBadge extends StatelessWidget {
  final int score;
  final bool showScoreNumber;
  final bool compact;

  const RiskBadge({
    super.key,
    required this.score,
    this.showScoreNumber = true,
    this.compact = false,
  });

  Color get badgeColor {
    if (score >= 80) return AppTheme.riskCritical;
    if (score >= 60) return AppTheme.riskHigh;
    if (score >= 40) return AppTheme.riskMedium;
    return AppTheme.riskLow;
  }

  String get label {
    if (score >= 80) return 'CRITICAL';
    if (score >= 60) return 'HIGH';
    if (score >= 40) return 'MEDIUM';
    return 'LOW';
  }

  @override
  Widget build(BuildContext context) {
    final color = badgeColor;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.55), width: 1),
        boxShadow: score >= 80
            ? [
                BoxShadow(
                  color: color.withOpacity(0.25),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.8),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            showScoreNumber ? '$label ($score)' : label,
            style: GoogleFonts.jetBrainsMono(
              color: color,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final ReviewStatus status;

  const StatusBadge({super.key, required this.status});

  Color get statusColor {
    switch (status) {
      case ReviewStatus.newDetected:
        return AppTheme.riskInfo;
      case ReviewStatus.inReview:
        return AppTheme.riskMedium;
      case ReviewStatus.confirmedThreat:
        return AppTheme.riskCritical;
      case ReviewStatus.falsePositive:
        return AppTheme.textMuted;
      case ReviewStatus.takedownRequested:
        return AppTheme.riskHigh;
      case ReviewStatus.resolved:
        return AppTheme.purpleGlow;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case ReviewStatus.newDetected:
        return Icons.radar;
      case ReviewStatus.inReview:
        return Icons.search_rounded;
      case ReviewStatus.confirmedThreat:
        return Icons.warning_amber_rounded;
      case ReviewStatus.falsePositive:
        return Icons.check_circle_outline_rounded;
      case ReviewStatus.takedownRequested:
        return Icons.gavel_rounded;
      case ReviewStatus.resolved:
        return Icons.verified_user_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = statusColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: GoogleFonts.inter(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
