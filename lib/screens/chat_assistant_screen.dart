import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/chat_message.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';

class ChatAssistantScreen extends StatefulWidget {
  const ChatAssistantScreen({super.key});

  @override
  State<ChatAssistantScreen> createState() => _ChatAssistantScreenState();
}

class _ChatAssistantScreenState extends State<ChatAssistantScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _suggestedQuestions = const [
    'What brands are registered?',
    'Why was this account flagged?',
    'What does this risk score mean?',
    'How do I register a brand?',
    'How do I report a suspicious app?',
  ];

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage([String? customText]) {
    final text = customText ?? _inputController.text;
    if (text.trim().isNotEmpty) {
      context.read<AppStateProvider>().sendChatMessage(text);
      if (customText == null) {
        _inputController.clear();
      }
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final messages = provider.chatMessages;
    final currentMode = provider.currentChatMode;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;

          return Row(
            children: [
              if (isWide) _buildLeftSidebar(provider),
              if (isWide) VerticalDivider(width: 1, thickness: 1, color: AppTheme.border),
              Expanded(
                child: Column(
                  children: [
                    // Chat Screen Top Bar
                    _buildTopHeader(provider, currentMode, isWide),

                    // Chat messages list
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          return _buildMessageBubble(msg);
                        },
                      ),
                    ),

                    if (provider.isChatThinking) _buildThinkingIndicator(),

                    // Suggested Questions horizontal bar
                    _buildSuggestedChipsBar(),

                    // Message input field
                    _buildInputArea(provider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLeftSidebar(AppStateProvider provider) {
    return Container(
      width: 280,
      color: AppTheme.surface,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AI Copilot Modes',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_sweep_outlined, size: 18, color: AppTheme.textMuted),
                tooltip: 'Clear Conversation',
                onPressed: () => provider.clearChat(),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: ChatMode.values.map((mode) {
                  final isSelected = provider.currentChatMode == mode;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryTeal.withOpacity(0.12) : AppTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryTeal.withOpacity(0.5) : AppTheme.border,
                      ),
                    ),
                    child: ListTile(
                      dense: true,
                      onTap: () => provider.setChatMode(mode),
                      leading: Icon(
                        mode == ChatMode.brandAssistant
                            ? Icons.domain_rounded
                            : (mode == ChatMode.riskAdvisor ? Icons.security_rounded : Icons.support_agent_rounded),
                        color: isSelected ? AppTheme.primaryTeal : AppTheme.textSecondary,
                        size: 20,
                      ),
                      title: Text(
                        mode.displayName,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                        ),
                      ),
                      subtitle: Text(
                        mode.description,
                        style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textMuted),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, size: 18, color: AppTheme.coralSunset),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Multi-modal LLM reasoning with live evidence retrieval',
                    style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader(AppStateProvider provider, ChatMode mode, bool isWide) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 620;

          final titleContent = Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppTheme.redPointsGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'RISKORA Threat Intelligence Assistant',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.coralSunset.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'FastAPI Ready',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.coralSunset,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Mode: ${mode.displayName} • ${mode.description}',
                      style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          );

          final dropdownWidget = !isWide
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.borderSubtle),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<ChatMode>(
                      value: mode,
                      isDense: true,
                      dropdownColor: AppTheme.surfaceElevated,
                      items: ChatMode.values.map((m) {
                        return DropdownMenuItem(
                          value: m,
                          child: Text(m.displayName, style: GoogleFonts.inter(fontSize: 12)),
                        );
                      }).toList(),
                      onChanged: (m) {
                        if (m != null) provider.setChatMode(m);
                      },
                    ),
                  ),
                )
              : null;

          if (isNarrow && dropdownWidget != null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                titleContent,
                const SizedBox(height: 10),
                dropdownWidget,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: titleContent),
              if (dropdownWidget != null) ...[
                const SizedBox(width: 12),
                dropdownWidget,
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isUser = msg.sender == MessageSender.user;
    final timeFormat = DateFormat('HH:mm');

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        constraints: const BoxConstraints(maxWidth: 720),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isUser) ...[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.5)),
                ),
                child: const Center(
                  child: Icon(Icons.smart_toy_rounded, size: 16, color: AppTheme.primaryTeal),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isUser ? AppTheme.primaryTeal.withOpacity(0.18) : AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isUser ? AppTheme.primaryTeal.withOpacity(0.4) : AppTheme.border,
                    width: 1,
                  ),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isUser ? 'You' : 'RISKORA Advisor',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isUser ? AppTheme.primaryTeal : AppTheme.purpleGlow,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timeFormat.format(msg.timestamp),
                          style: GoogleFonts.jetBrainsMono(fontSize: 10, color: AppTheme.textMuted),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: msg.text));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Message copied to clipboard')),
                            );
                          },
                          child: Icon(Icons.copy_rounded, size: 12, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      msg.text,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                        height: 1.5,
                      ),
                    ),
                    if (msg.metadata != null) ...[
                      const SizedBox(height: 14),
                      _buildRichMetadataCard(msg.metadata!),
                    ],
                  ],
                ),
              ),
            ),
            if (isUser) ...[
              const SizedBox(width: 10),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.border),
                ),
                child: const Center(
                  child: Icon(Icons.person_outline_rounded, size: 16, color: AppTheme.primaryTeal),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRichMetadataCard(ChatMetadata meta) {
    final type = meta.type;
    final data = meta.data ?? {};

    if (type == 'brand_info') {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.verified_user_rounded, color: AppTheme.purpleGlow, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Retrieved Monitored Brand Profile',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.purpleGlow,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('Company: ${data['company']}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
            Text('Website: ${data['website']}', style: GoogleFonts.jetBrainsMono(fontSize: 11, color: AppTheme.primaryTeal)),
            const SizedBox(height: 6),
            Text('Verified Socials: ${(data['verifiedHandles'] as List?)?.join(", ")}', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary)),
            Text('Monitored Apps: ${(data['officialApps'] as List?)?.join(", ")}', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary)),
          ],
        ),
      );
    }

    if (type == 'detection_evidence') {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.riskCritical.withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.biotech_rounded, color: AppTheme.riskCritical, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Evidence Breakdown: ${data['account']}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.riskCritical,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.riskCritical.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Risk: ${data['riskScore']}',
                    style: GoogleFonts.jetBrainsMono(fontSize: 10, color: AppTheme.riskCritical, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Confidence: ${data['confidence']}', style: GoogleFonts.jetBrainsMono(fontSize: 11, color: AppTheme.textSecondary)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: ((data['indicators'] as List?) ?? []).map((i) {
                return Chip(
                  label: Text('$i'),
                  backgroundColor: AppTheme.surface,
                  labelStyle: GoogleFonts.jetBrainsMono(fontSize: 10, color: AppTheme.textPrimary),
                );
              }).toList(),
            ),
            if (data['recommendedAction'] != null) ...[
              const SizedBox(height: 8),
              Text(
                'Recommended Action: ${data['recommendedAction']}',
                style: GoogleFonts.inter(fontSize: 11, color: AppTheme.primaryTeal, fontWeight: FontWeight.w600),
              ),
            ],
          ],
        ),
      );
    }

    if (type == 'support_guide') {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.riskInfo.withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.help_outline_rounded, color: AppTheme.riskInfo, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Support & Takedown Protocol',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.riskInfo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (data['tip'] != null)
              Text('Tip: ${data['tip']}', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary)),
            if (data['legalReference'] != null)
              Text('Legal Basis: ${data['legalReference']}', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: AppTheme.textMuted)),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildThinkingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryTeal),
          ),
          const SizedBox(width: 10),
          Text(
            'RISKORA intelligence engine synthesizing forensic models...',
            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedChipsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppTheme.surfaceElevated.withOpacity(0.5),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _suggestedQuestions.map((q) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                label: Text(q),
                backgroundColor: AppTheme.surface,
                labelStyle: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: AppTheme.border, width: 0.8),
                ),
                onPressed: () => _sendMessage(q),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildInputArea(AppStateProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Type your message (e.g. Why was this account flagged?)...',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppTheme.border),
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: () => _sendMessage(),
            icon: const Icon(Icons.send_rounded, size: 16),
            label: const Text('Send'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
