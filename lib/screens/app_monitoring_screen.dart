import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/threat_item.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/threat_card.dart';
import '../widgets/risk_badge.dart';

class AppMonitoringScreen extends StatefulWidget {
  const AppMonitoringScreen({super.key});

  @override
  State<AppMonitoringScreen> createState() => _AppMonitoringScreenState();
}

class _AppMonitoringScreenState extends State<AppMonitoringScreen> {
  String _searchQuery = '';
  String _selectedStore = 'All';
  String _selectedRiskLevel = 'All';
  String _sortBy = 'Highest Risk';

  void _showAppDetailsDialog(ThreatItem threat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.riskHigh.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.apps_rounded, size: 18, color: AppTheme.riskHigh),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Malicious APK / App Forensics',
                style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            RiskBadge(score: threat.riskScore),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                threat.title,
                style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              SelectableText(
                'Package: ${threat.identifier}',
                style: GoogleFonts.jetBrainsMono(fontSize: 12, color: AppTheme.primaryTeal),
              ),
              Text(
                threat.developerOrAuthor,
                style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 12),
              Text(
                threat.description,
                style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 14),
              // Suspicious Indicator Chips
              Text(
                'Suspicious Indicators & Risky Permissions:',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: threat.indicators.map((ind) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.riskCritical.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.riskCritical.withOpacity(0.4), width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.security_update_warning_rounded, size: 12, color: AppTheme.riskCritical),
                        const SizedBox(width: 6),
                        Text(
                          ind,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.riskCritical,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: [
                    _buildRow('Store / Distribution', threat.platform),
                    Divider(height: 12, color: AppTheme.borderSubtle),
                    _buildRow('Name Match Vector', '${threat.nameSimilarity.toStringAsFixed(1)}%'),
                    Divider(height: 12, color: AppTheme.borderSubtle),
                    _buildRow('Logo Similarity', '${threat.logoSimilarity.toStringAsFixed(1)}%'),
                    Divider(height: 12, color: AppTheme.borderSubtle),
                    _buildRow('Malware Permission Score', '${threat.breakdown.permissionMalwareScore.toStringAsFixed(0)} / 100'),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AppStateProvider>().selectThreatForInvestigation(threat);
            },
            icon: const Icon(Icons.biotech_rounded, size: 16),
            label: const Text('Investigate Threat'),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
        Text(value, style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final allApps = provider.appStoreThreats;

    var filtered = allApps.where((t) {
      final matchesSearch = _searchQuery.isEmpty ||
          t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.identifier.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.developerOrAuthor.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.description.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStore = _selectedStore == 'All' ||
          t.platform.toLowerCase().contains(_selectedStore.toLowerCase());

      final matchesRisk = _selectedRiskLevel == 'All' ||
          (_selectedRiskLevel == 'Critical' && t.riskScore >= 80) ||
          (_selectedRiskLevel == 'High' && t.riskScore >= 60 && t.riskScore < 80) ||
          (_selectedRiskLevel == 'Medium' && t.riskScore >= 40 && t.riskScore < 60) ||
          (_selectedRiskLevel == 'Low' && t.riskScore < 40);

      return matchesSearch && matchesStore && matchesRisk;
    }).toList();

    if (_sortBy == 'Highest Risk') {
      filtered.sort((a, b) => b.riskScore.compareTo(a.riskScore));
    } else if (_sortBy == 'Lowest Risk') {
      filtered.sort((a, b) => a.riskScore.compareTo(b.riskScore));
    } else if (_sortBy == 'Name Similarity') {
      filtered.sort((a, b) => b.nameSimilarity.compareTo(a.nameSimilarity));
    } else if (_sortBy == 'Newest') {
      filtered.sort((a, b) => b.detectedAt.compareTo(a.detectedAt));
    }

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
                        'App Store Impersonation Defense',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Continuous crawl across Google Play, Apple App Store, and third-party APK repositories.',
                        style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.android_rounded, size: 16, color: AppTheme.primaryTeal),
                      const SizedBox(width: 8),
                      Text(
                        '${filtered.length} Flagged Packages',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // Filter bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: TextField(
                          style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Search by app name, package ID (com.example), or developer...',
                            prefixIcon: Icon(Icons.search_rounded, size: 20, color: AppTheme.textMuted),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, size: 18),
                                    onPressed: () => setState(() => _searchQuery = ''),
                                  )
                                : null,
                          ),
                          onChanged: (val) => setState(() => _searchQuery = val),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceElevated,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _sortBy,
                            dropdownColor: AppTheme.surfaceElevated,
                            style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 12),
                            icon: const Icon(Icons.sort_rounded, size: 18, color: AppTheme.primaryTeal),
                            items: const [
                              DropdownMenuItem(value: 'Highest Risk', child: Text('Sort: Highest Risk')),
                              DropdownMenuItem(value: 'Lowest Risk', child: Text('Sort: Lowest Risk')),
                              DropdownMenuItem(value: 'Name Similarity', child: Text('Sort: Name Match')),
                              DropdownMenuItem(value: 'Newest', child: Text('Sort: Newest')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _sortBy = val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text('Repository:', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: ['All', 'Google Play', 'Apple App', 'APK Mirror'].map((s) {
                              final isSel = _selectedStore == s;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: ChoiceChip(
                                  label: Text(s),
                                  selected: isSel,
                                  onSelected: (_) => setState(() => _selectedStore = s),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('Risk:', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted)),
                      const SizedBox(width: 8),
                      ...['All', 'Critical', 'High', 'Medium', 'Low'].map((r) {
                        final isSel = _selectedRiskLevel == r;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(r),
                            selected: isSel,
                            onSelected: (_) => setState(() => _selectedRiskLevel = r),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            if (filtered.isEmpty)
              Container(
                padding: const EdgeInsets.all(48),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, color: AppTheme.purpleGlow, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'No Rogue Mobile Applications Found',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'No unauthorized packages match the active search and filter constraints.',
                      style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final threat = filtered[index];
                  return ThreatCard(
                    threat: threat,
                    onInvestigate: () {
                      _showAppDetailsDialog(threat);
                    },
                  );
                },
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
