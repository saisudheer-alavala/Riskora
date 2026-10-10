enum ThreatType {
  socialMedia,
  appStore,
  domain,
  darkWeb,
}

enum ReviewStatus {
  newDetected,
  inReview,
  confirmedThreat,
  falsePositive,
  takedownRequested,
  resolved,
}

extension ReviewStatusExtension on ReviewStatus {
  String get label {
    switch (this) {
      case ReviewStatus.newDetected:
        return 'New Detection';
      case ReviewStatus.inReview:
        return 'Under Review';
      case ReviewStatus.confirmedThreat:
        return 'Confirmed Threat';
      case ReviewStatus.falsePositive:
        return 'False Positive';
      case ReviewStatus.takedownRequested:
        return 'Takedown Initiated';
      case ReviewStatus.resolved:
        return 'Resolved / Mitigated';
    }
  }
}

class InvestigationNote {
  final String id;
  final String author;
  final String text;
  final DateTime createdAt;

  InvestigationNote({
    required this.id,
    required this.author,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'author': author,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
      };

  factory InvestigationNote.fromJson(Map<String, dynamic> json) => InvestigationNote(
        id: json['id'] ?? '',
        author: json['author'] ?? 'SecOps Analyst',
        text: json['text'] ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
            : DateTime.now(),
      );
}

class RiskBreakdown {
  final double nameSimilarityScore; // 0..100
  final double logoVisualMatchScore; // 0..100
  final double suspiciousKeywordsScore; // 0..100
  final double domainOrAccountAgeScore; // 0..100
  final double permissionMalwareScore; // 0..100 for apps, 0 for profiles

  const RiskBreakdown({
    this.nameSimilarityScore = 0.0,
    this.logoVisualMatchScore = 0.0,
    this.suspiciousKeywordsScore = 0.0,
    this.domainOrAccountAgeScore = 0.0,
    this.permissionMalwareScore = 0.0,
  });

  Map<String, dynamic> toJson() => {
        'nameSimilarityScore': nameSimilarityScore,
        'logoVisualMatchScore': logoVisualMatchScore,
        'suspiciousKeywordsScore': suspiciousKeywordsScore,
        'domainOrAccountAgeScore': domainOrAccountAgeScore,
        'permissionMalwareScore': permissionMalwareScore,
      };

  factory RiskBreakdown.fromJson(Map<String, dynamic> json) => RiskBreakdown(
        nameSimilarityScore: (json['nameSimilarityScore'] as num?)?.toDouble() ?? 0.0,
        logoVisualMatchScore: (json['logoVisualMatchScore'] as num?)?.toDouble() ?? 0.0,
        suspiciousKeywordsScore: (json['suspiciousKeywordsScore'] as num?)?.toDouble() ?? 0.0,
        domainOrAccountAgeScore: (json['domainOrAccountAgeScore'] as num?)?.toDouble() ?? 0.0,
        permissionMalwareScore: (json['permissionMalwareScore'] as num?)?.toDouble() ?? 0.0,
      );
}

class ThreatItem {
  final String id;
  final String title;
  final ThreatType type;
  final String platform; // "Twitter/X", "Instagram", "Google Play Store", etc.
  final String identifier; // handle e.g. "@riskora_official_support" or package e.g. "com.riskora.wallet.fake"
  final String url;
  final String avatarOrIcon;
  final double nameSimilarity; // 0-100%
  final double logoSimilarity; // 0-100%
  final int riskScore; // 0-100
  final List<String> detectionReasons;
  final List<String> indicators;
  final String description;
  final String developerOrAuthor;
  final ReviewStatus reviewStatus;
  final DateTime detectedAt;
  final RiskBreakdown breakdown;
  final List<InvestigationNote> notes;
  final Map<String, dynamic> comparisonMetadata;

  ThreatItem({
    required this.id,
    required this.title,
    required this.type,
    required this.platform,
    required this.identifier,
    required this.url,
    required this.avatarOrIcon,
    required this.nameSimilarity,
    required this.logoSimilarity,
    required this.riskScore,
    required this.detectionReasons,
    required this.indicators,
    required this.description,
    required this.developerOrAuthor,
    required this.reviewStatus,
    required this.detectedAt,
    this.breakdown = const RiskBreakdown(),
    List<InvestigationNote>? notes,
    Map<String, dynamic>? comparisonMetadata,
  })  : notes = notes ?? [],
        comparisonMetadata = comparisonMetadata ?? {};

