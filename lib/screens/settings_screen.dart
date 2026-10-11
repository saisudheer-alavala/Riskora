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
  late TextEditingController _apiKeyController;
  bool _obscureApiKey = true;
  double _similarityThreshold = 80.0;
  String _crawlFrequency = 'Every 1 Hour';
  bool _notifyCritical = true;
  bool _notifyHigh = true;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AppStateProvider>();
    _urlController = TextEditingController(text: provider.backendUrl);
    _apiKeyController = TextEditingController(text: provider.customGroqApiKey);
    _similarityThreshold = provider.similarityThreshold;
    _crawlFrequency = provider.crawlFrequency;
    _notifyCritical = provider.notifyCritical;
    _notifyHigh = provider.notifyHigh;
  }

  void _saveAllSettings() {
    final provider = context.read<AppStateProvider>();
    provider.updateBackendUrl(_urlController.text.trim());
    provider.updateCustomGroqApiKey(_apiKeyController.text.trim());
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
                    ? 'SecOps Intelligence Engine connected successfully!'
                    : 'Backend gateway offline or unreachable. Check endpoint URL.',
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
    provider.updateCustomGroqApiKey('');
    setState(() {
      _urlController.text = provider.backendUrl;
      _apiKeyController.clear();
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
    _apiKeyController.dispose();
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
                  // Quick Presets with responsive Wrap
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('Presets:', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted)),
                      _buildPresetChip('http://localhost:8000 (Desktop / Web)', 'http://localhost:8000', provider),
                      _buildPresetChip('http://10.0.2.2:8000 (Android Emulator)', 'http://10.0.2.2:8000', provider),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Section 1.5: Groq AI Copilot Engine Settings
            _buildSettingsCard(
              title: 'GroqCloud AI Engine (3 Chat Agents)',
              subtitle: 'Powers Brand Assistant, Risk Advisor, and SecOps Support using openai/gpt-oss-120b',
              icon: Icons.psychology_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _apiKeyController,
                          obscureText: _obscureApiKey,
                          style: GoogleFonts.jetBrainsMono(color: AppTheme.textPrimary, fontSize: 13),
                          decoration: InputDecoration(
                            labelText: 'Groq API Key (Override / Direct)',
                            hintText: 'gsk_...',
                            prefixIcon: const Icon(Icons.key_rounded, color: AppTheme.coralSunset),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureApiKey ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                color: AppTheme.textMuted,
                                size: 18,
                              ),
                              onPressed: () => setState(() => _obscureApiKey = !_obscureApiKey),
                            ),
                          ),
                          onSubmitted: (val) {
                            provider.updateCustomGroqApiKey(val.trim());
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          provider.updateCustomGroqApiKey(_apiKeyController.text.trim());
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Groq API Key calibrated for all 3 agents!',
                                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              backgroundColor: AppTheme.purpleElectric,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                        label: const Text('Apply Key'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Environment Note: Backend automatically loads GROQ_API_KEY from backend/.env or root .env (safely gitignored for GitHub). You can also provide or override the key here.',
                    style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Section 2: Scanning & Sensitivity Parameters (Responsive Layout)
            _buildSettingsCard(
              title: 'Crawl Frequency & Neural Sensitivity',
              subtitle: 'Fine-tune threat detection thresholds to balance false positives and detection velocity',
              icon: Icons.tune_rounded,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 640;

                  final similarityCol = Column(
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
                  );

                  final crawlCol = Column(
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
                  );

                  if (isNarrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        similarityCol,
                        const SizedBox(height: 20),
                        crawlCol,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: similarityCol),
                      const SizedBox(width: 24),
                      Expanded(child: crawlCol),
                    ],
                  );
                },
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
        color = const Color(0xFF10B981);
        label = 'SECOPS MATRIX ONLINE';
        icon = Icons.check_circle_rounded;
        break;
      case ApiConnectionStatus.disconnected:
        color = AppTheme.riskCritical;
        label = 'GATEWAY OFFLINE (RETRY)';
        icon = Icons.error_outline_rounded;
        break;
      case ApiConnectionStatus.demoMode:
        color = const Color(0xFF10B981);
        label = 'SECOPS MATRIX ONLINE';
        icon = Icons.check_circle_rounded;
        break;
      case ApiConnectionStatus.checking:
        color = AppTheme.primaryTeal;
        label = 'CONNECTING TO GATEWAY...';
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
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(14),
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
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
