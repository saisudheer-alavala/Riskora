import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'quick_chat_dialog.dart';

class FloatingAiButton extends StatefulWidget {
  const FloatingAiButton({super.key});

  @override
  State<FloatingAiButton> createState() => _FloatingAiButtonState();
}

class _FloatingAiButtonState extends State<FloatingAiButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryTeal.withOpacity(0.4),
              blurRadius: 18,
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => const QuickChatDialog(),
            );
          },
          backgroundColor: AppTheme.primaryTeal,
          foregroundColor: const Color(0xFF090D16),
          elevation: 6,
          icon: const Icon(Icons.smart_toy_rounded, size: 20),
          label: Row(
            children: [
              Text(
                'AI Advisor',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF090D16),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