  String get riskCategory {
    if (riskScore >= 80) return 'Critical';
    if (riskScore >= 60) return 'High';
    if (riskScore >= 40) return 'Medium';
    return 'Low';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type.name,
        'platform': platform,
        'identifier': identifier,
        'url': url,
        'avatarOrIcon': avatarOrIcon,
        'nameSimilarity': nameSimilarity,
        'logoSimilarity': logoSimilarity,
        'riskScore': riskScore,
        'detectionReasons': detectionReasons,
        'indicators': indicators,
        'description': description,
        'developerOrAuthor': developerOrAuthor,
        'reviewStatus': reviewStatus.name,
        'detectedAt': detectedAt.toIso8601String(),
        'breakdown': breakdown.toJson(),
        'notes': notes.map((n) => n.toJson()).toList(),
        'comparisonMetadata': comparisonMetadata,
      };

  factory ThreatItem.fromJson(Map<String, dynamic> json) => ThreatItem(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        type: ThreatType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => ThreatType.socialMedia,
        ),
        platform: json['platform'] ?? '',
        identifier: json['identifier'] ?? '',
        url: json['url'] ?? '',
        avatarOrIcon: json['avatarOrIcon'] ?? '',
        nameSimilarity: (json['nameSimilarity'] as num?)?.toDouble() ?? 0.0,
        logoSimilarity: (json['logoSimilarity'] as num?)?.toDouble() ?? 0.0,
        riskScore: json['riskScore'] ?? 50,
        detectionReasons: (json['detectionReasons'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        indicators: (json['indicators'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        description: json['description'] ?? '',
        developerOrAuthor: json['developerOrAuthor'] ?? '',
        reviewStatus: ReviewStatus.values.firstWhere(
          (s) => s.name == json['reviewStatus'],
          orElse: () => ReviewStatus.newDetected,
        ),
        detectedAt: json['detectedAt'] != null
            ? DateTime.tryParse(json['detectedAt']) ?? DateTime.now()
            : DateTime.now(),
        breakdown: json['breakdown'] != null
            ? RiskBreakdown.fromJson(json['breakdown'])
            : const RiskBreakdown(),
        notes: (json['notes'] as List<dynamic>?)
                ?.map((n) => InvestigationNote.fromJson(n as Map<String, dynamic>))
                .toList() ??
            [],
        comparisonMetadata: json['comparisonMetadata'] as Map<String, dynamic>? ?? {},
      );

  ThreatItem copyWith({
    String? id,
    String? title,
    ThreatType? type,
    String? platform,
    String? identifier,
    String? url,
    String? avatarOrIcon,
    double? nameSimilarity,
    double? logoSimilarity,
    int? riskScore,
    List<String>? detectionReasons,
    List<String>? indicators,
    String? description,
    String? developerOrAuthor,
    ReviewStatus? reviewStatus,
    DateTime? detectedAt,
    RiskBreakdown? breakdown,
    List<InvestigationNote>? notes,
    Map<String, dynamic>? comparisonMetadata,
  }) {
    return ThreatItem(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      platform: platform ?? this.platform,
      identifier: identifier ?? this.identifier,
      url: url ?? this.url,
      avatarOrIcon: avatarOrIcon ?? this.avatarOrIcon,
      nameSimilarity: nameSimilarity ?? this.nameSimilarity,
      logoSimilarity: logoSimilarity ?? this.logoSimilarity,
      riskScore: riskScore ?? this.riskScore,
      detectionReasons: detectionReasons ?? List.from(this.detectionReasons),
      indicators: indicators ?? List.from(this.indicators),
      description: description ?? this.description,
      developerOrAuthor: developerOrAuthor ?? this.developerOrAuthor,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      detectedAt: detectedAt ?? this.detectedAt,
      breakdown: breakdown ?? this.breakdown,
      notes: notes ?? List.from(this.notes),
      comparisonMetadata: comparisonMetadata ?? Map.from(this.comparisonMetadata),
    );
  }
}
