import 'package:flutter/material.dart';
import '../models/brand_profile.dart';
import '../models/threat_item.dart';
import '../models/scan_record.dart';
import '../models/report_data.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';
import '../services/chat_service.dart';
import '../services/mock_data_service.dart';
import '../theme/app_theme.dart';

class AppStateProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final ChatService _chatService = ChatService();

  // Navigation
  int _currentNavIndex = 0;
  int get currentNavIndex => _currentNavIndex;

  // Data states
  late BrandProfile _brandProfile;
  List<ThreatItem> _threats = [];
  List<ScanRecord> _scanRecords = [];
  late ReportSummary _reportSummary;
  ThreatItem? _selectedThreat;

  // Chat
  ChatMode _currentChatMode = ChatMode.riskAdvisor;
  List<ChatMessage> _chatMessages = [];
  bool _isChatThinking = false;

  // Loading & Scan Progress
  bool _isLoading = false;
  bool _isScanning = false;
  String _scanProgressMessage = '';

  // Settings
  String _backendUrl = 'http://localhost:8000';
  bool _useDemoMode = true;
  ApiConnectionStatus _connectionStatus = ApiConnectionStatus.demoMode;
  ThemeMode _themeMode = ThemeMode.dark;
  double _similarityThreshold = 80.0;
  String _crawlFrequency = 'Every 1 Hour';
  bool _notifyCritical = true;
  bool _notifyHigh = true;

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  double get similarityThreshold => _similarityThreshold;
  String get crawlFrequency => _crawlFrequency;
  bool get notifyCritical => _notifyCritical;
  bool get notifyHigh => _notifyHigh;
  BrandProfile get brandProfile => _brandProfile;
  List<ThreatItem> get threats => _threats;
  List<ScanRecord> get scanRecords => _scanRecords;
  ReportSummary get reportSummary => _reportSummary;
  ThreatItem? get selectedThreat => _selectedThreat;

  ChatMode get currentChatMode => _currentChatMode;
  List<ChatMessage> get chatMessages => _chatMessages;
  bool get isChatThinking => _isChatThinking;

  bool get isLoading => _isLoading;
  bool get isScanning => _isScanning;
  String get scanProgressMessage => _scanProgressMessage;

  String get backendUrl => _backendUrl;
  bool get useDemoMode => _useDemoMode;
  ApiConnectionStatus get connectionStatus => _connectionStatus;

  // Filtered queries for screens
  List<ThreatItem> get socialMediaThreats =>
      _threats.where((t) => t.type == ThreatType.socialMedia).toList();

  List<ThreatItem> get appStoreThreats =>
      _threats.where((t) => t.type == ThreatType.appStore).toList();

  int get totalDetectionsCount => _threats.length;
  int get socialCandidatesCount => socialMediaThreats.length;
  int get suspiciousAppsCount => appStoreThreats.length;
  int get highRiskAlertsCount =>
      _threats.where((t) => t.riskScore >= 70).length;

  // Authentication State
  bool _isAuthenticated = false;
  String? _currentUserIdentifier;
  String? _currentUserName;
  DateTime? _currentUserDob;

  bool _showAuthScreen = false;
  bool get showAuthScreen => _showAuthScreen;

  bool get isAuthenticated => _isAuthenticated;
  String? get currentUserIdentifier => _currentUserIdentifier;
  String get currentUserName => _currentUserName ?? 'SecOps Analyst';
  DateTime? get currentUserDob => _currentUserDob;

  AppStateProvider({bool initialAuthenticated = false, bool initialShowAuth = false}) {
    _isAuthenticated = initialAuthenticated;
    _showAuthScreen = initialShowAuth;
    _brandProfile = MockDataService.getInitialBrandProfile();
    _threats = MockDataService.getInitialThreats();
    _scanRecords = MockDataService.getInitialScanRecords();
    _reportSummary = MockDataService.getInitialReportSummary();
    _chatMessages = _chatService.getInitialMessages();
    if (_threats.isNotEmpty) {
      _selectedThreat = _threats.first;
    }
  }

  void openAuthScreen() {
    _showAuthScreen = true;
    notifyListeners();
  }

  void openHomeScreen() {
    _showAuthScreen = false;
    notifyListeners();
  }

  bool login(String identifier, String password) {
    if (identifier.trim().isEmpty || password.trim().isEmpty) {
      return false;
    }
    _isAuthenticated = true;
    _showAuthScreen = false;
    _currentUserIdentifier = identifier.trim();
    _currentUserName = identifier.contains('@')
        ? identifier.split('@').first
        : identifier.trim();
    notifyListeners();

    // Trigger asynchronous persistent backend sync
    _syncLogin(identifier.trim(), password);
    return true;
  }

  Future<void> _syncLogin(String email, String password) async {
    try {
      final res = await _apiService.login(email, password);
      if (res != null && res['user'] != null) {
        if (res['user']['name'] != null) {
          _currentUserName = res['user']['name'];
        }
        await refreshAllData();
      }
    } catch (e) {
      debugPrint('Sync login fallback: $e');
    }
  }

  bool register({
    required String name,
    required String email,
    required DateTime dob,
    required String password,
  }) {
    if (name.trim().isEmpty || email.trim().isEmpty || password.trim().isEmpty) {
      return false;
    }
    _isAuthenticated = true;
    _showAuthScreen = false;
    _currentUserName = name.trim();
    _currentUserIdentifier = email.trim();
    _currentUserDob = dob;
    notifyListeners();

    // Trigger asynchronous persistent backend registration
    _syncRegister(name.trim(), email.trim(), password, dob);
    return true;
  }

  Future<void> _syncRegister(String name, String email, String password, DateTime dob) async {
    try {
      final res = await _apiService.register(
        name: name,
        email: email,
        password: password,
        dob: dob,
      );
      if (res != null) {
        await refreshAllData();
      }
    } catch (e) {
      debugPrint('Sync register fallback: $e');
    }
  }

  void logout() {
    _isAuthenticated = false;
    _showAuthScreen = false;
    _currentUserIdentifier = null;
    _currentUserName = null;
    _currentNavIndex = 0;
    _apiService.setAuthToken(null);
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    AppTheme.currentIsDark = _themeMode == ThemeMode.dark;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    AppTheme.currentIsDark = _themeMode == ThemeMode.dark;
    notifyListeners();
  }

  void saveSettings({
    required double similarityThreshold,
    required String crawlFrequency,
    required bool notifyCritical,
    required bool notifyHigh,
  }) {
    _similarityThreshold = similarityThreshold;
    _crawlFrequency = crawlFrequency;
    _notifyCritical = notifyCritical;
    _notifyHigh = notifyHigh;
    notifyListeners();
  }

  void resetSettingsToDefaults() {
    _similarityThreshold = 80.0;
    _crawlFrequency = 'Every 1 Hour';
    _notifyCritical = true;
    _notifyHigh = true;
    _backendUrl = 'http://localhost:8000';
    _useDemoMode = true;
    _apiService.updateConfig(baseUrl: _backendUrl, useDemoMode: _useDemoMode);
    _connectionStatus = ApiConnectionStatus.demoMode;
    notifyListeners();
  }

  void setNavIndex(int index) {
    _currentNavIndex = index;
    notifyListeners();
  }

  void selectThreatForInvestigation(ThreatItem threat) {
    _selectedThreat = threat;
    _currentNavIndex = 4; // Threat Investigation screen index
    notifyListeners();
  }

  // --- BRAND PROFILE ACTIONS ---
  Future<void> updateBrandProfile(BrandProfile updated) async {
    _isLoading = true;
    notifyListeners();

    _brandProfile = updated;
    await _apiService.updateBrandProfile(updated);

    _isLoading = false;
    notifyListeners();
  }

  // --- THREAT ACTIONS ---
  Future<void> updateThreatStatus(String threatId, ReviewStatus newStatus) async {
    final index = _threats.indexWhere((t) => t.id == threatId);
    if (index != -1) {
      final updated = _threats[index].copyWith(reviewStatus: newStatus);
      _threats[index] = updated;

      if (_selectedThreat?.id == threatId) {
        _selectedThreat = updated;
      }
      notifyListeners();
      await _apiService.updateThreatStatus(threatId, newStatus);
    }
  }

  Future<void> addInvestigationNote(String threatId, String noteText, {String author = 'SecOps Analyst'}) async {
    final index = _threats.indexWhere((t) => t.id == threatId);
    if (index != -1) {
      final newNote = InvestigationNote(
        id: 'note-${DateTime.now().millisecondsSinceEpoch}',
        author: author,
        text: noteText,
        createdAt: DateTime.now(),
      );
      final updatedNotes = List<InvestigationNote>.from(_threats[index].notes)..insert(0, newNote);
      final updated = _threats[index].copyWith(notes: updatedNotes);
      _threats[index] = updated;

      if (_selectedThreat?.id == threatId) {
        _selectedThreat = updated;
      }
      notifyListeners();
      await _apiService.addInvestigationNote(threatId, noteText, author);
    }
  }

  // --- SCAN ACTIONS ---
  Future<void> triggerNewScan({String sourceType = 'All Sources'}) async {
    _isScanning = true;
    _scanProgressMessage = 'Initializing crawlers for $sourceType...';
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 700));
    _scanProgressMessage = 'Auditing active candidate profiles and package repositories...';
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 900));
    _scanProgressMessage = 'Running neural logo-matching & typo-squatting algorithms...';
    notifyListeners();

    final newRecord = await _apiService.triggerScan(sourceType: sourceType);
    _scanRecords.insert(0, newRecord);

    _isScanning = false;
    _scanProgressMessage = '';
    notifyListeners();
  }

  // --- CHAT ACTIONS ---
  void setChatMode(ChatMode mode) {
    _currentChatMode = mode;
    notifyListeners();
  }

  Future<void> sendChatMessage(String prompt) async {
    if (prompt.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
      sender: MessageSender.user,
      text: prompt.trim(),
      timestamp: DateTime.now(),
      mode: _currentChatMode,
    );

    _chatMessages.add(userMsg);
    _isChatThinking = true;
    notifyListeners();

    try {
      final aiResponse = await _chatService.sendMessage(
        userPrompt: prompt,
        mode: _currentChatMode,
        conversationHistory: _chatMessages,
      );
      _chatMessages.add(aiResponse);
    } catch (e) {
      _chatMessages.add(
        ChatMessage(
          id: 'err-${DateTime.now().millisecondsSinceEpoch}',
          sender: MessageSender.assistant,
          text: 'Unable to communicate with threat reasoning engine: $e',
          timestamp: DateTime.now(),
          mode: _currentChatMode,
        ),
      );
    } finally {
      _isChatThinking = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _chatMessages = _chatService.getInitialMessages();
    notifyListeners();
  }

  // --- SETTINGS ACTIONS ---
  void updateBackendUrl(String url) {
    _backendUrl = url;
    _apiService.updateConfig(baseUrl: _backendUrl, useDemoMode: _useDemoMode);
    notifyListeners();
  }

  void toggleDemoMode(bool value) {
    _useDemoMode = value;
    _apiService.updateConfig(baseUrl: _backendUrl, useDemoMode: _useDemoMode);
    _connectionStatus = value ? ApiConnectionStatus.demoMode : ApiConnectionStatus.disconnected;
    notifyListeners();
  }

  Future<void> testBackendConnection() async {
    _connectionStatus = ApiConnectionStatus.checking;
    notifyListeners();

    final isOk = await _apiService.checkHealth();
    _connectionStatus = isOk ? ApiConnectionStatus.connected : ApiConnectionStatus.disconnected;
    notifyListeners();
  }

  Future<void> refreshAllData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final p = await _apiService.fetchBrandProfile();
      final t = await _apiService.fetchThreats();
      final s = await _apiService.fetchScanHistory();
      final r = await _apiService.fetchReportSummary();

      _brandProfile = p;
      _threats = t;
      _scanRecords = s;
      _reportSummary = r;
      if (_threats.isNotEmpty && _selectedThreat == null) {
        _selectedThreat = _threats.first;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
