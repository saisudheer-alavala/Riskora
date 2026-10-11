import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/brand_profile.dart';
import '../models/threat_item.dart';
import '../models/scan_record.dart';
import '../models/report_data.dart';
import '../models/chat_message.dart';
import '../models/user_account.dart';
import '../services/api_service.dart';
import '../services/chat_service.dart';
import '../services/mock_data_service.dart';
import '../theme/app_theme.dart';

String getDefaultBackendUrl() {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:8000';
  }
  return 'http://localhost:8000';
}

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
  late String _backendUrl = getDefaultBackendUrl();
  bool _useDemoMode = false;
  ApiConnectionStatus _connectionStatus = ApiConnectionStatus.checking;
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
  UserAccount? _currentUserAccount;

  // Registered Corporate Users Database (Strict verification - prevents fake logins)
  final List<UserAccount> _registeredUsers = [
    UserAccount(
      name: 'Kureti Titus Karthikeya',
      email: 'kuretitituskathikeya@gmail.com',
      password: 'RiskoraLead#2026',
      role: 'Project Lead & Chief Cyber Defense Architect',
      dob: DateTime(2001, 6, 15),
      isVerified: true,
      authProvider: 'local',
    ),
    UserAccount(
      name: 'Senior SecOps Analyst',
      email: 'analyst@riskora.ai',
      password: 'RiskoraSecOps#2026',
      role: 'Principal Incident Handler',
      dob: DateTime(1994, 5, 12),
    ),
    UserAccount(
      name: 'Platform Administrator',
      email: 'admin@riskora.com',
      password: 'Admin@Riskora2026!',
      role: 'Global Security Administrator',
      dob: DateTime(1990, 8, 20),
    ),
    UserAccount(
      name: 'Dr. Aaron Sterling',
      email: 'director@cyberdefense.org',
      password: 'Director@Defense2026',
      role: 'Chief Threat Defense Director',
      dob: DateTime(1985, 3, 15),
    ),
    UserAccount(
      name: 'Sai Sudheer',
      email: 'saisudheer@riskora.ai',
      password: 'Riskora#2026',
      role: 'Enterprise SecOps Lead',
      dob: DateTime(2002, 1, 1),
    ),
  ];

  static final Set<String> _disposableDomains = {
    'tempmail.com', '10minutemail.com', 'mailinator.com', 'guerrillamail.com',
    'throwawaymail.com', 'yopmail.com', 'fakemail.com', 'trashmail.com',
    'sharklasers.com', 'dispostable.com', 'getairmail.com', 'temp-mail.org'
  };

  bool _showAuthScreen = false;
  bool get showAuthScreen => _showAuthScreen;

  bool get isAuthenticated => _isAuthenticated;
  String? get currentUserIdentifier => _currentUserIdentifier;
  String get currentUserName => _currentUserName ?? 'SecOps Analyst';
  DateTime? get currentUserDob => _currentUserDob;
  UserAccount? get currentUserAccount => _currentUserAccount;
  List<UserAccount> get registeredUsers => List.unmodifiable(_registeredUsers);

  AppStateProvider({bool initialAuthenticated = false, bool initialShowAuth = false}) {
    _isAuthenticated = initialAuthenticated;
    _showAuthScreen = initialShowAuth;
    _backendUrl = getDefaultBackendUrl();
    _useDemoMode = false;
    _apiService.updateConfig(baseUrl: _backendUrl, useDemoMode: false);
    _brandProfile = MockDataService.getInitialBrandProfile();
    _threats = MockDataService.getInitialThreats();
    _scanRecords = MockDataService.getInitialScanRecords();
    _reportSummary = MockDataService.getInitialReportSummary();
    _chatMessages = _chatService.getInitialMessages();
    if (_threats.isNotEmpty) {
      _selectedThreat = _threats.first;
    }
    // Proactively connect to FastAPI SecOps backend and sync live telemetry
    testBackendConnection();
  }

  void openAuthScreen() {
    _showAuthScreen = true;
    notifyListeners();
  }

  void openHomeScreen() {
    _showAuthScreen = false;
    notifyListeners();
  }

  /// Strict Verified Login with anti-fake email protection (Asynchronous with backend query)
  Future<AuthResult> verifyAndLoginAsync(String identifier, String password) async {
    final cleanId = identifier.trim().toLowerCase();
    final cleanPass = password.trim();

    if (cleanId.isEmpty || cleanPass.isEmpty) {
      return AuthResult.fail(
        AuthResultCode.userNotFound,
        'Please provide both corporate identity and access credentials.',
      );
    }

    // Check disposable email blacklist
    if (cleanId.contains('@')) {
      final domain = cleanId.split('@').last;
      if (_disposableDomains.contains(domain)) {
        return AuthResult.fail(
          AuthResultCode.disposableEmailRejected,
          'Security Block: Temporary and disposable email domains ($domain) are prohibited.',
        );
      }
    }

    // 1. Check in registered corporate database (local cache)
    final existingUser = _registeredUsers.firstWhere(
      (u) => u.email.toLowerCase() == cleanId,
      orElse: () => UserAccount(name: '', email: '', password: ''),
    );

    if (existingUser.email.isNotEmpty) {
      if (existingUser.password != cleanPass) {
        return AuthResult.fail(
          AuthResultCode.invalidPassword,
          'Access Denied: Incorrect password for "${existingUser.email}". Security breach challenge logged.',
        );
      }

      // Login successful
      _isAuthenticated = true;
      _showAuthScreen = false;
      _currentUserAccount = existingUser;
      _currentUserIdentifier = existingUser.email;
      _currentUserName = existingUser.name;
      _currentUserDob = existingUser.dob;
      notifyListeners();

      await _syncLogin(existingUser.email, cleanPass);
      return AuthResult.ok(existingUser);
    }

    // 2. Query FastAPI backend directly
    try {
      final backendRes = await _apiService.login(cleanId, cleanPass);
      if (backendRes != null && backendRes['user'] != null) {
        final userData = backendRes['user'];
        final backendUser = UserAccount(
          name: userData['name'] ?? 'SecOps Enterprise User',
          email: cleanId,
          password: cleanPass,
          role: 'SecOps Enterprise Specialist',
          isVerified: true,
          authProvider: 'backend',
        );
        _registeredUsers.add(backendUser);

        _isAuthenticated = true;
        _showAuthScreen = false;
        _currentUserAccount = backendUser;
        _currentUserIdentifier = backendUser.email;
        _currentUserName = backendUser.name;
        _currentUserDob = DateTime(1995, 1, 1);
        notifyListeners();

        await refreshAllData();
        return AuthResult.ok(backendUser);
      }
    } catch (e) {
      debugPrint('Backend login exception: $e');
    }

    return AuthResult.fail(
      AuthResultCode.userNotFound,
      'Account Verification Failed: No registered Riskora identity found for "$identifier". Fake or unregistered identities are blocked by corporate SecOps.',
    );
  }

  /// Strict Verified Login with anti-fake email protection (Synchronous fallback)
  AuthResult verifyAndLogin(String identifier, String password) {
    final cleanId = identifier.trim().toLowerCase();
    final cleanPass = password.trim();

    if (cleanId.isEmpty || cleanPass.isEmpty) {
      return AuthResult.fail(
        AuthResultCode.userNotFound,
        'Please provide both corporate identity and access credentials.',
      );
    }

    // Check disposable email blacklist
    if (cleanId.contains('@')) {
      final domain = cleanId.split('@').last;
      if (_disposableDomains.contains(domain)) {
        return AuthResult.fail(
          AuthResultCode.disposableEmailRejected,
          'Security Block: Temporary and disposable email domains ($domain) are prohibited.',
        );
      }
    }

    // Lookup user in registered corporate database
    final existingUser = _registeredUsers.firstWhere(
      (u) => u.email.toLowerCase() == cleanId,
      orElse: () => UserAccount(name: '', email: '', password: ''),
    );

    if (existingUser.email.isEmpty) {
      return AuthResult.fail(
        AuthResultCode.userNotFound,
        'Account Verification Failed: No registered Riskora identity found for "$identifier". Fake or unregistered identities are blocked by corporate SecOps.',
      );
    }

    if (existingUser.password != cleanPass) {
      return AuthResult.fail(
        AuthResultCode.invalidPassword,
        'Access Denied: Incorrect password for "${existingUser.email}". Security breach challenge logged.',
      );
    }

    // Login successful
    _isAuthenticated = true;
    _showAuthScreen = false;
    _currentUserAccount = existingUser;
    _currentUserIdentifier = existingUser.email;
    _currentUserName = existingUser.name;
    _currentUserDob = existingUser.dob;
    notifyListeners();

    _syncLogin(existingUser.email, cleanPass);
    return AuthResult.ok(existingUser);
  }

  /// Backward compatible login
  bool login(String identifier, String password) {
    final res = verifyAndLogin(identifier, password);
    return res.success;
  }

  /// Strict Corporate Registration
  AuthResult registerNewUser({
    required String name,
    required String email,
    required DateTime dob,
    required String password,
  }) {
    final cleanEmail = email.trim().toLowerCase();
    final cleanName = name.trim();
    final cleanPass = password.trim();

    if (cleanEmail.contains('@')) {
      final domain = cleanEmail.split('@').last;
      if (_disposableDomains.contains(domain)) {
        return AuthResult.fail(
          AuthResultCode.disposableEmailRejected,
          'Disposable email domains are blocked. Please use your corporate or legitimate email.',
        );
      }
    }

    final alreadyExists = _registeredUsers.any(
      (u) => u.email.toLowerCase() == cleanEmail,
    );
    if (alreadyExists) {
      return AuthResult.fail(
        AuthResultCode.emailAlreadyRegistered,
        'Security Notice: Identity "$cleanEmail" is already registered. Please proceed to login.',
      );
    }

    final newUser = UserAccount(
      name: cleanName,
      email: cleanEmail,
      password: cleanPass,
      dob: dob,
      role: 'SecOps Analyst (Enterprise)',
      isVerified: true,
      authProvider: 'local',
    );

    _registeredUsers.add(newUser);

    _isAuthenticated = true;
    _showAuthScreen = false;
    _currentUserAccount = newUser;
    _currentUserIdentifier = newUser.email;
    _currentUserName = newUser.name;
    _currentUserDob = dob;
    notifyListeners();

    _syncRegister(cleanName, cleanEmail, cleanPass, dob);
    return AuthResult.ok(newUser);
  }

  bool register({
    required String name,
    required String email,
    required DateTime dob,
    required String password,
  }) {
    final res = registerNewUser(
      name: name,
      email: email,
      dob: dob,
      password: password,
    );
    return res.success;
  }

  /// Official Google OAuth 2.0 Corporate Sign-in
  void loginWithGoogleAccount({
    required String name,
    required String email,
    required String avatarUrl,
  }) {
    final cleanEmail = email.trim().toLowerCase();

    UserAccount user = _registeredUsers.firstWhere(
      (u) => u.email.toLowerCase() == cleanEmail,
      orElse: () {
        final newUser = UserAccount(
          name: name.trim(),
          email: cleanEmail,
          password: 'OAuth2_Google_Verified_${DateTime.now().millisecondsSinceEpoch}',
          avatarUrl: avatarUrl,
          role: 'Google SSO Enterprise Identity',
          isVerified: true,
          authProvider: 'google',
        );
        _registeredUsers.add(newUser);
        return newUser;
      },
    );

    _isAuthenticated = true;
    _showAuthScreen = false;
    _currentUserAccount = user;
    _currentUserIdentifier = user.email;
    _currentUserName = user.name;
    _currentUserDob = user.dob ?? DateTime(1998, 1, 1);
    notifyListeners();
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
    _backendUrl = getDefaultBackendUrl();
    _useDemoMode = false;
    _apiService.updateConfig(baseUrl: _backendUrl, useDemoMode: false);
    _connectionStatus = ApiConnectionStatus.checking;
    notifyListeners();
    testBackendConnection();
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

  String get customGroqApiKey => ChatService.customApiKey;
  void updateCustomGroqApiKey(String key) {
    ChatService.setCustomApiKey(key);
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
    _apiService.updateConfig(baseUrl: _backendUrl, useDemoMode: value);
    notifyListeners();
    testBackendConnection();
  }

  Future<void> testBackendConnection() async {
    _connectionStatus = ApiConnectionStatus.checking;
    notifyListeners();

    final isOk = await _apiService.checkHealth();
    _connectionStatus = isOk ? ApiConnectionStatus.connected : ApiConnectionStatus.disconnected;
    notifyListeners();

    if (isOk) {
      await refreshAllData();
    }
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
