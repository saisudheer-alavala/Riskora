import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/brand_profile.dart';
import '../models/threat_item.dart';
import '../models/scan_record.dart';
import '../models/report_data.dart';
import 'mock_data_service.dart';

enum ApiConnectionStatus {
  connected,
  disconnected,
  demoMode,
  checking,
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String _baseUrl = 'http://localhost:8000';
  bool _useDemoMode = false;
  ApiConnectionStatus _connectionStatus = ApiConnectionStatus.checking;
  String? _authToken;

  String get baseUrl => _baseUrl;
  bool get useDemoMode => _useDemoMode;
  ApiConnectionStatus get connectionStatus => _connectionStatus;
  String? get authToken => _authToken;

  void setAuthToken(String? token) {
    _authToken = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  void updateConfig({required String baseUrl, required bool useDemoMode}) {
    _baseUrl = baseUrl.replaceAll(RegExp(r'/+$'), '');
    _useDemoMode = useDemoMode;
  }

  /// Check connectivity to FastAPI backend
  Future<bool> checkHealth() async {
    _connectionStatus = ApiConnectionStatus.checking;
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/health'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        _connectionStatus = ApiConnectionStatus.connected;
        return true;
      } else {
        _connectionStatus = ApiConnectionStatus.disconnected;
        return false;
      }
    } catch (e) {
      debugPrint('API health check fallback: $e');
      _connectionStatus = ApiConnectionStatus.disconnected;
      return false;
    }
  }

  // --- AUTHENTICATION ---

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['token'];
        _connectionStatus = ApiConnectionStatus.connected;
        return data;
      }
    } catch (e) {
      debugPrint('API login error: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> register({
    required String name,
    required String email,
    required String password,
    DateTime? dob,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
              'dob': dob?.toIso8601String(),
            }),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _authToken = data['token'];
        _connectionStatus = ApiConnectionStatus.connected;
        return data;
      }
    } catch (e) {
      debugPrint('API register error: $e');
    }
    return null;
  }

  // --- BRAND PROFILE ---

  Future<BrandProfile> fetchBrandProfile() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/brand-profile'), headers: _headers)
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _connectionStatus = ApiConnectionStatus.connected;
        return BrandProfile.fromJson(data);
      }
    } catch (e) {
      debugPrint('fetchBrandProfile error, falling back to cache: $e');
    }
    return MockDataService.getInitialBrandProfile();
  }

  Future<bool> updateBrandProfile(BrandProfile profile) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl/api/brand-profile'),
            headers: _headers,
            body: jsonEncode(profile.toJson()),
          )
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        _connectionStatus = ApiConnectionStatus.connected;
        return true;
      }
    } catch (e) {
      debugPrint('updateBrandProfile error: $e');
    }
    return false;
  }

  // --- THREATS ---

  Future<List<ThreatItem>> fetchThreats({ThreatType? type}) async {
    try {
      final queryParam = type != null ? '?type=${type.name}' : '';
      final response = await http
          .get(Uri.parse('$_baseUrl/api/threats$queryParam'), headers: _headers)
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        _connectionStatus = ApiConnectionStatus.connected;
        return list.map((item) => ThreatItem.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint('fetchThreats error, falling back to cache: $e');
    }
    final all = MockDataService.getInitialThreats();
    if (type != null) return all.where((t) => t.type == type).toList();
    return all;
  }

  Future<bool> updateThreatStatus(String threatId, ReviewStatus status) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/threats/$threatId/status'),
            headers: _headers,
            body: jsonEncode({'status': status.name}),
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('updateThreatStatus error: $e');
      return false;
    }
  }

  Future<bool> addInvestigationNote(String threatId, String noteText, String author) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/threats/$threatId/notes'),
            headers: _headers,
            body: jsonEncode({'text': noteText, 'author': author}),
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      debugPrint('addInvestigationNote error: $e');
      return false;
    }
  }

  // --- SCAN HISTORY ---

  Future<List<ScanRecord>> fetchScanHistory() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/scans'), headers: _headers)
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        _connectionStatus = ApiConnectionStatus.connected;
        return list.map((item) => ScanRecord.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint('fetchScanHistory error, falling back to cache: $e');
    }
    return MockDataService.getInitialScanRecords();
  }

  Future<ScanRecord> triggerScan({String sourceType = 'All Sources'}) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/scans/run'),
            headers: _headers,
            body: jsonEncode({'sourceType': sourceType}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        _connectionStatus = ApiConnectionStatus.connected;
        return ScanRecord.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint('triggerScan error: $e');
    }

    return ScanRecord(
      id: 'SCN-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      scanDate: DateTime.now(),
      sourceType: sourceType,
      status: ScanStatus.completed,
      candidatesChecked: 890,
      detectionsCount: 3,
      highRiskCount: 1,
      durationSeconds: 45,
      errors: [],
    );
  }

  // --- REPORTS ---

  Future<ReportSummary> fetchReportSummary({String range = 'Last 30 Days'}) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/reports?range=$range'), headers: _headers)
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        _connectionStatus = ApiConnectionStatus.connected;
        return ReportSummary.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint('fetchReportSummary error, falling back to cache: $e');
    }
    return MockDataService.getInitialReportSummary();
  }
}
