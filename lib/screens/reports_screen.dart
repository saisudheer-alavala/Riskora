import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/report_data.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/charts/risk_distribution_chart.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedRange = 'Last 30 Days';

  void _showPdfPreviewDialog(ReportSummary report) {
    final dateFormat = DateFormat('MMMM dd, yyyy');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Row(
          children: [
            const Icon(Icons.picture_as_pdf_rounded, color: AppTheme.riskHigh, size: 22),
            const SizedBox(width: 10),
            Text('RISKORA Executive Threat Brief', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('DIGITAL RISK INTELLIGENCE REPORT', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
                          Text(dateFormat.format(report.generatedAt), style: GoogleFonts.jetBrainsMono(fontSize: 10, color: AppTheme.textMuted)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('Target Organization: Riskora Technologies Inc.', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold)),
                      Text('Reporting Window: ${report.dateRange}', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text('Key Metric Highlights:', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                _buildReportRow('Total Automated Crawls', '${report.totalScansRun}'),
                _buildReportRow('Anomalous Impersonators Detected', '${report.totalDetections}'),
                _buildReportRow('Confirmed Active Threats', '${report.confirmedThreats}'),
                _buildReportRow('False Positives Cleared', '${report.falsePositives}'),
                _buildReportRow('Takedown Notices Dispatched', '${report.takedownsInitiated}'),
                _buildReportRow('Model Detection Accuracy', '${report.averageDetectionAccuracy}%'),
                const SizedBox(height: 16),
                Text('Executive Incident Summary:', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                ...report.executiveHighlights.map((h) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_outline_rounded, size: 14, color: AppTheme.coralSunset),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(h, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Executive PDF downloaded to local storage.'),
                  backgroundColor: AppTheme.surfaceHigh,
                ),
              );
            },
            icon: const Icon(Icons.download_rounded, size: 16),
            label: const Text('Download PDF'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
          Text(value, style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryTeal)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final report = provider.reportSummary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Security Intelligence Reports',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Comprehensive digital perimeter analytics, false positive audits, and executive briefings.',
                        style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 10,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Exported detection forensics as telemetry.csv')),
                        );
                      },
                      icon: const Icon(Icons.table_chart_rounded, size: 16),
                      label: const Text('Export CSV'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showPdfPreviewDialog(report),
                      icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                      label: const Text('Generate PDF Brief'),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 22),

            // Date Range Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.date_range_rounded, size: 18, color: AppTheme.primaryTeal),
                  const SizedBox(width: 10),
                  Text('Audit Period:', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
                  const SizedBox(width: 10),
                  ...['Last 7 Days', 'Last 30 Days', 'Last 90 Days', 'All Time'].map((range) {
                    final isSel = _selectedRange == range;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(range),
                        selected: isSel,
                        onSelected: (_) => setState(() => _selectedRange = range),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Metric Cards Grid
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    'Confirmed Threats',
                    '${report.confirmedThreats}',
                    'Active malicious clones',
                    AppTheme.riskCritical,
                    Icons.security_update_warning_rounded,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildMetricTile(
                    'False Positives',
                    '${report.falsePositives}',
                    'Flagged benign entities',
                    AppTheme.purpleGlow,
                    Icons.check_circle_outline_rounded,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildMetricTile(
                    'Takedowns Filed',
                    '${report.takedownsInitiated}',
                    'Registrar & store notices',
                    AppTheme.riskHigh,
                    Icons.gavel_rounded,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildMetricTile(
                    'Model Accuracy',
                    '${report.averageDetectionAccuracy}%',
                    'Verified precision index',
                    AppTheme.primaryTeal,
                    Icons.insights_rounded,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Distribution Breakdown & Threat Ratio
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 900;
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6,
                        child: RiskDistributionChart(distribution: report.riskDistribution),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        flex: 5,
                        child: _buildThreatRatioCard(report),
                      ),
                    ],
                  );
                }
                return Column(
                  children: [
                    RiskDistributionChart(distribution: report.riskDistribution),
                    const SizedBox(height: 18),
                    _buildThreatRatioCard(report),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Executive Highlights Section
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shield_outlined, color: AppTheme.purpleGlow, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        'Autonomous Threat Analysis & Executive Highlights',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...report.executiveHighlights.map((hl) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.borderSubtle),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.arrow_right_rounded, size: 20, color: AppTheme.coralSunset),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              hl,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppTheme.textPrimary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String title, String value, String sub, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
              ),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(sub, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildThreatRatioCard(ReportSummary report) {
    final total = report.confirmedThreats + report.falsePositives;
    final threatPct = total > 0 ? (report.confirmedThreats / total * 100).toStringAsFixed(1) : '0';
    final fpPct = total > 0 ? (report.falsePositives / total * 100).toStringAsFixed(1) : '0';

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
            'Threat Validation Ratio',
            style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Ratio of verified brand attackers versus student/benign occurrences',
            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 20),
          // Stacked Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 16,
              child: Row(
                children: [
                  Expanded(
                    flex: report.confirmedThreats,
                    child: Container(color: AppTheme.riskCritical),
                  ),
                  Expanded(
                    flex: report.falsePositives,
                    child: Container(color: AppTheme.purpleGlow),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppTheme.riskCritical, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text('Confirmed Threats ($threatPct%)', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
              Row(
                children: [
                  Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppTheme.purpleGlow, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text('False Positives ($fpPct%)', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, size: 16, color: AppTheme.coralSunset),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'High threat ratio indicates accurate neural targeting with minimal alert fatigue.',
                    style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
