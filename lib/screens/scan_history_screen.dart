import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/scan_record.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  String _selectedStatus = 'All';
  String _selectedSource = 'All';

  void _triggerScanDialog(AppStateProvider provider) {
    String chosenSource = 'All Sources';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            backgroundColor: AppTheme.surface,
            title: Row(
              children: [
                const Icon(Icons.radar_rounded, color: AppTheme.primaryTeal, size: 22),
                const SizedBox(width: 10),
                Text('Launch Multi-Channel Crawl', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select the perimeter target for real-time asset discovery and typo-squatting inspection:',
                  style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: chosenSource,
                  dropdownColor: AppTheme.surfaceElevated,
                  decoration: const InputDecoration(labelText: 'Target Scanning Channel'),
                  items: const [
                    DropdownMenuItem(value: 'All Sources', child: Text('All Sources (Complete Perimeter)')),
                    DropdownMenuItem(value: 'Social Media Channels', child: Text('Social Media Channels (X, IG, TG, LI)')),
                    DropdownMenuItem(value: 'Google Play & App Stores', child: Text('App Stores (Google Play, iOS, APKs)')),
                    DropdownMenuItem(value: 'Domain Registries & DNS', child: Text('Domain Registries & DNS Lookups')),
                    DropdownMenuItem(value: 'Dark Web Threat Feeds', child: Text('Dark Web & Paste Sites')),
                  ],
                  onChanged: (val) {
                    if (val != null) setModalState(() => chosenSource = val);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  provider.triggerNewScan(sourceType: chosenSource);
                },
                icon: const Icon(Icons.play_arrow_rounded, size: 16),
                label: const Text('Start Scan Now'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final scans = provider.scanRecords;

    final totalCandidates = scans.fold<int>(0, (sum, s) => sum + s.candidatesChecked);
    final totalDetections = scans.fold<int>(0, (sum, s) => sum + s.detectionsCount);
    final dateFormat = DateFormat('MMM dd, yyyy • HH:mm:ss');

    var filtered = scans.where((s) {
      final matchesStatus = _selectedStatus == 'All' ||
          s.status.name.toLowerCase() == _selectedStatus.toLowerCase();
      final matchesSource = _selectedSource == 'All' ||
          s.sourceType.toLowerCase().contains(_selectedSource.toLowerCase());
      return matchesStatus && matchesSource;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 650;
                final titleCol = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Continuous Scan Audit & History',
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
                      'Audit trail of scheduled automated crawls, candidate asset discoveries, and pipeline execution logs.',
                      style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );

                final triggerBtn = ElevatedButton.icon(
                  onPressed: provider.isScanning ? null : () => _triggerScanDialog(provider),
                  icon: provider.isScanning
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF090D16)),
                        )
                      : const Icon(Icons.radar_rounded, size: 16),
                  label: Text(provider.isScanning ? 'Scan in progress...' : 'Trigger New Scan'),
                );

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleCol,
                      const SizedBox(height: 14),
                      triggerBtn,
                    ],
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: titleCol),
                    const SizedBox(width: 16),
                    triggerBtn,
                  ],
                );
              },
            ),

            const SizedBox(height: 18),

            // Scanning progress banner if active
            if (provider.isScanning)
              Container(
                margin: const EdgeInsets.only(bottom: 18),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryTeal),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        provider.scanProgressMessage.isNotEmpty
                            ? provider.scanProgressMessage
                            : 'Crawler is analyzing brand perimeter...',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          color: AppTheme.primaryTeal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Summary Telemetry Metric Cards
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 850;
                final isMedium = constraints.maxWidth >= 480 && !isWide;

                if (isWide) {
                  return Row(
                    children: [
                      Expanded(
                        child: _buildMetricMiniCard('Total Scans', '${scans.length}', Icons.history_rounded, AppTheme.primaryTeal),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildMetricMiniCard('Candidates Checked', '$totalCandidates', Icons.travel_explore_rounded, AppTheme.riskInfo),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildMetricMiniCard('Flagged Impersonators', '$totalDetections', Icons.warning_amber_rounded, AppTheme.riskHigh),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildMetricMiniCard('Avg Pipeline Speed', '1.8 mins', Icons.speed_rounded, AppTheme.coralSunset),
                      ),
                    ],
                  );
                }

                if (isMedium) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricMiniCard('Total Scans', '${scans.length}', Icons.history_rounded, AppTheme.primaryTeal),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _buildMetricMiniCard('Candidates Checked', '$totalCandidates', Icons.travel_explore_rounded, AppTheme.riskInfo),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricMiniCard('Flagged Impersonators', '$totalDetections', Icons.warning_amber_rounded, AppTheme.riskHigh),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _buildMetricMiniCard('Avg Pipeline Speed', '1.8 mins', Icons.speed_rounded, AppTheme.coralSunset),
                          ),
                        ],
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    _buildMetricMiniCard('Total Scans', '${scans.length}', Icons.history_rounded, AppTheme.primaryTeal),
                    const SizedBox(height: 12),
                    _buildMetricMiniCard('Candidates Checked', '$totalCandidates', Icons.travel_explore_rounded, AppTheme.riskInfo),
                    const SizedBox(height: 12),
                    _buildMetricMiniCard('Flagged Impersonators', '$totalDetections', Icons.warning_amber_rounded, AppTheme.riskHigh),
                    const SizedBox(height: 12),
                    _buildMetricMiniCard('Avg Pipeline Speed', '1.8 mins', Icons.speed_rounded, AppTheme.coralSunset),
                  ],
                );
              },
            ),

            const SizedBox(height: 22),

            // Filters Bar
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Text('Status:', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
                    const SizedBox(width: 8),
                    ...['All', 'completed', 'failed'].map((st) {
                      final isSel = _selectedStatus.toLowerCase() == st.toLowerCase();
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(st == 'All' ? 'All' : st[0].toUpperCase() + st.substring(1)),
                          selected: isSel,
                          onSelected: (_) => setState(() => _selectedStatus = st),
                        ),
                      );
                    }),
                    const SizedBox(width: 24),
                    Text('Source:', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
                    const SizedBox(width: 8),
                    ...['All', 'Social', 'App', 'Dark Web'].map((src) {
                      final isSel = _selectedSource == src;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(src),
                          selected: isSel,
                          onSelected: (_) => setState(() => _selectedSource = src),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Scan Records List
            if (filtered.isEmpty)
              Container(
                padding: const EdgeInsets.all(48),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Text('No scan records matching selected criteria.', style: GoogleFonts.inter(color: AppTheme.textMuted)),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final record = filtered[index];
                  final isSuccess = record.status == ScanStatus.completed;

                  return Container(
                    padding: const EdgeInsets.all(18),
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
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: (isSuccess ? AppTheme.purpleGlow : AppTheme.riskCritical).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isSuccess ? Icons.check_circle_outline_rounded : Icons.error_outline_rounded,
                                color: isSuccess ? AppTheme.purpleGlow : AppTheme.riskCritical,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        record.id,
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.surfaceElevated,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          record.sourceType,
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: AppTheme.primaryTeal,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    dateFormat.format(record.scanDate),
                                    style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: (isSuccess ? AppTheme.purpleGlow : AppTheme.riskCritical).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: (isSuccess ? AppTheme.purpleGlow : AppTheme.riskCritical).withOpacity(0.4),
                                ),
                              ),
                              child: Text(
                                record.status.label,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isSuccess ? AppTheme.purpleGlow : AppTheme.riskCritical,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Stats row
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem('Candidates Checked', '${record.candidatesChecked}'),
                              Container(width: 1, height: 20, color: AppTheme.border),
                              _buildStatItem('Detections Discovered', '${record.detectionsCount}', color: AppTheme.riskHigh),
                              Container(width: 1, height: 20, color: AppTheme.border),
                              _buildStatItem('High-Risk Flags', '${record.highRiskCount}', color: AppTheme.riskCritical),
                              Container(width: 1, height: 20, color: AppTheme.border),
                              _buildStatItem('Duration', '${record.durationSeconds}s'),
                            ],
                          ),
                        ),
                        if (record.errors.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.riskHigh.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppTheme.riskHigh.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline_rounded, size: 14, color: AppTheme.riskHigh),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    record.errors.join('; '),
                                    style: GoogleFonts.inter(fontSize: 11, color: AppTheme.riskHigh),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricMiniCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textMuted)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textMuted)),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color ?? AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
