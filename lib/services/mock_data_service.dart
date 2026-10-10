import '../models/brand_profile.dart';
import '../models/threat_item.dart';
import '../models/scan_record.dart';
import '../models/report_data.dart';

class MockDataService {
  static BrandProfile getInitialBrandProfile() {
    return BrandProfile(
      id: 'brand-riskora-01',
      companyName: 'Riskora Technologies Inc.',
      industry: 'Cybersecurity & Digital Risk Protection',
      description:
          'Riskora provides enterprise-grade autonomous threat intelligence, brand impersonation detection, and rogue application takedown defense.',
      logoUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=200&auto=format&fit=crop&q=80',
      officialWebsite: 'https://riskora.io',
      socialAccounts: [
        const SocialAccount(
          platform: 'Twitter / X',
          handle: '@RiskoraSec',
          url: 'https://x.com/RiskoraSec',
          isVerified: true,
        ),
        const SocialAccount(
          platform: 'LinkedIn',
          handle: 'company/riskora-protection',
          url: 'https://linkedin.com/company/riskora-protection',
          isVerified: true,
        ),
        const SocialAccount(
          platform: 'Instagram',
          handle: '@riskora.official',
          url: 'https://instagram.com/riskora.official',
          isVerified: true,
        ),
        const SocialAccount(
          platform: 'Telegram',
          handle: '@RiskoraAnnouncements',
          url: 'https://t.me/RiskoraAnnouncements',
          isVerified: false,
        ),
      ],
      officialApps: [
        const OfficialApp(
          name: 'Riskora Shield: Threat Defense',
          platform: 'Android (Google Play)',
          packageId: 'com.riskora.security.shield',
          publisher: 'Riskora Technologies Inc.',
          storeUrl: 'https://play.google.com/store/apps/details?id=com.riskora.security.shield',
        ),
        const OfficialApp(
          name: 'Riskora SecOps Mobile',
          platform: 'iOS (App Store)',
          packageId: 'com.riskora.secops.ios',
          publisher: 'Riskora Technologies Inc.',
          storeUrl: 'https://apps.apple.com/app/riskora-secops/id1659920192',
        ),
      ],
      trustedIdentifiers: [
        'Riskora Technologies Inc.',
        'riskora.io',
        'auth.riskora.io',
        'security@riskora.io',
        'RISKORA™ Registration #8921820',
        'Riskora Sentinel Protocol',
      ],
      lastUpdated: DateTime.now().subtract(const Duration(hours: 3)),
    );
  }

