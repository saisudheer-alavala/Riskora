import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _urlController;
  double _similarityThreshold = 80.0;
  String _crawlFrequency = 'Every 1 Hour';
  bool _notifyCritical = true;
  bool _notifyHigh = true;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AppStateProvider>();
    _urlController = TextEditingController(text: provider.backendUrl);
    _similarityThreshold = provider.similarityThreshold;
    _crawlFrequency = provider.crawlFrequency;
    _notifyCritical = provider.notifyCritical;
    _notifyHigh = provider.notifyHigh;
  }

  void _saveAllSettings() {
    final provider = context.read<AppStateProvider>();
    provider.updateBackendUrl(_urlController.text.trim());
    provider.saveSettings(
      similarityThreshold: _similarityThreshold,
      crawlFrequency: _crawlFrequency,
      notifyCritical: _notifyCritical,
      notifyHigh: _notifyHigh,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(
              'Settings saved successfully! Neural thresholds updated.',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: AppTheme.purpleElectric,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _testConnection() async {
    final provider = context.read<AppStateProvider>();
    provider.updateBackendUrl(_urlController.text.trim());
    await provider.testBackendConnection();
    if (!mounted) return;
    final status = provider.connectionStatus;
    final isOk = status == ApiConnectionStatus.connected;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isOk ? Icons.check_circle_rounded : Icons.info_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isOk
                    ? 'FastAPI backend connected successfully!'
                    : 'Backend offline or unreachable. Demo simulation mode is active.',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: isOk ? AppTheme.mintGreen : AppTheme.coralDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _resetDefaults() {
    final provider = context.read<AppStateProvider>();
    provider.resetSettingsToDefaults();
    setState(() {
      _urlController.text = provider.backendUrl;
      _similarityThreshold = provider.similarityThreshold;
      _crawlFrequency = provider.crawlFrequency;
      _notifyCritical = provider.notifyCritical;
      _notifyHigh = provider.notifyHigh;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(
              'Reset all configurations to factory defaults.',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: AppTheme.purpleElectric,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final connStatus = provider.connectionStatus;

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
                final isNarrow = constraints.maxWidth < 680;
                final titleColumn = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'System Configuration & API Settings',
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
                      'Configure Python FastAPI backend endpoint, crawl sensitivity, and notification protocols.',
                      style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );

                final statusAndSave = Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _buildStatusPill(connStatus),
                    ElevatedButton.icon(
                      onPressed: _saveAllSettings,
                      icon: const Icon(Icons.check_circle_rounded, size: 16),
                      label: const Text('Save Settings'),
                    ),
                  ],
                );

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleColumn,
                      const SizedBox(height: 14),
                      statusAndSave,
                    ],
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: titleColumn),
                    const SizedBox(width: 16),
                    statusAndSave,
                  ],
                );
              },
            ),

            const SizedBox(height: 22),

            // Section 0: Theme Mode (Dark & Light Theme)
            _buildSettingsCard(
              title: 'Visual Appearance & Theme Mode',
              subtitle: 'Select between deep cyber-stealth dark mode or clean high-contrast light mode',
              icon: Icons.palette_outlined,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 580;
                  final darkCard = _buildThemeOptionCard(
                    title: 'Dark Stealth Mode',
                    description: 'Deep obsidian canvas with anti-glare cyber styling.',
                    icon: Icons.dark_mode_rounded,
                    isSelected: provider.isDarkMode,
                    onTap: () => provider.setThemeMode(ThemeMode.dark),
                  );

                  final lightCard = _buildThemeOptionCard(
                    title: 'Light Enterprise Mode',
                    description: 'Clean crisp daylight theme with high-contrast surfaces.',
                    icon: Icons.light_mode_rounded,
                    isSelected: !provider.isDarkMode,
                    onTap: () => provider.setThemeMode(ThemeMode.light),
                  );

                  if (isNarrow) {
                    return Column(
                      children: [
                        darkCard,
                        const SizedBox(height: 12),
                        lightCard,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: darkCard),
                      const SizedBox(width: 14),
                      Expanded(child: lightCard),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 22),

            // Section 1: Backend Connection Config
            _buildSettingsCard(
              title: 'Python FastAPI Backend Connectivity',
              subtitle: 'Endpoint for threat crawler feeds, AI chat assistant, and takedown orchestration',
              icon: Icons.electrical_services_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _urlController,
                          style: GoogleFonts.jetBrainsMono(color: AppTheme.textPrimary, fontSize: 13),
                          decoration: const InputDecoration(
                            labelText: 'FastAPI Backend URL',
                            hintText: 'http://localhost:8000',
                            prefixIcon: Icon(Icons.link_rounded, color: AppTheme.primaryTeal),
                          ),
                          onSubmitted: (val) {
                            provider.updateBackendUrl(val.trim());
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _testConnection,
                        icon: connStatus == ApiConnectionStatus.checking
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.network_check_rounded, size: 16),
                        label: const Text('Test Connection'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Quick Presets
                  Row(
                    children: [
                      Text('Presets:', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted)),
                      const SizedBox(width: 8),
                      _buildPresetChip('http://localhost:8000 (Desktop / Web)', 'http://localhost:8000', provider),
                      const SizedBox(width: 6),
                      _buildPresetChip('http://10.0.2.2:8000 (Android Emulator)', 'http://10.0.2.2:8000', provider),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: AppTheme.borderSubtle),
                  const SizedBox(height: 12),
                  // Simulation / Demo Mode Switch
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Enable Offline Simulation Mode (Demo Data)',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                    ),
                    subtitle: Text(
                      'Allows presenting the entire frontend with synthetic intelligence models when the Python backend is offline or during demonstrations.',
                      style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted),
                    ),
                    value: provider.useDemoMode,
                    activeColor: AppTheme.primaryTeal,
                    onChanged: (val) {
                      provider.toggleDemoMode(val);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Section 2: Scanning & Sensitivity Parameters
            _buildSettingsCard(
              title: 'Crawl Frequency & Neural Sensitivity',
              subtitle: 'Fine-tune threat detection thresholds to balance false positives and detection velocity',
              icon: Icons.tune_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Similarity Trigger Threshold',
                                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                                ),
                                Text(
                                  '${_similarityThreshold.toInt()}%',
                                  style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primaryTeal),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Candidates with visual logo or phonetic name similarity above this value generate alerts.',
                              style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
                            ),
                            Slider(
                              value: _similarityThreshold,
                              min: 50,
                              max: 95,
                              divisions: 9,
                              activeColor: AppTheme.primaryTeal,
                              inactiveColor: AppTheme.surfaceElevated,
                              onChanged: (val) => setState(() => _similarityThreshold = val),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Automated Crawl Frequency',
                              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: _crawlFrequency,
                              dropdownColor: AppTheme.surfaceElevated,
                              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                              items: const [
                                DropdownMenuItem(value: 'Every 15 Mins', child: Text('Every 15 Minutes (Real-Time)')),
                                DropdownMenuItem(value: 'Every 1 Hour', child: Text('Every 1 Hour (Standard)')),
                                DropdownMenuItem(value: 'Every 6 Hours', child: Text('Every 6 Hours (Periodic)')),
                                DropdownMenuItem(value: 'Daily', child: Text('Daily Summary')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _crawlFrequency = val);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Section 3: Notification Preferences
            _buildSettingsCard(
              title: 'Incident Notification Alerts',
              subtitle: 'Dispatch SecOps notifications upon discovery of impersonation vectors',
              icon: Icons.notifications_active_outlined,
              child: Column(
                children: [
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Notify on Critical Threat Detections (Score >= 80)', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textPrimary)),
                    subtitle: Text('Immediate alerts for active credential phishers and trojanized APK packages', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted)),
                    value: _notifyCritical,
                    activeColor: AppTheme.riskCritical,
                    onChanged: (val) => setState(() => _notifyCritical = val ?? true),
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Notify on High Risk Impersonation Candidates (Score >= 60)', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textPrimary)),
                    subtitle: Text('Alerts when brand similarity exceeds the configured threshold', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted)),
                    value: _notifyHigh,
                    activeColor: AppTheme.riskHigh,
                    onChanged: (val) => setState(() => _notifyHigh = val ?? true),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Section 4: FastAPI REST API Specifications Documentation
            _buildSettingsCard(
              title: 'FastAPI Backend Endpoint Reference',
              subtitle: 'Pre-configured endpoints prepared for connection with your Python backend service',
              icon: Icons.code_rounded,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Centralized REST API routes ready in ApiService & ChatService:', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
                    const SizedBox(height: 10),
                    _buildApiRoute('GET', '/api/health', 'Health check ping for backend status indicator'),
                    _buildApiRoute('GET / PUT', '/api/brand-profile', 'Fetch and update registered brand baseline & identifiers'),
                    _buildApiRoute('GET', '/api/threats?type={social|app}', 'Query flagged detections filtered by channel'),
                    _buildApiRoute('POST', '/api/threats/{id}/status', 'Update review status (confirmed / false positive / takedown)'),
                    _buildApiRoute('POST', '/api/threats/{id}/notes', 'Record timestamped analyst investigation notes'),
                    _buildApiRoute('POST', '/api/chat', 'Multi-mode LLM endpoint (Brand Assistant, Risk Advisor, Support)'),
                    _buildApiRoute('POST', '/api/scans/run', 'Trigger multi-channel autonomous crawler scan'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Section 5: Save & Reset Action Controls
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _saveAllSettings,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                  ),
                  icon: const Icon(Icons.check_circle_rounded, size: 18),
                  label: const Text('Save & Apply Settings'),
                ),
                OutlinedButton.icon(
                  onPressed: _resetDefaults,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  icon: const Icon(Icons.restore_rounded, size: 18),
                  label: const Text('Reset Defaults'),
                ),
                TextButton.icon(
                  onPressed: () {
                    provider.refreshAllData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Cleared threat memory cache & re-synchronized feeds.'),
                        backgroundColor: AppTheme.purpleElectric,
                      ),
                    );
                  },
                  icon: const Icon(Icons.cleaning_services_rounded, size: 16),
                  label: const Text('Purge Cache'),
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPill(ApiConnectionStatus status) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case ApiConnectionStatus.connected:
        color = AppTheme.coralSunset;
        label = 'FASTAPI CONNECTED';
        icon = Icons.check_circle_rounded;
        break;
      case ApiConnectionStatus.disconnected:
        color = AppTheme.riskCritical;
        label = 'FASTAPI OFFLINE';
        icon = Icons.error_outline_rounded;
        break;
      case ApiConnectionStatus.demoMode:
        color = AppTheme.primaryTeal;
        label = 'SIMULATION SANDBOX ACTIVE';
        icon = Icons.science_outlined;
        break;
      case ApiConnectionStatus.checking:
        color = AppTheme.riskMedium;
        label = 'PINGING ENDPOINT...';
        icon = Icons.sync_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(String label, String url, AppStateProvider provider) {
    return ActionChip(
      label: Text(label),
      backgroundColor: AppTheme.surfaceElevated,
      labelStyle: GoogleFonts.jetBrainsMono(fontSize: 10, color: AppTheme.primaryTeal),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: AppTheme.border),
      ),
      onPressed: () {
        _urlController.text = url;
        provider.updateBackendUrl(url);
      },
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryTeal, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _buildApiRoute(String method, String path, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.4)),
            ),
            child: Text(
              method,
              style: GoogleFonts.jetBrainsMono(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(path, style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                Text(desc, style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOptionCard({
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.purpleElectric.withOpacity(0.16)
              : AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.purpleGlow : AppTheme.borderSubtle,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? AppTheme.coralSunset : AppTheme.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppTheme.coralSunset : AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded, size: 16, color: AppTheme.purpleGlow),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }
}
