import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/chat_message.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';

class QuickChatDialog extends StatefulWidget {
  const QuickChatDialog({super.key});

  @override
  State<QuickChatDialog> createState() => _QuickChatDialogState();
}

class _QuickChatDialogState extends State<QuickChatDialog> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();
    final messages = provider.chatMessages;

    return Dialog(
      backgroundColor: AppTheme.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.border, width: 1.2),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 680),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                border: const Border(bottom: BorderSide(color: AppTheme.border)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.smart_toy_rounded, color: AppTheme.primaryTeal, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RISKORA AI Copilot',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'Active Mode: ${provider.currentChatMode.displayName}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppTheme.coralSunset,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.open_in_full_rounded, size: 18, color: AppTheme.textSecondary),
                    tooltip: 'Open Full Chat Screen',
                    onPressed: () {
                      Navigator.pop(context);
                      provider.setNavIndex(5); // Chat Assistant Screen
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: AppTheme.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Mode Selector Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              color: AppTheme.surfaceHigh.withOpacity(0.4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ChatMode.values.map((mode) {
                    final isSelected = provider.currentChatMode == mode;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(mode.displayName),
                        selected: isSelected,
                        onSelected: (_) => provider.setChatMode(mode),
                        selectedColor: AppTheme.primaryTeal.withOpacity(0.2),
                        backgroundColor: AppTheme.surface,
                        labelStyle: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppTheme.primaryTeal : AppTheme.textSecondary,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                          side: BorderSide(
                            color: isSelected ? AppTheme.primaryTeal : AppTheme.border,
                            width: 0.8,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Messages View
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isUser = msg.sender == MessageSender.user;

                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      constraints: const BoxConstraints(maxWidth: 480),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isUser ? AppTheme.primaryTeal.withOpacity(0.18) : AppTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isUser ? AppTheme.primaryTeal.withOpacity(0.4) : AppTheme.border,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isUser ? Icons.person_outline_rounded : Icons.smart_toy_rounded,
                                size: 13,
                                color: isUser ? AppTheme.coralSunset : AppTheme.purpleGlow,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isUser ? 'You' : 'RISKORA Advisor',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isUser ? AppTheme.coralSunset : AppTheme.purpleGlow,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          SelectableText(
                            msg.text,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppTheme.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            if (provider.isChatThinking)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryTeal),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Analyzing cybersecurity evidence models...',
                      style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),

            // Suggested prompt chips
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppTheme.borderSubtle)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildPromptChip('Why was this account flagged?', provider),
                    _buildPromptChip('What does this risk score mean?', provider),
                    _buildPromptChip('What brands are registered?', provider),
                  ],
                ),
              ),
            ),

            // Input Bar
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Ask RISKORA AI about threats, scores, takedowns...',
                        filled: true,
                        fillColor: AppTheme.surfaceElevated,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppTheme.border),
                        ),
                      ),
                      onSubmitted: (val) {
                        if (val.trim().isNotEmpty) {
                          provider.sendChatMessage(val);
                          _textController.clear();
                          _scrollToBottom();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () {
                      final val = _textController.text;
                      if (val.trim().isNotEmpty) {
                        provider.sendChatMessage(val);
                        _textController.clear();
                        _scrollToBottom();
                      }
                    },
                    icon: const Icon(Icons.send_rounded, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                      foregroundColor: const Color(0xFF090D16),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptChip(String question, AppStateProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ActionChip(
        label: Text(question),
        backgroundColor: AppTheme.surfaceElevated,
        labelStyle: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: AppTheme.border, width: 0.8),
        ),
        onPressed: () {
          provider.sendChatMessage(question);
          _scrollToBottom();
        },
      ),
    );
  }
}
