import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/stat_card.dart';
import '../widgets/threat_card.dart';
import '../widgets/demo_banner.dart';
import '../widgets/floating_ai_button.dart';
import '../widgets/charts/risk_distribution_chart.dart';
import '../widgets/charts/threat_timeline_chart.dart';
import '../widgets/quick_chat_dialog.dart';
import '../widgets/animated_gradient_button.dart';
import '../widgets/cyber_ticker_banner.dart';
import '../widgets/cyber_radar_widget.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final threats = provider.threats;
    final recentThreats = threats.take(3).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: const FloatingAiButton(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header & Actions
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 650;
                final titleColumn = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Security Operations Center',
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
                      'Real-time brand impersonation and digital threat defense matrix',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );

                final actionsWrap = Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => provider.refreshAllData(),
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Refresh'),
                    ),
                    AnimatedGradientButton(
                      onPressed: provider.isScanning
                          ? null
                          : () => provider.triggerNewScan(sourceType: 'All Sources'),
                      icon: Icons.radar_rounded,
                      text: provider.isScanning ? 'Scanning...' : 'Trigger Scan',
                      isLoading: provider.isScanning,
                    ),
                  ],
                );

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleColumn,
                      const SizedBox(height: 14),
                      actionsWrap,
                    ],
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: titleColumn),
                    const SizedBox(width: 16),
                    actionsWrap,
                  ],
                );
              },
            ),

            const SizedBox(height: 16),

            // Red Points Inspired Animated Cyber Threat Ticker Banner
            const CyberTickerBanner(),

            // Demo Mode Notice Banner
            DemoBanner(
              status: provider.connectionStatus,
              onSettingsTap: () => provider.setNavIndex(8),
            ),

            // 4 Required Telemetry Stat Cards
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 900;
                final isMedium = constraints.maxWidth >= 550 && !isWide;

                if (isWide) {
                  return Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Total Detections',
                          value: '${provider.totalDetectionsCount}',
                          subtitle: 'Across web, apps & social',
                          icon: Icons.shield_rounded,
                          accentColor: AppTheme.primaryTeal,
                          trend: '+14% w/w',
                          isTrendPositive: true,
                          onTap: () => provider.setNavIndex(2),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: StatCard(
                          title: 'Social Candidates',
                          value: '${provider.socialCandidatesCount}',
                          subtitle: 'Accounts under review',
                          icon: Icons.alternate_email_rounded,
                          accentColor: AppTheme.riskInfo,
                          trend: '3 critical',
                          isTrendPositive: true,
                          onTap: () => provider.setNavIndex(2),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: StatCard(
                          title: 'Suspicious Apps',
                          value: '${provider.suspiciousAppsCount}',
                          subtitle: 'Cloned app packages',
                          icon: Icons.apps_rounded,
                          accentColor: AppTheme.riskHigh,
                          trend: '+2 new APKs',
                          isTrendPositive: true,
                          onTap: () => provider.setNavIndex(3),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: StatCard(
                          title: 'High-Risk Alerts',
                          value: '${provider.highRiskAlertsCount}',
                          subtitle: 'Requires immediate triage',
                          icon: Icons.warning_rounded,
                          accentColor: AppTheme.riskCritical,
                          trend: 'Critical urgency',
                          isTrendPositive: true,
                          onTap: () => provider.setNavIndex(4),
                        ),
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
                            child: StatCard(
                              title: 'Total Detections',
                              value: '${provider.totalDetectionsCount}',
                              subtitle: 'Across web, apps & social',
                              icon: Icons.shield_rounded,
                              accentColor: AppTheme.primaryTeal,
                              trend: '+14% w/w',
                              isTrendPositive: true,
                              onTap: () => provider.setNavIndex(2),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: StatCard(
                              title: 'Social Candidates',
                              value: '${provider.socialCandidatesCount}',
                              subtitle: 'Accounts under review',
                              icon: Icons.alternate_email_rounded,
                              accentColor: AppTheme.riskInfo,
                              trend: '3 critical',
                              isTrendPositive: true,
                              onTap: () => provider.setNavIndex(2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              title: 'Suspicious Apps',
                              value: '${provider.suspiciousAppsCount}',
                              subtitle: 'Cloned app packages',
                              icon: Icons.apps_rounded,
                              accentColor: AppTheme.riskHigh,
                              trend: '+2 new APKs',
                              isTrendPositive: true,
                              onTap: () => provider.setNavIndex(3),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: StatCard(
                              title: 'High-Risk Alerts',
                              value: '${provider.highRiskAlertsCount}',
                              subtitle: 'Requires immediate triage',
                              icon: Icons.warning_rounded,
                              accentColor: AppTheme.riskCritical,
                              trend: 'Critical urgency',
                              isTrendPositive: true,
                              onTap: () => provider.setNavIndex(4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }

                // Mobile
                return Column(
                  children: [
                    StatCard(
                      title: 'Total Detections',
                      value: '${provider.totalDetectionsCount}',
                      subtitle: 'Across web, apps & social',
                      icon: Icons.shield_rounded,
                      accentColor: AppTheme.primaryTeal,
                      trend: '+14% w/w',
                      isTrendPositive: true,
                      onTap: () => provider.setNavIndex(2),
                    ),
                    const SizedBox(height: 12),
                    StatCard(
                      title: 'Social Candidates',
                      value: '${provider.socialCandidatesCount}',
                      subtitle: 'Accounts under review',
                      icon: Icons.alternate_email_rounded,
                      accentColor: AppTheme.riskInfo,
                      trend: '3 critical',
                      isTrendPositive: true,
                      onTap: () => provider.setNavIndex(2),
                    ),
                    const SizedBox(height: 12),
                    StatCard(
                      title: 'Suspicious Apps',
                      value: '${provider.suspiciousAppsCount}',
                      subtitle: 'Cloned app packages',
                      icon: Icons.apps_rounded,
                      accentColor: AppTheme.riskHigh,
                      trend: '+2 new APKs',
                      isTrendPositive: true,
                      onTap: () => provider.setNavIndex(3),
                    ),
                    const SizedBox(height: 12),
                    StatCard(
                      title: 'High-Risk Alerts',
                      value: '${provider.highRiskAlertsCount}',
                      subtitle: 'Requires immediate triage',
                      icon: Icons.warning_rounded,
                      accentColor: AppTheme.riskCritical,
                      trend: 'Critical urgency',
                      isTrendPositive: true,
                      onTap: () => provider.setNavIndex(4),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 22),

            // Red Points Signature 360-degree Cyber Threat Radar Visualizer
            const CyberRadarWidget(),

            const SizedBox(height: 24),

            // Charts Section: Risk Distribution & Activity Timeline
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 900;
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(flex: 6, child: ThreatTimelineChart()),
                      const SizedBox(width: 18),
                      Expanded(
                        flex: 5,
                        child: RiskDistributionChart(
                          distribution: provider.reportSummary.riskDistribution,
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  children: [
                    const ThreatTimelineChart(),
                    const SizedBox(height: 18),
                    RiskDistributionChart(
                      distribution: provider.reportSummary.riskDistribution,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 28),

            // Quick Actions Toolbar
            Container(
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
                      const Icon(Icons.bolt_rounded, color: AppTheme.primaryTeal, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'SecOps Quick Actions',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      _buildQuickActionBtn(
                        icon: Icons.radar_rounded,
                        label: 'Run Crawl Scan',
                        color: AppTheme.primaryTeal,
                        onTap: () => provider.triggerNewScan(),
                      ),
                      _buildQuickActionBtn(
                        icon: Icons.domain_rounded,
                        label: 'Configure Brand Assets',
                        color: AppTheme.riskInfo,
                        onTap: () => provider.setNavIndex(1),
                      ),
                      _buildQuickActionBtn(
                        icon: Icons.smart_toy_rounded,
                        label: 'Consult AI Advisor',
                        color: AppTheme.purpleGlow,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => const QuickChatDialog(),
                          );
                        },
                      ),
                      _buildQuickActionBtn(
                        icon: Icons.picture_as_pdf_rounded,
                        label: 'Generate Incident Report',
                        color: AppTheme.riskHigh,
                        onTap: () => provider.setNavIndex(7),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Recent Detections Section
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Detections & Critical Candidates',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'High-priority impersonation candidates awaiting review',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => provider.setNavIndex(2),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: const Text('View All Detections'),
                ),
              ],
            ),

            const SizedBox(height: 14),

            if (recentThreats.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.verified_user_rounded, color: AppTheme.purpleGlow, size: 40),
                    const SizedBox(height: 10),
                    Text(
                      'No Active Threats Flagged',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Your registered brand perimeter is currently clean.',
                      style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentThreats.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final threat = recentThreats[index];
                  return ThreatCard(
                    threat: threat,
                    onInvestigate: () {
                      provider.selectThreatForInvestigation(threat);
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

  Widget _buildQuickActionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
