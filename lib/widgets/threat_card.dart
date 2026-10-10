import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/threat_item.dart';
import '../theme/app_theme.dart';
import 'risk_badge.dart';

/// Threat Intelligence Card with interactive animated hover effects,
/// dynamic risk badges, and Red Points cyber aesthetics.
class ThreatCard extends StatefulWidget {
  final ThreatItem threat;
  final VoidCallback onInvestigate;
  final VoidCallback? onQuickTriage;

  const ThreatCard({
    super.key,
    required this.threat,
    required this.onInvestigate,
    this.onQuickTriage,
  });

  @override
  State<ThreatCard> createState() => _ThreatCardState();
}

class _ThreatCardState extends State<ThreatCard> {
  bool _isHovered = false;

  IconData get _platformIcon {
    final p = widget.threat.platform.toLowerCase();
    if (p.contains('twitter') || p.contains('x')) return Icons.alternate_email_rounded;
    if (p.contains('play') || p.contains('android')) return Icons.android_rounded;
    if (p.contains('apple') || p.contains('ios')) return Icons.apple_rounded;
    if (p.contains('telegram')) return Icons.send_rounded;
    if (p.contains('instagram')) return Icons.camera_alt_rounded;
    if (p.contains('linkedin')) return Icons.business_center_rounded;
    return Icons.public_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, HH:mm');
    final isCritical = widget.threat.riskScore >= 80;
    final primaryAccent = isCritical ? AppTheme.riskCritical : AppTheme.purpleGlow;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -3 : 0, 0),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isHovered
                ? primaryAccent.withOpacity(0.65)
                : (isCritical
                    ? AppTheme.riskCritical.withOpacity(0.35)
                    : AppTheme.border),
            width: _isHovered ? 1.3 : (isCritical ? 1.2 : 1.0),
          ),
          boxShadow: [
            BoxShadow(
              color: primaryAccent.withOpacity(_isHovered ? 0.22 : (isCritical ? 0.08 : 0.03)),
              blurRadius: _isHovered ? 22 : 12,
              offset: Offset(0, _isHovered ? 6 : 4),
            ),
            ...AppTheme.cardShadow,
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Platform, Identifier, and Risk Badges
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Platform Icon Avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _isHovered
                            ? primaryAccent.withOpacity(0.4)
                            : AppTheme.border,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(_platformIcon, color: primaryAccent, size: 22),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Title and Identifier
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceElevated,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppTheme.borderSubtle),
                              ),
                              child: Text(
                                widget.threat.platform,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.coralSunset,
                                ),
                              ),
                            ),
                            StatusBadge(status: widget.threat.reviewStatus),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.threat.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.threat.identifier,
                          style: AppTheme.monoStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Risk Score Badge
                  RiskBadge(
                    score: widget.threat.riskScore,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Metrics Row: Match Scores & Timeline
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 360) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMetricTile(
                            'Name Similarity',
                            '${widget.threat.nameSimilarity.toStringAsFixed(1)}%',
                            widget.threat.nameSimilarity >= 85
                                ? AppTheme.riskCritical
                                : AppTheme.purpleGlow,
                            Icons.spellcheck_rounded,
                          ),
                          const SizedBox(height: 6),
                          _buildMetricTile(
                            'Logo Similarity',
                            '${widget.threat.logoSimilarity.toStringAsFixed(1)}%',
                            widget.threat.logoSimilarity >= 80
                                ? AppTheme.riskCritical
                                : AppTheme.coralSunset,
                            Icons.image_search_rounded,
                          ),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(
                          child: _buildMetricTile(
                            'Name Match',
                            '${widget.threat.nameSimilarity.toStringAsFixed(1)}%',
                            widget.threat.nameSimilarity >= 85
                                ? AppTheme.riskCritical
                                : AppTheme.purpleGlow,
                            Icons.spellcheck_rounded,
                          ),
                        ),
                        Container(width: 1, height: 26, color: AppTheme.border),
                        Expanded(
                          child: _buildMetricTile(
                            'Logo Match',
                            '${widget.threat.logoSimilarity.toStringAsFixed(1)}%',
                            widget.threat.logoSimilarity >= 80
                                ? AppTheme.riskCritical
                                : AppTheme.coralSunset,
                            Icons.image_search_rounded,
                          ),
                        ),
                        Container(width: 1, height: 26, color: AppTheme.border),
                        Expanded(
                          child: _buildMetricTile(
                            'Detected',
                            dateFormat.format(widget.threat.detectedAt),
                            AppTheme.textSecondary,
                            Icons.access_time_rounded,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Detection Reasons Chips
              if (widget.threat.detectionReasons.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: widget.threat.detectionReasons.take(2).map((reason) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.coralSunset.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppTheme.coralSunset.withOpacity(0.25),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.warning_amber_rounded, size: 12, color: AppTheme.coralSunset),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              reason,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppTheme.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 14),

              // Actions row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.threat.developerOrAuthor,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: widget.onInvestigate,
                    icon: const Icon(Icons.biotech_rounded, size: 16),
                    label: const Text('Investigate Threat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.purpleGlow,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
