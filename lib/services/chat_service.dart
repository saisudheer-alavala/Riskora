import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import 'api_service.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final ApiService _apiService = ApiService();

  static const String _defaultGroqApiKey =
      String.fromEnvironment('GROQ_API_KEY', defaultValue: '');
  static String customApiKey = '';
  static String get effectiveApiKey =>
      customApiKey.isNotEmpty ? customApiKey : _defaultGroqApiKey;
  static const String _groqModel = 'openai/gpt-oss-120b';
  static const String _fallbackGroqModel = 'openai/gpt-oss-20b';

  static void setCustomApiKey(String key) {
    customApiKey = key.trim();
  }

  Future<ChatMessage> sendMessage({
    required String userPrompt,
    required ChatMode mode,
    List<ChatMessage> conversationHistory = const [],
  }) async {
    // 1. Always attempt FastAPI backend chat endpoint first
    try {
      final response = await http
          .post(
            Uri.parse('${_apiService.baseUrl}/api/chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'prompt': userPrompt,
              'mode': mode.name,
              'history': conversationHistory
                  .map((m) => {'sender': m.sender.name, 'text': m.text})
                  .toList(),
            }),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return ChatMessage.fromJson(data);
      }
    } catch (e) {
      debugPrint('Backend chat error, trying direct Groq AI: $e');
    }

    // 2. Call Groq AI Assistant directly using Groq API Key if configured
    if (effectiveApiKey.isNotEmpty) {
      try {
        final groqResponse = await _sendGroqMessage(
          userPrompt: userPrompt,
          mode: mode,
          conversationHistory: conversationHistory,
        );
        if (groqResponse != null) {
          return groqResponse;
        }
      } catch (e) {
        debugPrint('Groq AI direct error: $e');
      }
    }

    // 3. Fallback to local heuristic intelligence if offline or network error
    await Future.delayed(const Duration(milliseconds: 600));
    final normalized = userPrompt.trim().toLowerCase();
    return _generateIntelligentResponse(userPrompt, normalized, mode);
  }

  Future<ChatMessage?> _sendGroqMessage({
    required String userPrompt,
    required ChatMode mode,
    List<ChatMessage> conversationHistory = const [],
  }) async {
    final systemPrompt = _getSystemPromptForMode(mode);
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
    ];

    // Append recent conversation context (last 6 messages)
    final recentHistory = conversationHistory.length > 6
        ? conversationHistory.sublist(conversationHistory.length - 6)
        : conversationHistory;

    for (final m in recentHistory) {
      messages.add({
        'role': m.sender == MessageSender.user ? 'user' : 'assistant',
        'content': m.text,
      });
    }

    messages.add({'role': 'user', 'content': userPrompt});

    for (final model in [_groqModel, _fallbackGroqModel]) {
      try {
        final response = await http
            .post(
              Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
              headers: {
                'Authorization': 'Bearer $effectiveApiKey',
                'Content-Type': 'application/json',
                'User-Agent': 'RISKORA-SecOps/1.0',
              },
              body: jsonEncode({
                'model': model,
                'messages': messages,
                'temperature': 0.6,
                'max_tokens': 1024,
              }),
            )
            .timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final json = jsonDecode(utf8.decode(response.bodyBytes));
          final choices = json['choices'] as List?;
          if (choices != null && choices.isNotEmpty) {
            final content = choices[0]['message']?['content'] as String?;
            if (content != null && content.trim().isNotEmpty) {
              final now = DateTime.now();
              return ChatMessage(
                id: 'groq-${now.millisecondsSinceEpoch}',
                sender: MessageSender.assistant,
                mode: mode,
                timestamp: now,
                text: content.trim(),
              );
            }
          }
        } else {
          debugPrint('Groq API error on $model: ${response.statusCode} -> ${response.body}');
        }
      } catch (e) {
        debugPrint('Groq direct API exception on $model: $e');
      }
    }
    return null;
  }

  String _getSystemPromptForMode(ChatMode mode) {
    switch (mode) {
      case ChatMode.brandAssistant:
        return 'You are RISKORA Brand Intelligence Assistant, an elite AI assistant for enterprise brand protection and digital perimeter defense. You assist security analysts in monitoring trademarks, official social handles, rogue domains, and brand impersonators. Format answers clearly using Markdown with actionable steps.';
      case ChatMode.riskAdvisor:
        return 'You are RISKORA Threat Intelligence & Risk Advisor. You analyze cyber threat telemetry, compute threat severity ratings, evaluate phishing vectors and logo squatted assets, and recommend immediate risk mitigation protocols. Format responses in Markdown.';
      case ChatMode.customerSupport:
        return 'You are RISKORA SecOps Support Assistant. You provide clear, step-by-step guidance on operating the RISKORA SecOps platform, executing crawler scans, generating compliance takedown notices, and configuring API telemetry. Format responses in Markdown.';
    }
  }

  ChatMessage _generateIntelligentResponse(
      String originalPrompt, String prompt, ChatMode mode) {
    final now = DateTime.now();
    final messageId = 'ai-${now.millisecondsSinceEpoch}';

    // 1. What brands are registered?
    if (prompt.contains('what brands are registered') ||
        prompt.contains('registered brand') ||
        prompt.contains('brand list')) {
      return ChatMessage(
        id: messageId,
        sender: MessageSender.assistant,
        mode: mode,
        timestamp: now,
        text:
            '**Active Brand Monitored:** Riskora Technologies Inc.\n\n'
            'RISKORA is actively tracking brand assets across 5 social ecosystems, mobile app marketplaces, and DNS registrars. Below is the active brand identity card retrieved from your profile.',
        metadata: const ChatMetadata(
          type: 'brand_info',
          data: {
            'company': 'Riskora Technologies Inc.',
            'industry': 'Cybersecurity & Digital Risk Protection',
            'website': 'https://riskora.io',
            'verifiedHandles': ['@RiskoraSec (X)', '@riskora.official (IG)', 'company/riskora-protection (LinkedIn)'],
            'officialApps': ['Riskora Shield (com.riskora.security.shield)', 'Riskora SecOps Mobile (iOS)'],
            'identifiersCount': 6,
          },
        ),
      );
    }

    // 2. Why was this account flagged?
    if (prompt.contains('why was this account flagged') ||
        prompt.contains('flagged') ||
        prompt.contains('why flagged')) {
      return ChatMessage(
        id: messageId,
        sender: MessageSender.assistant,
        mode: mode,
        timestamp: now,
        text:
            '**Detection Forensics: Threat Analysis Report**\n\n'
            'Target account `@Riskora_Support_Help` was flagged automatically by RISKORA’s multi-modal inspection pipeline for high-probability credential phishing:\n\n'
            '• **Logo Vector Similarity: 91.2%** match against official Riskora corporate shield icon.\n'
            '• **Name Similarity Score: 94.5%** utilizing Levenshtein distance & phonetic squatted tokens.\n'
            '• **Malicious Pattern:** Account bio solicits 2FA recovery seeds and links to `riskora-support.tk` (known disposable registrar).\n'
            '• **Account Age:** Profile created less than 48 hours ago with zero organic interaction history.',
        metadata: const ChatMetadata(
          type: 'detection_evidence',
          data: {
            'threatId': 'TH-SOC-101',
            'account': '@Riskora_Support_Help',
            'riskScore': 95,
            'confidence': '98.4%',
            'indicators': ['Phishing Link', 'Visual Logo Match', 'Disposable Registrar', 'Zero Age'],
            'recommendedAction': 'Dispatch automated DMCA / Twitter abuse takedown notice.',
          },
        ),
      );
    }

    // 3. What does this risk score mean?
    if (prompt.contains('what does this risk score mean') ||
        prompt.contains('risk score') ||
        prompt.contains('score mean') ||
        prompt.contains('how is risk calculated')) {
      return ChatMessage(
        id: messageId,
        sender: MessageSender.assistant,
        mode: mode,
        timestamp: now,
        text:
            '**RISKORA Risk Scoring Formula & Classification**\n\n'
            'RISKORA aggregates multi-modal threat signals on a 0–100 weighted index:\n\n'
            'Formula: Score = (Wn × Sn) + (Wl × Sl) + (Wk × Sk) + (Wa × Sa) + (Wm × Sm)\n\n'
            '• **80 – 100 (Critical Risk):** Confirmed active threat or weaponized credential harvesting (e.g., trojans, spoofed login forms).\n'
            '• **60 – 79 (High Risk):** Strong impersonation indicators with high visual match and suspicious links.\n'
            '• **40 – 59 (Medium Risk):** Moderate similarity, unofficial community accounts, or ambiguous keyword usage.\n'
            '• **0 – 39 (Low Risk / False Positive):** Benign references, news commentary, or educational usage.',
        metadata: const ChatMetadata(
          type: 'risk_breakdown',
          data: {
            'weights': {
              'Name Similarity': '25%',
              'Logo Visual Match': '30%',
              'Suspicious Keywords': '20%',
              'Account / Domain Age': '15%',
              'Malware / Permission Vectors': '10%',
            }
          },
        ),
      );
    }

    // 4. How do I register a brand?
    if (prompt.contains('how do i register a brand') ||
        prompt.contains('register a brand') ||
        prompt.contains('register brand') ||
        prompt.contains('add brand')) {
      return ChatMessage(
        id: messageId,
        sender: MessageSender.assistant,
        mode: mode,
        timestamp: now,
        text:
            '**Brand Registration & Baseline Configuration Guide**\n\n'
            'To calibrate RISKORA for real-time protection of your organization:\n\n'
            '1. Navigate to the **Brand Profile** screen via the sidebar navigation.\n'
            '2. Input your **Official Company Name, Website Domain, and Primary Logo**.\n'
            '3. Add all **Authorized Social Media Handles** (X, Instagram, LinkedIn, Telegram, etc.).\n'
            '4. Provide your **Official Mobile App Package IDs** (e.g., `com.riskora.app`) to establish genuine baseline checksums.\n'
            '5. Save changes to trigger an automated baseline scan across all monitored channels.',
        metadata: const ChatMetadata(
          type: 'support_guide',
          data: {
            'targetScreen': 'Brand Profile',
            'stepsCount': 5,
            'tip': 'Adding trusted identifiers minimizes false positives by up to 87%.',
          },
        ),
      );
    }

    // 5. How do I report a suspicious app?
    if (prompt.contains('how do i report a suspicious app') ||
        prompt.contains('report a suspicious app') ||
        prompt.contains('report app') ||
        prompt.contains('suspicious app')) {
      return ChatMessage(
        id: messageId,
        sender: MessageSender.assistant,
        mode: mode,
        timestamp: now,
        text:
            '**Rogue Mobile Application Takedown Workflow**\n\n'
            'When RISKORA detects an unauthorized application masquerading as your brand:\n\n'
            '1. Open **App Store Monitoring** or click on the detected threat ID.\n'
            '2. Select **Threat Investigation** to view permission anomalies and package signature differences.\n'
            '3. Review the forensic indicators (e.g., `RECEIVE_SMS`, malicious C2 addresses).\n'
            '4. Click **"Initiate Takedown"** to automatically generate a pre-formatted legal DMCA / Trademark Infringement notice for Google Play or Apple App Store legal review.\n'
            '5. Track review progress under **Scan History** & **Reports**.',
        metadata: const ChatMetadata(
          type: 'support_guide',
          data: {
            'recommendedAction': 'Export Evidence Package & File Store Infringement Ticket',
            'legalReference': '17 U.S.C. § 512(c)(3) & Google Developer Policy Notice',
          },
        ),
      );
    }

    // Mode-specific fallback handling
    switch (mode) {
      case ChatMode.brandAssistant:
        return ChatMessage(
          id: messageId,
          sender: MessageSender.assistant,
          mode: mode,
          timestamp: now,
          text:
              '**Brand Intelligence Assistant Response**\n\n'
              'Regarding your query: *"$originalPrompt"*\n\n'
              'RISKORA is monitoring 4 official social channels, 2 mobile app stores, and your primary domain `riskora.io`. All telemetry is normal, with 2 active high-priority candidates currently pending SecOps analyst review. You can update verified handles at any time in the Brand Profile panel.',
        );

      case ChatMode.riskAdvisor:
        return ChatMessage(
          id: messageId,
          sender: MessageSender.assistant,
          mode: mode,
          timestamp: now,
          text:
              '**Cybersecurity Risk Advisory Analysis**\n\n'
              'Analysis of *"$originalPrompt"*\n\n'
              'Our autonomous threat assessment model flags potential risks based on impersonation velocity, visual logo cloning, domain age disparity, and behavioral signatures. If you are examining an anomalous detection, consider reviewing its permission breakdown in the Threat Investigation workbench or marking it as a False Positive to fine-tune future scans.',
        );

      case ChatMode.customerSupport:
        return ChatMessage(
          id: messageId,
          sender: MessageSender.assistant,
          mode: mode,
          timestamp: now,
          text:
              '**RISKORA Customer Support Desk**\n\n'
              'Thank you for reaching out regarding *"$originalPrompt"*\n\n'
              'Our platform supports end-to-end digital risk remediation. You can configure continuous scanning schedules under Settings, export PDF forensic summaries under Reports, or customize brand baseline parameters in Brand Profile. Let me know if you would like me to guide you through any specific workflow!',
        );
    }
  }

  List<String> getSuggestedQuestions() {
    return [
      'What brands are registered?',
      'Why was this account flagged?',
      'What does this risk score mean?',
      'How do I register a brand?',
      'How do I report a suspicious app?',
    ];
  }

  List<ChatMessage> getInitialMessages() {
    final now = DateTime.now();
    return [
      ChatMessage(
        id: 'msg-welcome-01',
        sender: MessageSender.assistant,
        mode: ChatMode.riskAdvisor,
        timestamp: now.subtract(const Duration(minutes: 5)),
        text:
            'Hello! I am **RISKORA AI**, your autonomous digital risk intelligence advisor.\n\n'
            'I can help you audit registered brand profiles, interpret detection algorithms, review forensic evidence for flagged accounts, and guide takedown operations. Select a suggested question below or ask me anything!',
      ),
    ];
  }
}
