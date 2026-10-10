class SocialAccount {
  final String platform;
  final String handle;
  final String url;
  final bool isVerified;

  const SocialAccount({
    required this.platform,
    required this.handle,
    required this.url,
    this.isVerified = true,
  });

  Map<String, dynamic> toJson() => {
        'platform': platform,
        'handle': handle,
        'url': url,
        'isVerified': isVerified,
      };

  factory SocialAccount.fromJson(Map<String, dynamic> json) => SocialAccount(
        platform: json['platform'] ?? '',
        handle: json['handle'] ?? '',
        url: json['url'] ?? '',
        isVerified: json['isVerified'] ?? false,
      );

  SocialAccount copyWith({
    String? platform,
    String? handle,
    String? url,
    bool? isVerified,
  }) {
    return SocialAccount(
      platform: platform ?? this.platform,
      handle: handle ?? this.handle,
      url: url ?? this.url,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

class OfficialApp {
  final String name;
  final String platform; // "Android (Play Store)", "iOS (App Store)"
  final String packageId; // "com.riskora.app"
  final String publisher;
  final String storeUrl;

  const OfficialApp({
    required this.name,
    required this.platform,
    required this.packageId,
    required this.publisher,
    required this.storeUrl,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'platform': platform,
        'packageId': packageId,
        'publisher': publisher,
        'storeUrl': storeUrl,
      };

  factory OfficialApp.fromJson(Map<String, dynamic> json) => OfficialApp(
        name: json['name'] ?? '',
        platform: json['platform'] ?? '',
        packageId: json['packageId'] ?? '',
        publisher: json['publisher'] ?? '',
        storeUrl: json['storeUrl'] ?? '',
      );

  OfficialApp copyWith({
    String? name,
    String? platform,
    String? packageId,
    String? publisher,
    String? storeUrl,
  }) {
    return OfficialApp(
      name: name ?? this.name,
      platform: platform ?? this.platform,
      packageId: packageId ?? this.packageId,
      publisher: publisher ?? this.publisher,
      storeUrl: storeUrl ?? this.storeUrl,
    );
  }
}

class BrandProfile {
  final String id;
  final String companyName;
  final String industry;
  final String description;
  final String logoUrl;
  final String officialWebsite;
  final List<SocialAccount> socialAccounts;
  final List<OfficialApp> officialApps;
  final List<String> trustedIdentifiers;
  final DateTime lastUpdated;

  BrandProfile({
    required this.id,
    required this.companyName,
    required this.industry,
    required this.description,
    required this.logoUrl,
    required this.officialWebsite,
    required this.socialAccounts,
    required this.officialApps,
    required this.trustedIdentifiers,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'companyName': companyName,
        'industry': industry,
        'description': description,
        'logoUrl': logoUrl,
        'officialWebsite': officialWebsite,
        'socialAccounts': socialAccounts.map((s) => s.toJson()).toList(),
        'officialApps': officialApps.map((a) => a.toJson()).toList(),
        'trustedIdentifiers': trustedIdentifiers,
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  factory BrandProfile.fromJson(Map<String, dynamic> json) => BrandProfile(
        id: json['id'] ?? 'brand-1',
        companyName: json['companyName'] ?? '',
        industry: json['industry'] ?? 'FinTech & Cybersecurity',
        description: json['description'] ?? '',
        logoUrl: json['logoUrl'] ?? '',
        officialWebsite: json['officialWebsite'] ?? '',
        socialAccounts: (json['socialAccounts'] as List<dynamic>?)
                ?.map((e) => SocialAccount.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        officialApps: (json['officialApps'] as List<dynamic>?)
                ?.map((e) => OfficialApp.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        trustedIdentifiers: (json['trustedIdentifiers'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        lastUpdated: json['lastUpdated'] != null
            ? DateTime.tryParse(json['lastUpdated']) ?? DateTime.now()
            : DateTime.now(),
      );

  BrandProfile copyWith({
    String? id,
    String? companyName,
    String? industry,
    String? description,
    String? logoUrl,
    String? officialWebsite,
    List<SocialAccount>? socialAccounts,
    List<OfficialApp>? officialApps,
    List<String>? trustedIdentifiers,
    DateTime? lastUpdated,
  }) {
    return BrandProfile(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      industry: industry ?? this.industry,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      officialWebsite: officialWebsite ?? this.officialWebsite,
      socialAccounts: socialAccounts ?? List.from(this.socialAccounts),
      officialApps: officialApps ?? List.from(this.officialApps),
      trustedIdentifiers: trustedIdentifiers ?? List.from(this.trustedIdentifiers),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
