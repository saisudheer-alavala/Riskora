import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/threat_item.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/threat_card.dart';
import '../widgets/risk_badge.dart';

class SocialMonitoringScreen extends StatefulWidget {
  const SocialMonitoringScreen({super.key});

  @override
  State<SocialMonitoringScreen> createState() => _SocialMonitoringScreenState();
}

class _SocialMonitoringScreenState extends State<SocialMonitoringScreen> {
  String _searchQuery = '';
  String _selectedPlatform = 'All';
  String _selectedRiskLevel = 'All';
  String _sortBy = 'Highest Risk';

  void _showDetailModal(ThreatItem threat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.share_rounded, size: 18, color: AppTheme.primaryTeal),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Social Profile Forensic Evidence',
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
                style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              SelectableText(
                '${threat.platform} • ${threat.identifier}',
                style: GoogleFonts.jetBrainsMono(fontSize: 12, color: AppTheme.primaryTeal),
              ),
              const SizedBox(height: 12),
              Text(
                threat.description,
                style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: [
                    _buildModalMetricRow('Name Similarity', '${threat.nameSimilarity.toStringAsFixed(1)}%'),
                    Divider(height: 14, color: AppTheme.borderSubtle),
                    _buildModalMetricRow('Logo Visual Similarity', '${threat.logoSimilarity.toStringAsFixed(1)}%'),
                    Divider(height: 14, color: AppTheme.borderSubtle),
                    _buildModalMetricRow('Suspicious Flag Confidence', '${threat.breakdown.suspiciousKeywordsScore.toStringAsFixed(0)}%'),
                    Divider(height: 14, color: AppTheme.borderSubtle),
                    _buildModalMetricRow('Account Age Score', '${threat.breakdown.domainOrAccountAgeScore.toStringAsFixed(0)} / 100'),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Detected Threat Signals:',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 6),
              ...threat.detectionReasons.map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 14, color: AppTheme.riskHigh),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(r, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                      ),
                    ],
                  ),
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
            label: const Text('Open Investigation Workbench'),
          ),
        ],
      ),
    );
  }

  Widget _buildModalMetricRow(String label, String value) {
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
    final allSocial = provider.socialMediaThreats;

    // Filter by search query
    var filtered = allSocial.where((t) {
      final matchesSearch = _searchQuery.isEmpty ||
          t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.identifier.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.description.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesPlatform = _selectedPlatform == 'All' ||
          t.platform.toLowerCase().contains(_selectedPlatform.toLowerCase());

      final matchesRisk = _selectedRiskLevel == 'All' ||
          (_selectedRiskLevel == 'Critical' && t.riskScore >= 80) ||
          (_selectedRiskLevel == 'High' && t.riskScore >= 60 && t.riskScore < 80) ||
          (_selectedRiskLevel == 'Medium' && t.riskScore >= 40 && t.riskScore < 60) ||
          (_selectedRiskLevel == 'Low' && t.riskScore < 40);

      return matchesSearch && matchesPlatform && matchesRisk;
    }).toList();

    // Sort
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
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 600;
                final titleCol = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Social Media Brand Monitoring',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: isNarrow ? 20 : 24,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Automated detection of impersonation handles, scam accounts, and fraudulent social profiles.',
                      style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary),
                    ),
                  ],
                );

                final badge = Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.radar_rounded, size: 16, color: AppTheme.primaryTeal),
                      const SizedBox(width: 8),
                      Text(
                        '${filtered.length} of ${allSocial.length} Profiles',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleCol,
                      const SizedBox(height: 12),
                      badge,
                    ],
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: titleCol),
                    const SizedBox(width: 16),
                    badge,
                  ],
                );
              },
            ),

            const SizedBox(height: 22),

            // Filter & Search Controls Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 560;
                      final searchField = TextField(
                        style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Search by handle, profile name, or threat keyword...',
                          prefixIcon: Icon(Icons.search_rounded, size: 20, color: AppTheme.textMuted),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () => setState(() => _searchQuery = ''),
                                )
                              : null,
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val),
                      );

                      final sortDropdown = Container(
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
                      );

                      if (isNarrow) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            searchField,
                            const SizedBox(height: 12),
                            Align(alignment: Alignment.centerLeft, child: sortDropdown),
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(child: searchField),
                          const SizedBox(width: 14),
                          sortDropdown,
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  // Filter Chips row: Platform & Risk
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Text('Platform:', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted)),
                        const SizedBox(width: 8),
                        ...['All', 'Twitter', 'Telegram', 'Instagram', 'LinkedIn'].map((p) {
                          final isSel = _selectedPlatform == p;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(p),
                              selected: isSel,
                              onSelected: (_) => setState(() => _selectedPlatform = p),
                            ),
                          );
                        }),
                        const SizedBox(width: 16),
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
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Threat Candidates List
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
                      'No Matching Social Threats Found',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Try resetting filters or search terms to inspect all social profiles.',
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
                      _showDetailModal(threat);
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
