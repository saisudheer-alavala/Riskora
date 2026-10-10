class ReportSummary {
  final DateTime generatedAt;
  final String dateRange;
  final int totalScansRun;
  final int totalDetections;
  final int confirmedThreats;
  final int falsePositives;
  final int takedownsInitiated;
  final int activeMonitoringAssets;
  final double averageDetectionAccuracy;
  final Map<String, int> riskDistribution; // Critical, High, Medium, Low
  final Map<String, int> platformBreakdown; // Twitter, Instagram, Play Store, etc.
  final List<String> executiveHighlights;

  const ReportSummary({
    required this.generatedAt,
    required this.dateRange,
    required this.totalScansRun,
    required this.totalDetections,
    required this.confirmedThreats,
    required this.falsePositives,
    required this.takedownsInitiated,
    required this.activeMonitoringAssets,
    required this.averageDetectionAccuracy,
    required this.riskDistribution,
    required this.platformBreakdown,
    required this.executiveHighlights,
  });

  Map<String, dynamic> toJson() => {
        'generatedAt': generatedAt.toIso8601String(),
        'dateRange': dateRange,
        'totalScansRun': totalScansRun,
        'totalDetections': totalDetections,
        'confirmedThreats': confirmedThreats,
        'falsePositives': falsePositives,
        'takedownsInitiated': takedownsInitiated,
        'activeMonitoringAssets': activeMonitoringAssets,
        'averageDetectionAccuracy': averageDetectionAccuracy,
        'riskDistribution': riskDistribution,
        'platformBreakdown': platformBreakdown,
        'executiveHighlights': executiveHighlights,
      };

  factory ReportSummary.fromJson(Map<String, dynamic> json) => ReportSummary(
        generatedAt: json['generatedAt'] != null
            ? DateTime.tryParse(json['generatedAt']) ?? DateTime.now()
            : DateTime.now(),
        dateRange: json['dateRange'] ?? 'Last 30 Days',
        totalScansRun: json['totalScansRun'] ?? 0,
        totalDetections: json['totalDetections'] ?? 0,
        confirmedThreats: json['confirmedThreats'] ?? 0,
        falsePositives: json['falsePositives'] ?? 0,
        takedownsInitiated: json['takedownsInitiated'] ?? 0,
        activeMonitoringAssets: json['activeMonitoringAssets'] ?? 0,
        averageDetectionAccuracy: (json['averageDetectionAccuracy'] as num?)?.toDouble() ?? 94.6,
        riskDistribution: (json['riskDistribution'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, (v as num).toInt())) ??
            {
              'Critical': 14,
              'High': 28,
              'Medium': 45,
              'Low': 19,
            },
        platformBreakdown: (json['platformBreakdown'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, (v as num).toInt())) ??
            {
              'Twitter / X': 38,
              'Google Play': 29,
              'Instagram': 21,
              'Telegram': 12,
              'App Store': 6,
            },
        executiveHighlights: (json['executiveHighlights'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );
}
