import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state_provider.dart';
import 'theme/app_theme.dart';
import 'widgets/app_navigation.dart';
import 'widgets/intro_splash_screen.dart';

import 'screens/dashboard_screen.dart';
import 'screens/brand_profile_screen.dart';
import 'screens/social_monitoring_screen.dart';
import 'screens/app_monitoring_screen.dart';
import 'screens/investigation_screen.dart';
import 'screens/chat_assistant_screen.dart';
import 'screens/scan_history_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

class RiskoraApp extends StatelessWidget {
  final bool startAuthenticated;
  final bool startOnAuthScreen;
  final bool enableIntro;

  const RiskoraApp({
    super.key,
    this.startAuthenticated = false,
    this.startOnAuthScreen = false,
    this.enableIntro = true,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppStateProvider(
            initialAuthenticated: startAuthenticated,
            initialShowAuth: startOnAuthScreen,
          ),
        ),
      ],
      child: Consumer<AppStateProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
            title: 'RISKORA - Digital Risk Protection Platform',
            debugShowCheckedModeBanner: false,
            themeMode: provider.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: AppRootShell(enableIntro: enableIntro),
          );
        },
      ),
    );
  }
}

class AppRootShell extends StatefulWidget {
  final bool enableIntro;
  const AppRootShell({super.key, this.enableIntro = true});

  @override
  State<AppRootShell> createState() => _AppRootShellState();
}

class _AppRootShellState extends State<AppRootShell> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();

    if (!provider.isAuthenticated) {
      if (provider.showAuthScreen) {
        return const AuthScreen();
      }
      if (widget.enableIntro) {
        return const IntroVideoSplashScreen(
          nextScreen: HomeScreen(),
        );
      }
      return const HomeScreen();
    }

    final index = provider.currentNavIndex;

    final Widget activeScreen;
    switch (index) {
      case 0:
        activeScreen = const DashboardScreen();
        break;
      case 1:
        activeScreen = const BrandProfileScreen();
        break;
      case 2:
        activeScreen = const SocialMonitoringScreen();
        break;
      case 3:
        activeScreen = const AppMonitoringScreen();
        break;
      case 4:
        activeScreen = const ThreatInvestigationScreen();
        break;
      case 5:
        activeScreen = const ChatAssistantScreen();
        break;
      case 6:
        activeScreen = const ScanHistoryScreen();
        break;
      case 7:
        activeScreen = const ReportsScreen();
        break;
      case 8:
        activeScreen = const SettingsScreen();
        break;
      default:
        activeScreen = const DashboardScreen();
    }

    return AppNavigationShell(
      child: activeScreen,
    );
  }
}
