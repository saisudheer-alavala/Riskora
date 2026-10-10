enum ChatMode {
  brandAssistant,
  riskAdvisor,
  customerSupport,
}

extension ChatModeExtension on ChatMode {
  String get displayName {
    switch (this) {
      case ChatMode.brandAssistant:
        return 'Brand Assistant';
      case ChatMode.riskAdvisor:
        return 'Risk Advisor';
      case ChatMode.customerSupport:
        return 'Customer Support';
    }
  }

  String get description {
    switch (this) {
      case ChatMode.brandAssistant:
        return 'Monitors official brand assets, handles & coverage';
      case ChatMode.riskAdvisor:
        return 'Explains threat logic, risks & remediation steps';
      case ChatMode.customerSupport:
        return 'Assists with takedown procedures & platform usage';
    }
  }
}

enum MessageSender {
  user,
  assistant,
  system,
}

class ChatMetadata {
  final String? type; // 'brand_info', 'detection_evidence', 'support_guide', 'action_recommendation'
  final Map<String, dynamic>? data;

  const ChatMetadata({this.type, this.data});

  Map<String, dynamic> toJson() => {
        'type': type,
        'data': data,
      };

  factory ChatMetadata.fromJson(Map<String, dynamic> json) => ChatMetadata(
        type: json['type'],
        data: json['data'] as Map<String, dynamic>?,
      );
}

class ChatMessage {
  final String id;
  final MessageSender sender;
  final String text;
  final DateTime timestamp;
  final ChatMode mode;
  final ChatMetadata? metadata;
  final bool isLoading;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    required this.mode,
    this.metadata,
    this.isLoading = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'sender': sender.name,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
        'mode': mode.name,
        'metadata': metadata?.toJson(),
        'isLoading': isLoading,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] ?? '',
        sender: MessageSender.values.firstWhere(
          (s) => s.name == json['sender'],
          orElse: () => MessageSender.assistant,
        ),
        text: json['text'] ?? '',
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
            : DateTime.now(),
        mode: ChatMode.values.firstWhere(
          (m) => m.name == json['mode'],
          orElse: () => ChatMode.brandAssistant,
        ),
        metadata: json['metadata'] != null ? ChatMetadata.fromJson(json['metadata']) : null,
        isLoading: json['isLoading'] ?? false,
      );

  ChatMessage copyWith({
    String? id,
    MessageSender? sender,
    String? text,
    DateTime? timestamp,
    ChatMode? mode,
    ChatMetadata? metadata,
    bool? isLoading,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      mode: mode ?? this.mode,
      metadata: metadata ?? this.metadata,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