  static List<ThreatItem> getInitialThreats() {
    return [
      // 1. Critical Social Media Impersonator
      ThreatItem(
        id: 'TH-SOC-101',
        title: 'Fake Verified Support Bot Claiming Account Recovery',
        type: ThreatType.socialMedia,
        platform: 'Twitter / X',
        identifier: '@Riskora_Support_Help',
        url: 'https://x.com/Riskora_Support_Help',
        avatarOrIcon: 'https://images.unsplash.com/photo-1563089145-599997674d42?w=150&auto=format&fit=crop&q=80',
        nameSimilarity: 94.5,
        logoSimilarity: 91.2,
        riskScore: 95,
        detectionReasons: [
          'High visual logo match (91.2%) with official brand icon',
          'Name typo-squatting targeting customer support keywords',
          'Biographical text soliciting user private keys & credentials',
          'Phishing URL hosted on dynamic free domain (riskora-support.tk)',
        ],
        indicators: [
          'Phishing Form Link',
          'Fake Verification Badge',
          'Account Age < 3 Days',
          'Zero Following Ratio',
        ],
        description:
          'Active Twitter account impersonating Riskora technical assistance. DMs victims to "verify their 2FA seeds" using a credential-harvesting webform.',
        developerOrAuthor: 'Threat Actor: APT-CryptoHarvest',
        reviewStatus: ReviewStatus.confirmedThreat,
        detectedAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 15)),
        breakdown: const RiskBreakdown(
          nameSimilarityScore: 94.5,
          logoVisualMatchScore: 91.2,
          suspiciousKeywordsScore: 98.0,
          domainOrAccountAgeScore: 95.0,
          permissionMalwareScore: 0.0,
        ),
        notes: [
          InvestigationNote(
            id: 'n-1',
            author: 'Lead SOC Analyst (Sarah M.)',
            text: 'Domain riskora-support.tk is hosted on Cloudflare bypass ASN. Takedown notice prepared for registrar.',
            createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 40)),
          ),
        ],
        comparisonMetadata: {
          'officialName': 'Riskora Technologies',
          'officialHandle': '@RiskoraSec',
          'officialDomain': 'https://riskora.io',
        },
      ),

      // 2. Critical Mobile App Impersonator
      ThreatItem(
        id: 'TH-APP-202',
        title: 'Riskora Mobile Wallet: Cloud Key Backup (Trojan)',
        type: ThreatType.appStore,
        platform: 'Google Play Store',
        identifier: 'com.riskora.wallet.cloudsync',
        url: 'https://play.google.com/store/apps/details?id=com.riskora.wallet.cloudsync',
        avatarOrIcon: 'https://images.unsplash.com/photo-1614680376593-902f749f7ffc?w=150&auto=format&fit=crop&q=80',
        nameSimilarity: 96.0,
        logoSimilarity: 88.5,
        riskScore: 92,
        detectionReasons: [
          'Direct clone of official app assets and corporate branding',
          'Suspicious background SMS intercept and Accessibility Service misuse',
          'Publisher name spoofing: "Riskora Technologies Ltd LLC"',
          'Obfuscated payload attempting exfiltration to unknown C2 server',
        ],
        indicators: [
          'RECEIVE_SMS Permission',
          'READ_CONTACTS Permission',
          'Accessibility Keylogger Payload',
          'Disguised Publisher Identity',
        ],
        description:
          'Malicious APK uploaded under finance category requesting invasive system permissions to intercept 2FA codes and wallet credentials.',
        developerOrAuthor: 'Publisher: Riskora Technologies Ltd LLC (Unverified)',
        reviewStatus: ReviewStatus.inReview,
        detectedAt: DateTime.now().subtract(const Duration(hours: 5, minutes: 30)),
        breakdown: const RiskBreakdown(
          nameSimilarityScore: 96.0,
          logoVisualMatchScore: 88.5,
          suspiciousKeywordsScore: 90.0,
          domainOrAccountAgeScore: 82.0,
          permissionMalwareScore: 96.0,
        ),
        notes: [
          InvestigationNote(
            id: 'n-2',
            author: 'Malware Reverse Engineer (David K.)',
            text: 'Static analysis confirmed decompiled bytecode includes hardcoded telemetry endpoint in Eastern Europe.',
            createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          ),
        ],
        comparisonMetadata: {
          'officialPackageId': 'com.riskora.security.shield',
          'officialPublisher': 'Riskora Technologies Inc.',
        },
      ),

      // 3. High Risk Social Media Impersonator
      ThreatItem(
        id: 'TH-SOC-103',
        title: 'Telegram AirDrop & Token Claim Bot',
        type: ThreatType.socialMedia,
        platform: 'Telegram',
        identifier: '@Riskora_Official_Reward_Bot',
        url: 'https://t.me/Riskora_Official_Reward_Bot',
        avatarOrIcon: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=150&auto=format&fit=crop&q=80',
        nameSimilarity: 88.0,
        logoSimilarity: 82.0,
        riskScore: 84,
        detectionReasons: [
          'Unauthorized use of trademarked logos in bot profile header',
          'Promises fraudulent token giveaways under brand guise',
          'Requires user to sign malicious smart contract transaction',
        ],
        indicators: [
          'Drainer Contract Integration',
          'Automated Spam Group Invites',
          'Fake Giveaway Announcement',
        ],
        description:
          'Telegram bot circulating on cybersecurity forums falsely promising early access tokens while distributing wallet-drainer scripts.',
        developerOrAuthor: 'Bot Creator: @anon_dev_x99',
        reviewStatus: ReviewStatus.takedownRequested,
        detectedAt: DateTime.now().subtract(const Duration(hours: 8)),
        breakdown: const RiskBreakdown(
          nameSimilarityScore: 88.0,
          logoVisualMatchScore: 82.0,
          suspiciousKeywordsScore: 89.0,
          domainOrAccountAgeScore: 78.0,
          permissionMalwareScore: 0.0,
        ),
        notes: [
          InvestigationNote(
            id: 'n-3',
            author: 'Threat Intel Analyst (Alex C.)',
            text: 'Abuse ticket #TLG-99412 filed with Telegram abuse desk. Awaiting account termination.',
            createdAt: DateTime.now().subtract(const Duration(hours: 6)),
          ),
        ],
        comparisonMetadata: {
          'officialHandle': '@RiskoraAnnouncements',
        },
      ),

      // 4. High Risk App Store Impersonator
      ThreatItem(
        id: 'TH-APP-204',
        title: 'Riskora SecAuth 2FA Authenticator',
        type: ThreatType.appStore,
        platform: 'Third-Party APK Mirror',
        identifier: 'org.auth.riskora.authenticator.v2',
        url: 'https://apkpure-mirror-test.com/riskora-secauth',
        avatarOrIcon: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=150&auto=format&fit=crop&q=80',
        nameSimilarity: 89.0,
        logoSimilarity: 79.0,
        riskScore: 78,
        detectionReasons: [
          'Unsigned binary masquerading as official authenticator app',
          'App bundles ad-fraud SDK and excessive background wake-locks',
          'Contains deceptive UI mirroring official Riskora brand gradient',
        ],
        indicators: [
          'Unsigned Debug Certificate',
          'Aggressive Ad-Injection SDK',
          'Package ID Impersonation',
        ],
        description:
          'Third-party Android package targeting enterprise employees searching for Riskora multi-factor authentication tools.',
        developerOrAuthor: 'Distributor: FastApp Distribution Hub',
        reviewStatus: ReviewStatus.newDetected,
        detectedAt: DateTime.now().subtract(const Duration(hours: 14)),
        breakdown: const RiskBreakdown(
          nameSimilarityScore: 89.0,
          logoVisualMatchScore: 79.0,
          suspiciousKeywordsScore: 72.0,
          domainOrAccountAgeScore: 65.0,
          permissionMalwareScore: 82.0,
        ),
      ),

      // 5. Medium Risk Social Media
      ThreatItem(
        id: 'TH-SOC-105',
        title: 'Instagram Job Recruiting Scammer',
        type: ThreatType.socialMedia,
        platform: 'Instagram',
        identifier: '@riskora_global_careers',
        url: 'https://instagram.com/riskora_global_careers',
        avatarOrIcon: 'https://images.unsplash.com/photo-1579546929518-9e396f3cc809?w=150&auto=format&fit=crop&q=80',
        nameSimilarity: 75.0,
        logoSimilarity: 64.0,
        riskScore: 58,
        detectionReasons: [
          'Unofficial job recruitment offers charging "application processing fees"',
          'Modest visual similarity with outdated brand typography',
        ],
        indicators: [
          'Payment Request for Interviews',
          'Unverified Recruiter Profiles',
        ],
        description:
          'Instagram profile posting fabricated cybersecurity job openings and requesting registration fees via Western Union / gift cards.',
        developerOrAuthor: 'Account Operator: Unknown',
        reviewStatus: ReviewStatus.inReview,
        detectedAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        breakdown: const RiskBreakdown(
          nameSimilarityScore: 75.0,
          logoVisualMatchScore: 64.0,
          suspiciousKeywordsScore: 68.0,
          domainOrAccountAgeScore: 45.0,
          permissionMalwareScore: 0.0,
        ),
      ),

      // 6. False Positive Example
      ThreatItem(
        id: 'TH-SOC-106',
        title: 'Cybersecurity Student Research Club @ Uni',
        type: ThreatType.socialMedia,
        platform: 'LinkedIn',
        identifier: 'showcase/riskora-student-researchers',
        url: 'https://linkedin.com/showcase/riskora-student-researchers',
        avatarOrIcon: 'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=150&auto=format&fit=crop&q=80',
        nameSimilarity: 68.0,
        logoSimilarity: 35.0,
        riskScore: 28,
        detectionReasons: [
          'Educational discussion referencing Riskora open threat whitepapers',
          'Clear disclaimer stating student academic non-affiliation',
        ],
        indicators: [
          'Academic Domain Reference',
          'Non-commercial Intent',
        ],
        description:
          'Legitimate student university group analyzing cybersecurity threat models using Riskora published case studies. Flagged due to keyword overlap.',
        developerOrAuthor: 'Organization: Univ Cybersecurity Club',
        reviewStatus: ReviewStatus.falsePositive,
        detectedAt: DateTime.now().subtract(const Duration(days: 2)),
        breakdown: const RiskBreakdown(
          nameSimilarityScore: 68.0,
          logoVisualMatchScore: 35.0,
          suspiciousKeywordsScore: 20.0,
          domainOrAccountAgeScore: 10.0,
          permissionMalwareScore: 0.0,
        ),
        notes: [
          InvestigationNote(
            id: 'n-4',
            author: 'Analyst (Marcus V.)',
            text: 'Verified academic non-infringing usage. Marked as false positive to tune crawler precision.',
            createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 18)),
          ),
        ],
      ),

      // 7. Low Risk App Item
      ThreatItem(
        id: 'TH-APP-207',
        title: 'Risk Guide & Cheat Sheet for SecOps',
        type: ThreatType.appStore,
        platform: 'Apple App Store',
        identifier: 'com.infoguides.riskora.handbook',
        url: 'https://apps.apple.com/app/risk-handbook/id9921448',
        avatarOrIcon: 'https://images.unsplash.com/photo-1550751827-4bd374c3f58b?w=150&auto=format&fit=crop&q=80',
        nameSimilarity: 62.0,
        logoSimilarity: 22.0,
        riskScore: 34,
        detectionReasons: [
          'Reference app mentioning brand name in search tags',
          'No deceptive intent or malware signals observed',
        ],
        indicators: [
          'Educational Content Tag',
          'No Sensitive Permissions',
        ],
        description:
          'Educational cybersecurity flashcards and glossary mentioning Riskora alongside other security frameworks.',
        developerOrAuthor: 'Developer: InfoGuide Studio',
        reviewStatus: ReviewStatus.resolved,
        detectedAt: DateTime.now().subtract(const Duration(days: 3)),
        breakdown: const RiskBreakdown(
          nameSimilarityScore: 62.0,
          logoVisualMatchScore: 22.0,
          suspiciousKeywordsScore: 18.0,
          domainOrAccountAgeScore: 12.0,
          permissionMalwareScore: 15.0,
        ),
      ),
    ];
  }

  static List<ScanRecord> getInitialScanRecords() {
    return [
      ScanRecord(
        id: 'SCN-9021',
        scanDate: DateTime.now().subtract(const Duration(minutes: 42)),
        sourceType: 'All Sources (Automated)',
        status: ScanStatus.completed,
        candidatesChecked: 1420,
        detectionsCount: 7,
        highRiskCount: 3,
        durationSeconds: 114,
        errors: [],
      ),
      ScanRecord(
        id: 'SCN-9020',
        scanDate: DateTime.now().subtract(const Duration(hours: 6)),
        sourceType: 'Google Play & App Stores',
        status: ScanStatus.completed,
        candidatesChecked: 485,
        detectionsCount: 4,
        highRiskCount: 2,
        durationSeconds: 68,
        errors: [],
      ),
      ScanRecord(
        id: 'SCN-9019',
        scanDate: DateTime.now().subtract(const Duration(hours: 18)),
        sourceType: 'Social Media Channels',
        status: ScanStatus.completed,
        candidatesChecked: 935,
        detectionsCount: 6,
        highRiskCount: 2,
        durationSeconds: 82,
        errors: [
          'Rate limit reached on TikTok API crawl (handled via backoff)',
        ],
      ),
      ScanRecord(
        id: 'SCN-9018',
        scanDate: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
        sourceType: 'Dark Web Threat Feeds',
        status: ScanStatus.completed,
        candidatesChecked: 310,
        detectionsCount: 2,
        highRiskCount: 1,
        durationSeconds: 145,
        errors: [],
      ),
      ScanRecord(
        id: 'SCN-9017',
        scanDate: DateTime.now().subtract(const Duration(days: 2)),
        sourceType: 'Domain Registries & DNS',
        status: ScanStatus.completed,
        candidatesChecked: 2150,
        detectionsCount: 5,
        highRiskCount: 3,
        durationSeconds: 198,
        errors: [],
      ),
      ScanRecord(
        id: 'SCN-9016',
        scanDate: DateTime.now().subtract(const Duration(days: 3)),
        sourceType: 'All Sources (Scheduled)',
        status: ScanStatus.completed,
        candidatesChecked: 1380,
        detectionsCount: 8,
        highRiskCount: 4,
        durationSeconds: 130,
        errors: [],
      ),
    ];
  }

  static ReportSummary getInitialReportSummary() {
    return ReportSummary(
      generatedAt: DateTime.now(),
      dateRange: 'Last 30 Days',
      totalScansRun: 42,
      totalDetections: 38,
      confirmedThreats: 18,
      falsePositives: 7,
      takedownsInitiated: 11,
      activeMonitoringAssets: 6,
      averageDetectionAccuracy: 95.2,
      riskDistribution: {
        'Critical (80-100)': 12,
        'High (60-79)': 14,
        'Medium (40-59)': 8,
        'Low (0-39)': 4,
      },
      platformBreakdown: {
        'Twitter / X': 14,
        'Google Play': 10,
        'Telegram': 6,
        'Instagram': 4,
        'Third-Party APK': 3,
        'LinkedIn': 1,
      },
      executiveHighlights: [
        'Impersonation campaigns targeting cryptocurrency and authentication mechanisms increased by 34% this month.',
        'High-confidence brand logo vector similarity model successfully intercepted 3 counterfeit Google Play applications prior to widespread infection.',
        'Average automated takedown package preparation time reduced to under 4 minutes with pre-compiled evidence logs.',
        'False positive rate maintained at a record low 4.8% due to active trusted identifier white-listing.',
      ],
    );
  }
}
