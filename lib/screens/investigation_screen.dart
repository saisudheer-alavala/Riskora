import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/threat_item.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/risk_badge.dart';
import '../widgets/animated_gradient_button.dart';

class ThreatInvestigationScreen extends StatefulWidget {
  const ThreatInvestigationScreen({super.key});

  @override
  State<ThreatInvestigationScreen> createState() => _ThreatInvestigationScreenState();
}

class _ThreatInvestigationScreenState extends State<ThreatInvestigationScreen> {
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _authorController = TextEditingController(text: 'Senior SecOps Analyst');

  @override
  void dispose() {
    _noteController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  void _showTakedownNoticeDialog(ThreatItem threat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Row(
          children: [
            const Icon(Icons.gavel_rounded, color: AppTheme.riskHigh, size: 20),
            const SizedBox(width: 8),
            Text('Digital Takedown Notice Package', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'A formalized DMCA / Trademark Infringement notice has been compiled for ${threat.platform} abuse desks:',
                style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.border),
                ),
                child: SelectableText(
                  'SUBJECT: Formal Trademark Infringement & Impersonation Takedown Request\n'
                  'TARGET IDENTIFIER: ${threat.identifier}\n'
                  'URL: ${threat.url}\n'
                  'PLATFORM: ${threat.platform}\n'
                  'INFRINGED ENTITY: Riskora Technologies Inc. (Reg #8921820)\n'
                  'EVIDENCE SUMMARY:\n'
                  '• Logo Visual Similarity: ${threat.logoSimilarity.toStringAsFixed(1)}%\n'
                  '• Name Squatting Score: ${threat.nameSimilarity.toStringAsFixed(1)}%\n'
                  '• Flagged Signals: ${threat.detectionReasons.join("; ")}\n\n'
                  'Requested Action: Immediate suspension and removal pursuant to 17 U.S.C. 512(c).',
                  style: GoogleFonts.jetBrainsMono(fontSize: 11, color: AppTheme.textPrimary, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AppStateProvider>().updateThreatStatus(threat.id, ReviewStatus.takedownRequested);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Takedown packet dispatched to platform abuse desk! Status updated.'),
                  backgroundColor: AppTheme.surfaceHigh,
                ),
              );
            },
            icon: const Icon(Icons.send_rounded, size: 16),
            label: const Text('Dispatch Takedown Notice'),
          ),
        ],
      ),
    );
  }

  void _addNote(ThreatItem threat) {
    final text = _noteController.text.trim();
    final author = _authorController.text.trim();
    if (text.isNotEmpty) {
      context.read<AppStateProvider>().addInvestigationNote(
            threat.id,
            text,
            author: author.isEmpty ? 'SecOps Analyst' : author,
          );
      _noteController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Analyst forensic note added to threat timeline.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final threats = provider.threats;
    final threat = provider.selectedThreat ?? (threats.isNotEmpty ? threats.first : null);

    if (threat == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.biotech_rounded, size: 48, color: AppTheme.primaryTeal),
              const SizedBox(height: 12),
              Text('No Threat Selected for Investigation', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700)),
              Text('Select a threat from Social Monitoring or App Monitoring to inspect evidence.', style: GoogleFonts.inter(color: AppTheme.textMuted)),
            ],
          ),
        ),
      );
    }

    final dateFormat = DateFormat('MMM dd, yyyy • HH:mm:ss');

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Threat Selector Switcher
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 680;
                final titleCol = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Threat Forensics & Investigation',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Deep forensic analysis, neural evidence score decomposition, and takedown orchestration workbench.',
                      style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );

                // Deduplicate threats by ID to prevent duplicate DropdownMenuItem assertions
                final uniqueThreatMap = <String, ThreatItem>{};
                for (final t in threats) {
                  uniqueThreatMap[t.id] = t;
                }
                final uniqueThreats = uniqueThreatMap.values.toList();

                final currentSelectedId = uniqueThreatMap.containsKey(threat.id)
                    ? threat.id
                    : (uniqueThreats.isNotEmpty ? uniqueThreats.first.id : null);

                final threatDropdown = Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: currentSelectedId,
                      isExpanded: isNarrow,
                      dropdownColor: AppTheme.surfaceElevated,
                      style: GoogleFonts.jetBrainsMono(color: AppTheme.textPrimary, fontSize: 12),
                      icon: const Icon(Icons.arrow_drop_down_rounded, color: AppTheme.primaryTeal),
                      items: uniqueThreats.map((t) {
                        return DropdownMenuItem<String>(
                          value: t.id,
                          child: Text(
                            '${t.id} - ${t.identifier} (${t.riskScore})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (id) {
                        if (id != null && uniqueThreatMap.containsKey(id)) {
                          provider.selectThreatForInvestigation(uniqueThreatMap[id]!);
                        }
                      },
                    ),
                  ),
                );

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleCol,
                      const SizedBox(height: 14),
                      threatDropdown,
                    ],
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: titleCol),
                    const SizedBox(width: 16),
                    threatDropdown,
                  ],
                );
              },
            ),

            const SizedBox(height: 22),

            // Threat Meta Header Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: threat.riskScore >= 80 ? AppTheme.riskCritical.withOpacity(0.4) : AppTheme.border,
                  width: 1.2,
                ),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 620;

                      final iconBox = Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceElevated,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Icon(
                          threat.type == ThreatType.socialMedia
                              ? Icons.alternate_email_rounded
                              : Icons.apps_rounded,
                          color: AppTheme.primaryTeal,
                          size: 26,
                        ),
                      );

                      final metaTags = Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            threat.id,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          StatusBadge(status: threat.reviewStatus),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceElevated,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              threat.platform,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryTeal,
                              ),
                            ),
                          ),
                        ],
                      );

                      final textDetails = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          metaTags,
                          const SizedBox(height: 6),
                          Text(
                            threat.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          SelectableText(
                            threat.identifier,
                            style: GoogleFonts.jetBrainsMono(fontSize: 13, color: AppTheme.primaryTeal),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'First detected: ${dateFormat.format(threat.detectedAt)} • Publisher: ${threat.developerOrAuthor}',
                            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted),
                          ),
                        ],
                      );

                      final riskBadge = RiskBadge(score: threat.riskScore);

                      if (isNarrow) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                iconBox,
                                riskBadge,
                              ],
                            ),
                            const SizedBox(height: 14),
                            textDetails,
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          iconBox,
                          const SizedBox(width: 16),
                          Expanded(child: textDetails),
                          const SizedBox(width: 16),
                          riskBadge,
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 18),
                  Divider(color: AppTheme.borderSubtle, height: 1),
                  const SizedBox(height: 18),

                  // Interactive Triage Action Buttons
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          provider.updateThreatStatus(threat.id, ReviewStatus.confirmedThreat);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Marked as Confirmed Threat.')),
                          );
                        },
                        icon: const Icon(Icons.warning_amber_rounded, size: 16),
                        label: const Text('Mark Confirmed Threat'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.riskCritical,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          provider.updateThreatStatus(threat.id, ReviewStatus.falsePositive);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Marked as False Positive. Crawler weights adjusted.')),
                          );
                        },
                        icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                        label: const Text('Mark False Positive'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.purpleGlow,
                          side: const BorderSide(color: AppTheme.purpleGlow),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          provider.updateThreatStatus(threat.id, ReviewStatus.inReview);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Kept Under Review.')),
                          );
                        },
                        icon: const Icon(Icons.access_time_rounded, size: 16),
                        label: const Text('Keep Under Review'),
                      ),
                      AnimatedGradientButton(
                        onPressed: () => _showTakedownNoticeDialog(threat),
                        icon: Icons.gavel_rounded,
                        text: 'Initiate Takedown Notice',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Two-column layout: Left (Risk Breakdown & Indicators), Right (Side-by-side Asset Comparison & Notes)
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 900;
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            _buildRiskBreakdownCard(threat),
                            const SizedBox(height: 18),
                            _buildThreatIndicatorsCard(threat),
                          ],
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        flex: 6,
                        child: Column(
                          children: [
                            _buildEvidenceComparisonCard(threat, provider),
                            const SizedBox(height: 18),
                            _buildInvestigationNotesCard(threat),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    _buildRiskBreakdownCard(threat),
                    const SizedBox(height: 18),
                    _buildEvidenceComparisonCard(threat, provider),
                    const SizedBox(height: 18),
                    _buildThreatIndicatorsCard(threat),
                    const SizedBox(height: 18),
                    _buildInvestigationNotesCard(threat),
                  ],
                );
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskBreakdownCard(ThreatItem threat) {
    final b = threat.breakdown;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Risk Score Decomposition',
                  style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Composite: ${threat.riskScore}/100',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: threat.riskScore >= 80 ? AppTheme.riskCritical : AppTheme.primaryTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildScoreBar('Name Similarity (Weight: 25%)', b.nameSimilarityScore, AppTheme.purpleGlow),
          const SizedBox(height: 12),
          _buildScoreBar('Logo Visual Similarity (Weight: 30%)', b.logoVisualMatchScore, AppTheme.coralSunset),
          const SizedBox(height: 12),
          _buildScoreBar('Malicious Pattern Matching (Weight: 20%)', b.suspiciousKeywordsScore, AppTheme.riskHigh),
          const SizedBox(height: 12),
          _buildScoreBar('Account / Domain Age Disparity (Weight: 15%)', b.domainOrAccountAgeScore, AppTheme.riskMedium),
          const SizedBox(height: 12),
          _buildScoreBar('Permission & Malware Vector (Weight: 10%)', b.permissionMalwareScore, AppTheme.riskCritical),
        ],
      ),
    );
  }

  Widget _buildScoreBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text('${value.toStringAsFixed(1)}%', style: GoogleFonts.jetBrainsMono(fontSize: 11, color: AppTheme.textPrimary)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: value / 100,
          backgroundColor: AppTheme.surfaceElevated,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 6,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildThreatIndicatorsCard(ThreatItem threat) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Flagged Threat Indicators',
            style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...threat.detectionReasons.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.arrow_right_rounded, size: 18, color: AppTheme.riskHigh),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(r, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textPrimary)),
                    ),
                  ],
                ),
              )),
          if (threat.indicators.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: threat.indicators.map((ind) {
                return Chip(
                  label: Text(ind),
                  backgroundColor: AppTheme.surfaceElevated,
                  labelStyle: GoogleFonts.jetBrainsMono(fontSize: 10, color: AppTheme.primaryTeal),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: BorderSide(color: AppTheme.border),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEvidenceComparisonCard(ThreatItem threat, AppStateProvider provider) {
    final brand = provider.brandProfile;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Asset Comparison: Monitored vs Impersonator',
            style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 540;

              final officialCard = Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.purpleGlow.withOpacity(0.35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.verified_rounded, size: 14, color: AppTheme.purpleGlow),
                        SizedBox(width: 6),
                        Text('Official Brand Asset', style: TextStyle(color: AppTheme.purpleGlow, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      brand.companyName,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      brand.officialWebsite,
                      style: GoogleFonts.jetBrainsMono(color: AppTheme.textMuted, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );

              final rogueCard = Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.riskCritical.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.warning_amber_rounded, size: 14, color: AppTheme.riskCritical),
                        SizedBox(width: 6),
                        Text('Detected Rogue Asset', style: TextStyle(color: AppTheme.riskCritical, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      threat.title,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      threat.identifier,
                      style: GoogleFonts.jetBrainsMono(color: AppTheme.riskHigh, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );

              if (isNarrow) {
                return Column(
                  children: [
                    officialCard,
                    const SizedBox(height: 12),
                    rogueCard,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: officialCard),
                  const SizedBox(width: 12),
                  Expanded(child: rogueCard),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInvestigationNotesCard(ThreatItem threat) {
    final dateFormat = DateFormat('MMM dd, HH:mm');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Analyst Forensic Notes',
                style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('${threat.notes.length} Entries', style: GoogleFonts.jetBrainsMono(fontSize: 11, color: AppTheme.primaryTeal)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Add note field
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 480;
              final textField = TextField(
                controller: _noteController,
                style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Add an investigation observation, registrar IP, or action note...',
                ),
                onSubmitted: (_) => _addNote(threat),
              );

              final addBtn = ElevatedButton.icon(
                onPressed: () => _addNote(threat),
                icon: const Icon(Icons.add_comment_rounded, size: 16),
                label: const Text('Add Note'),
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    textField,
                    const SizedBox(height: 10),
                    addBtn,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: textField),
                  const SizedBox(width: 10),
                  addBtn,
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          if (threat.notes.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              alignment: Alignment.center,
              child: Text('No investigation notes recorded yet.', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: threat.notes.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final note = threat.notes[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            note.author,
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryTeal),
                          ),
                          Text(
                            dateFormat.format(note.createdAt),
                            style: GoogleFonts.jetBrainsMono(fontSize: 10, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        note.text,
                        style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary, height: 1.3),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
