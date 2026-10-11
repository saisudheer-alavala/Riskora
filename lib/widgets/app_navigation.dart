import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'red_points_background.dart';
import 'animated_gradient_button.dart';

class NavDestinationItem {
  final String title;
  final IconData icon;
  final IconData selectedIcon;
  final int? badgeCount;

  const NavDestinationItem({
    required this.title,
    required this.icon,
    required this.selectedIcon,
    this.badgeCount,
  });
}

class AppNavigationShell extends StatelessWidget {
  final Widget child;

  const AppNavigationShell({
    super.key,
    required this.child,
  });

  static List<NavDestinationItem> getDestinations(AppStateProvider provider) {
    return [
      const NavDestinationItem(
        title: 'Dashboard',
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard_rounded,
      ),
      const NavDestinationItem(
        title: 'Brand Profile',
        icon: Icons.domain_outlined,
        selectedIcon: Icons.domain_rounded,
      ),
      NavDestinationItem(
        title: 'Social Monitoring',
        icon: Icons.tag_outlined,
        selectedIcon: Icons.tag_rounded,
        badgeCount: provider.socialCandidatesCount,
      ),
      NavDestinationItem(
        title: 'App Monitoring',
        icon: Icons.apps_outlined,
        selectedIcon: Icons.apps_rounded,
        badgeCount: provider.suspiciousAppsCount,
      ),
      NavDestinationItem(
        title: 'Threat Investigation',
        icon: Icons.biotech_outlined,
        selectedIcon: Icons.biotech_rounded,
        badgeCount: provider.highRiskAlertsCount,
      ),
      const NavDestinationItem(
        title: 'AI Chat Assistant',
        icon: Icons.smart_toy_outlined,
        selectedIcon: Icons.smart_toy_rounded,
      ),
      const NavDestinationItem(
        title: 'Scan History',
        icon: Icons.history_outlined,
        selectedIcon: Icons.history_rounded,
      ),
      const NavDestinationItem(
        title: 'Reports & Analytics',
        icon: Icons.assessment_outlined,
        selectedIcon: Icons.assessment_rounded,
      ),
      const NavDestinationItem(
        title: 'Settings',
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings_rounded,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final currentIndex = provider.currentNavIndex;
    final destinations = getDestinations(provider);

    return RedPointsBackground(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1024;
          final isTablet = constraints.maxWidth >= 640 && constraints.maxWidth < 1024;

          if (isDesktop) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: Row(
                children: [
                  _buildDesktopSidebar(context, provider, destinations, currentIndex),
                  VerticalDivider(width: 1, thickness: 1, color: AppTheme.border),
                  Expanded(child: child),
                ],
              ),
            );
          }

          if (isTablet) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: Row(
                children: [
                  _buildTabletNavRail(context, provider, destinations, currentIndex),
                  VerticalDivider(width: 1, thickness: 1, color: AppTheme.border),
                  Expanded(child: child),
                ],
              ),
            );
          }

