import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/brand_profile.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';

class BrandProfileScreen extends StatefulWidget {
  const BrandProfileScreen({super.key});

  @override
  State<BrandProfileScreen> createState() => _BrandProfileScreenState();
}

class _BrandProfileScreenState extends State<BrandProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _industryController;
  late TextEditingController _descController;
  late TextEditingController _websiteController;
  late TextEditingController _logoController;
  late TextEditingController _identifierInputController;

  late List<SocialAccount> _socialAccounts;
  late List<OfficialApp> _officialApps;
  late List<String> _trustedIdentifiers;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AppStateProvider>().brandProfile;
    _nameController = TextEditingController(text: profile.companyName);
    _industryController = TextEditingController(text: profile.industry);
    _descController = TextEditingController(text: profile.description);
    _websiteController = TextEditingController(text: profile.officialWebsite);
    _logoController = TextEditingController(text: profile.logoUrl);
    _identifierInputController = TextEditingController();

    _socialAccounts = List.from(profile.socialAccounts);
    _officialApps = List.from(profile.officialApps);
    _trustedIdentifiers = List.from(profile.trustedIdentifiers);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _industryController.dispose();
    _descController.dispose();
    _websiteController.dispose();
    _logoController.dispose();
    _identifierInputController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final currentProfile = context.read<AppStateProvider>().brandProfile;
      final updated = currentProfile.copyWith(
        companyName: _nameController.text.trim(),
        industry: _industryController.text.trim(),
        description: _descController.text.trim(),
        officialWebsite: _websiteController.text.trim(),
        logoUrl: _logoController.text.trim(),
        socialAccounts: _socialAccounts,
        officialApps: _officialApps,
        trustedIdentifiers: _trustedIdentifiers,
        lastUpdated: DateTime.now(),
      );

      context.read<AppStateProvider>().updateBrandProfile(updated);
      setState(() {
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: AppTheme.coralSunset, size: 18),
              SizedBox(width: 10),
              Text('Brand Profile baseline successfully saved & updated!'),
            ],
          ),
          backgroundColor: AppTheme.surfaceHigh,
        ),
      );
    }
  }

  void _addSocialAccountDialog() {
    final platformCtrl = TextEditingController(text: 'Twitter / X');
    final handleCtrl = TextEditingController();
    final urlCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text('Register Monitored Social Account', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: platformCtrl,
              decoration: const InputDecoration(labelText: 'Platform (e.g. Twitter/X, Instagram, LinkedIn)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: handleCtrl,
              decoration: const InputDecoration(labelText: 'Official Handle (e.g. @RiskoraSec)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlCtrl,
              decoration: const InputDecoration(labelText: 'Profile URL (e.g. https://x.com/RiskoraSec)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (handleCtrl.text.trim().isNotEmpty) {
                setState(() {
                  _socialAccounts.add(
                    SocialAccount(
                      platform: platformCtrl.text.trim(),
                      handle: handleCtrl.text.trim(),
                      url: urlCtrl.text.trim(),
                      isVerified: true,
                    ),
                  );
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add Account'),
          ),
        ],
      ),
    );
  }

  void _addOfficialAppDialog() {
    final nameCtrl = TextEditingController();
    final platformCtrl = TextEditingController(text: 'Android (Google Play)');
    final pkgCtrl = TextEditingController(text: 'com.riskora.');
    final pubCtrl = TextEditingController(text: _nameController.text);
    final urlCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text('Register Official Mobile App', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'App Name (e.g. Riskora Shield)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: platformCtrl,
                decoration: const InputDecoration(labelText: 'Platform (Android / iOS)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pkgCtrl,
                decoration: const InputDecoration(labelText: 'Package / Bundle ID (e.g. com.riskora.app)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pubCtrl,
                decoration: const InputDecoration(labelText: 'Official Publisher Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urlCtrl,
                decoration: const InputDecoration(labelText: 'Store URL'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty && pkgCtrl.text.trim().isNotEmpty) {
                setState(() {
                  _officialApps.add(
                    OfficialApp(
                      name: nameCtrl.text.trim(),
                      platform: platformCtrl.text.trim(),
                      packageId: pkgCtrl.text.trim(),
                      publisher: pubCtrl.text.trim(),
                      storeUrl: urlCtrl.text.trim(),
                    ),
                  );
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add App'),
          ),
        ],
      ),
    );
  }

  void _addTrustedIdentifier() {
    final text = _identifierInputController.text.trim();
    if (text.isNotEmpty && !_trustedIdentifiers.contains(text)) {
      setState(() {
        _trustedIdentifiers.add(text);
        _identifierInputController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Mode Toggle
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 640;
                  final titleCol = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Brand Profile & Asset Perimeter',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: isNarrow ? 20 : 24,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Define official brand identities, verified handles, and package IDs for crawler baseline matching.',
                        style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary),
                      ),
                    ],
                  );

                  final actions = Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      if (!_isEditing)
                        ElevatedButton.icon(
                          onPressed: () => setState(() => _isEditing = true),
                          icon: const Icon(Icons.edit_rounded, size: 16),
                          label: const Text('Edit Profile'),
                        )
                      else ...[
                        OutlinedButton(
                          onPressed: () {
                            final profile = provider.brandProfile;
                            setState(() {
                              _nameController.text = profile.companyName;
                              _industryController.text = profile.industry;
                              _descController.text = profile.description;
                              _websiteController.text = profile.officialWebsite;
                              _logoController.text = profile.logoUrl;
                              _socialAccounts = List.from(profile.socialAccounts);
                              _officialApps = List.from(profile.officialApps);
                              _trustedIdentifiers = List.from(profile.trustedIdentifiers);
                              _isEditing = false;
                            });
                          },
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton.icon(
                          onPressed: provider.isLoading ? null : _saveChanges,
                          icon: provider.isLoading
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF090D16)),
                                )
                              : const Icon(Icons.save_rounded, size: 16),
                          label: const Text('Save Changes'),
                        ),
                      ],
                    ],
                  );

                  if (isNarrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        titleCol,
                        const SizedBox(height: 12),
                        actions,
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: titleCol),
                      const SizedBox(width: 16),
                      actions,
                    ],
                  );
                },
              ),

              const SizedBox(height: 22),

              // Overview Banner Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.surfaceElevated,
                      AppTheme.primaryTeal.withOpacity(0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceHigh,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.4)),
                        image: _logoController.text.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(_logoController.text),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _logoController.text.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                'assets/images/riskora_emblem.png',
                                fit: BoxFit.contain,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  _nameController.text,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.purpleGlow.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Protected Entity',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.purpleGlow,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _websiteController.text,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              color: AppTheme.primaryTeal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_socialAccounts.length} Verified Social Handles • ${_officialApps.length} Mobile App Packages • ${_trustedIdentifiers.length} Trusted Identifiers',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Section 1: General Organization Info
              _buildSectionCard(
                title: 'General Brand Information',
                subtitle: 'Core organization identity registered with RISKORA threat neural network',
                child: Column(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isNarrow = constraints.maxWidth < 540;
                        final nameField = TextFormField(
                          controller: _nameController,
                          enabled: _isEditing,
                          decoration: const InputDecoration(labelText: 'Company / Brand Name *'),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Company name is required' : null,
                        );
                        final industryField = TextFormField(
                          controller: _industryController,
                          enabled: _isEditing,
                          decoration: const InputDecoration(labelText: 'Industry / Sector'),
                        );

                        if (isNarrow) {
                          return Column(
                            children: [
                              nameField,
                              const SizedBox(height: 16),
                              industryField,
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(child: nameField),
                            const SizedBox(width: 16),
                            Expanded(child: industryField),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isNarrow = constraints.maxWidth < 540;
                        final websiteField = TextFormField(
                          controller: _websiteController,
                          enabled: _isEditing,
                          decoration: const InputDecoration(labelText: 'Official Website Domain *'),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Official website is required' : null,
                        );
                        final logoField = TextFormField(
                          controller: _logoController,
                          enabled: _isEditing,
                          decoration: const InputDecoration(labelText: 'Logo Image URL'),
                        );

                        if (isNarrow) {
                          return Column(
                            children: [
                              websiteField,
                              const SizedBox(height: 16),
                              logoField,
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(child: websiteField),
                            const SizedBox(width: 16),
                            Expanded(child: logoField),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descController,
                      enabled: _isEditing,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Brand Description & Protection Scope'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Section 2: Monitored Social Media Accounts
              _buildSectionCard(
                title: 'Authorized Social Media Channels',
                subtitle: 'Accounts recognized as legitimate; deviations are flagged as impersonation candidates',
                action: _isEditing
                    ? TextButton.icon(
                        onPressed: _addSocialAccountDialog,
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('Add Account'),
                      )
                    : null,
                child: _socialAccounts.isEmpty
                    ? _buildEmptyState('No social media accounts configured.')
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _socialAccounts.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = _socialAccounts[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceElevated,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryTeal.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.share_rounded, size: 16, color: AppTheme.primaryTeal),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            item.platform,
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Icon(Icons.verified_rounded, size: 14, color: AppTheme.purpleGlow),
                                        ],
                                      ),
                                      Text(
                                        item.handle,
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      if (item.url.isNotEmpty)
                                        Text(
                                          item.url,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
                                        ),
                                    ],
                                  ),
                                ),
                                if (_isEditing)
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.riskCritical, size: 18),
                                    onPressed: () {
                                      setState(() {
                                        _socialAccounts.removeAt(index);
                                      });
                                    },
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 24),

              // Section 3: Official Mobile Apps
              _buildSectionCard(
                title: 'Official Mobile Applications',
                subtitle: 'Registered Google Play & iOS package IDs used to identify trojanized clones',
                action: _isEditing
                    ? TextButton.icon(
                        onPressed: _addOfficialAppDialog,
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('Add App'),
                      )
                    : null,
                child: _officialApps.isEmpty
                    ? _buildEmptyState('No official mobile applications configured.')
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _officialApps.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final app = _officialApps[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceElevated,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.purpleGlow.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.apps_rounded, size: 16, color: AppTheme.purpleGlow),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        app.name,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        'Package: ${app.packageId} • Publisher: ${app.publisher}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 11,
                                          color: AppTheme.primaryTeal,
                                        ),
                                      ),
                                      Text(
                                        app.platform,
                                        style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_isEditing)
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.riskCritical, size: 18),
                                    onPressed: () {
                                      setState(() {
                                        _officialApps.removeAt(index);
                                      });
                                    },
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 24),

              // Section 4: Trusted Identifiers
              _buildSectionCard(
                title: 'Trusted Identifiers & Keywords',
                subtitle: 'Trademarks, corporate keywords, and whitelisted strings used to refine crawler precision',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isEditing) ...[
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _identifierInputController,
                              style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 13),
                              decoration: const InputDecoration(
                                hintText: 'Enter keyword, trademark or domain (e.g. auth.riskora.io)',
                              ),
                              onSubmitted: (_) => _addTrustedIdentifier(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: _addTrustedIdentifier,
                            icon: const Icon(Icons.add_rounded, size: 16),
                            label: const Text('Add'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _trustedIdentifiers.map((id) {
                        return Chip(
                          label: Text(id),
                          backgroundColor: AppTheme.surfaceElevated,
                          labelStyle: GoogleFonts.jetBrainsMono(fontSize: 11, color: AppTheme.textPrimary),
                          deleteIcon: _isEditing ? const Icon(Icons.close_rounded, size: 14) : null,
                          onDeleted: _isEditing
                              ? () {
                                  setState(() {
                                    _trustedIdentifiers.remove(id);
                                  });
                                }
                              : null,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required Widget child,
    Widget? action,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              ?action,
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.center,
      child: Text(
        msg,
        style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted),
      ),
    );
  }
}
