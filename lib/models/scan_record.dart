enum ScanStatus {
  completed,
  inProgress,
  failed,
  scheduled,
}

extension ScanStatusExtension on ScanStatus {
  String get label {
    switch (this) {
      case ScanStatus.completed:
        return 'Completed';
      case ScanStatus.inProgress:
        return 'In Progress';
      case ScanStatus.failed:
        return 'Failed';
      case ScanStatus.scheduled:
        return 'Scheduled';
    }
  }
}

class ScanRecord {
  final String id;
  final DateTime scanDate;
  final String sourceType; // "All Sources", "Social Media", "App Stores", "Domain Registries", "Dark Web"
  final ScanStatus status;
  final int candidatesChecked;
  final int detectionsCount;
  final int highRiskCount;
  final int durationSeconds;
  final List<String> errors;

  ScanRecord({
    required this.id,
    required this.scanDate,
    required this.sourceType,
    required this.status,
    required this.candidatesChecked,
    required this.detectionsCount,
    required this.highRiskCount,
    required this.durationSeconds,
    required this.errors,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'scanDate': scanDate.toIso8601String(),
        'sourceType': sourceType,
        'status': status.name,
        'candidatesChecked': candidatesChecked,
        'detectionsCount': detectionsCount,
        'highRiskCount': highRiskCount,
        'durationSeconds': durationSeconds,
        'errors': errors,
      };

  factory ScanRecord.fromJson(Map<String, dynamic> json) => ScanRecord(
        id: json['id'] ?? '',
        scanDate: json['scanDate'] != null
            ? DateTime.tryParse(json['scanDate']) ?? DateTime.now()
            : DateTime.now(),
        sourceType: json['sourceType'] ?? 'All Sources',
        status: ScanStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => ScanStatus.completed,
        ),
        candidatesChecked: json['candidatesChecked'] ?? 0,
        detectionsCount: json['detectionsCount'] ?? 0,
        highRiskCount: json['highRiskCount'] ?? 0,
        durationSeconds: json['durationSeconds'] ?? 0,
        errors: (json['errors'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );
}