          // Mobile layout with drawer & bottom nav
          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: AppTheme.surface.withOpacity(0.95),
              elevation: 0,
              title: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E5FF).withOpacity(0.35),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/riskora_emblem.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'RISKORA',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      fontSize: 16,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            actions: [
              IconButton(
                icon: Icon(
                  provider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  size: 20,
                  color: provider.isDarkMode ? AppTheme.coralSunset : AppTheme.purpleElectric,
                ),
                onPressed: () => provider.toggleTheme(),
                tooltip: provider.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 20),
                onPressed: () => provider.refreshAllData(),
                tooltip: 'Refresh Data',
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, size: 20),
                onPressed: () => provider.setNavIndex(8),
                tooltip: 'Settings',
              ),
            ],
          ),
          drawer: _buildMobileDrawer(context, provider, destinations, currentIndex),
          body: child,
          bottomNavigationBar: _buildMobileBottomNav(provider, currentIndex),
        );
      },
    ),
  );
}

  Widget _buildDesktopSidebar(
    BuildContext context,
    AppStateProvider provider,
    List<NavDestinationItem> destinations,
    int currentIndex,
  ) {
    return Container(
      width: 260,
      color: AppTheme.backgroundCanvas,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & Branding Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.borderSubtle)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withOpacity(0.35),
                        blurRadius: 14,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/riskora_emblem.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'RISKORA',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              fontSize: 16,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: AppTheme.purpleElectric.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppTheme.purpleGlow.withOpacity(0.4), width: 0.8),
                            ),
                            child: Text(
                              'DRP',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.coralSunset,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Digital Risk Protection',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Monitored Brand Pill
          Container(
            margin: const EdgeInsets.all(14),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.coralSunset,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.brandProfile.companyName,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Sentinel Shield Active',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: AppTheme.coralSunset,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Navigation Links
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              itemCount: destinations.length,
              separatorBuilder: (_, _) => const SizedBox(height: 2),
              itemBuilder: (context, index) {
                final item = destinations[index];
                final isSelected = currentIndex == index;

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => provider.setNavIndex(index),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.purpleElectric.withOpacity(0.18)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: isSelected
                            ? Border.all(color: AppTheme.purpleGlow.withOpacity(0.5), width: 1)
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? item.selectedIcon : item.icon,
                            size: 19,
                            color: isSelected ? AppTheme.coralSunset : AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.title,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                              ),
                            ),
                          ),
                          if (item.badgeCount != null && item.badgeCount! > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: index == 4
                                    ? AppTheme.riskCritical.withOpacity(0.2)
                                    : AppTheme.primaryTeal.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: index == 4
                                      ? AppTheme.riskCritical.withOpacity(0.5)
                                      : AppTheme.primaryTeal.withOpacity(0.4),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                '${item.badgeCount}',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: index == 4 ? AppTheme.riskCritical : AppTheme.primaryTeal,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom System Status / Fast Trigger
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppTheme.borderSubtle)),
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: provider.connectionStatus != ApiConnectionStatus.connected
                      ? () => provider.testBackendConnection()
                      : null,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: provider.connectionStatus == ApiConnectionStatus.connected
                                ? const Color(0xFF10B981)
                                : (provider.connectionStatus == ApiConnectionStatus.checking
                                    ? AppTheme.primaryTeal
                                    : const Color(0xFFF59E0B)),
                            shape: BoxShape.circle,
                            boxShadow: provider.connectionStatus == ApiConnectionStatus.connected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF10B981).withOpacity(0.5),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    )
                                  ]
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            provider.connectionStatus == ApiConnectionStatus.connected
                                ? 'SecOps Matrix Online'
                                : (provider.connectionStatus == ApiConnectionStatus.checking
                                    ? 'Connecting SecOps...'
                                    : 'SecOps Offline (Tap Retry)'),
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: provider.connectionStatus == ApiConnectionStatus.connected
                                  ? const Color(0xFF10B981)
                                  : AppTheme.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                AnimatedGradientButton(
                  width: double.infinity,
                  height: 38,
                  onPressed: provider.isScanning
                      ? null
                      : () => provider.triggerNewScan(),
                  icon: Icons.radar_rounded,
                  text: provider.isScanning ? 'Scanning...' : 'Run New Scan',
                  isLoading: provider.isScanning,
                ),
                const SizedBox(height: 10),
                // Theme Mode Switcher Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            provider.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                            size: 15,
                            color: provider.isDarkMode ? AppTheme.purpleGlow : AppTheme.coralDark,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            provider.isDarkMode ? 'Dark Stealth' : 'Light Clean',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          provider.isDarkMode ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
                          size: 26,
                          color: provider.isDarkMode ? AppTheme.purpleGlow : AppTheme.coralDark,
                        ),
                        onPressed: () => provider.toggleTheme(),
                        tooltip: 'Toggle Dark / Light Theme',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Current User & Logout
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AppTheme.purpleElectric,
                      child: Text(
                        provider.currentUserName.isNotEmpty
                            ? provider.currentUserName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        provider.currentUserName,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout_rounded, size: 16, color: AppTheme.coralSunset),
                      tooltip: 'Sign Out to Login Page',
                      onPressed: () => provider.logout(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletNavRail(
    BuildContext context,
    AppStateProvider provider,
    List<NavDestinationItem> destinations,
    int currentIndex,
  ) {
    return Container(
      width: 78,
      color: AppTheme.backgroundCanvas,
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/riskora_emblem.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: destinations.length,
              itemBuilder: (context, index) {
                final item = destinations[index];
                final isSelected = currentIndex == index;

                return IconButton(
                  icon: Badge(
                    isLabelVisible: item.badgeCount != null && item.badgeCount! > 0,
                    label: Text('${item.badgeCount}'),
                    child: Icon(
                      isSelected ? item.selectedIcon : item.icon,
                      color: isSelected ? AppTheme.coralSunset : AppTheme.textSecondary,
                    ),
                  ),
                  tooltip: item.title,
                  onPressed: () => provider.setNavIndex(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileDrawer(
    BuildContext context,
    AppStateProvider provider,
    List<NavDestinationItem> destinations,
    int currentIndex,
  ) {
    return Drawer(
      backgroundColor: AppTheme.backgroundCanvas,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.border)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E5FF).withOpacity(0.35),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/riskora_emblem.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RISKORA DRP',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'Cyber Threat Defense',
                          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: destinations.length,
                itemBuilder: (context, index) {
                  final item = destinations[index];
                  final isSelected = currentIndex == index;

                  return ListTile(
                    leading: Icon(
                      isSelected ? item.selectedIcon : item.icon,
                      color: isSelected ? AppTheme.primaryTeal : AppTheme.textSecondary,
                    ),
                    title: Text(
                      item.title,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppTheme.primaryTeal : AppTheme.textPrimary,
                      ),
                    ),
                    trailing: item.badgeCount != null && item.badgeCount! > 0
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryTeal.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${item.badgeCount}',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryTeal,
                              ),
                            ),
                          )
                        : null,
                    selected: isSelected,
                    onTap: () {
                      Navigator.pop(context);
                      provider.setNavIndex(index);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileBottomNav(AppStateProvider provider, int currentIndex) {
    // 5 primary mobile destinations: Dashboard (0), Social (2), Apps (3), Investigation (4), AI Chat (5)
    final mobileIndices = [0, 2, 3, 4, 5];
    final selectedMobileIndex = mobileIndices.indexOf(currentIndex);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: BottomNavigationBar(
        currentIndex: selectedMobileIndex != -1 ? selectedMobileIndex : 0,
        backgroundColor: AppTheme.surface,
        selectedItemColor: AppTheme.primaryTeal,
        unselectedItemColor: AppTheme.textMuted,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 10),
        onTap: (idx) {
          provider.setNavIndex(mobileIndices[idx]);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tag_outlined),
            activeIcon: Icon(Icons.tag_rounded),
            label: 'Social',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apps_outlined),
            activeIcon: Icon(Icons.apps_rounded),
            label: 'Apps',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.biotech_outlined),
            activeIcon: Icon(Icons.biotech_rounded),
            label: 'Forensics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy_outlined),
            activeIcon: Icon(Icons.smart_toy_rounded),
            label: 'AI Copilot',
          ),
        ],
      ),
    );
  }
}
