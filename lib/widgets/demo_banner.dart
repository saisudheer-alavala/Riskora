import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class DemoBanner extends StatelessWidget {
  final ApiConnectionStatus status;
  final VoidCallback? onSettingsTap;

  const DemoBanner({
    super.key,
    required this.status,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLive = status == ApiConnectionStatus.connected;
    final isChecking = status == ApiConnectionStatus.checking;

    final bannerBg = isLive
        ? AppTheme.purpleGlow.withOpacity(0.12)
        : const Color(0xFF1E2838);
    final borderColor = isLive
        ? AppTheme.purpleGlow.withOpacity(0.4)
        : AppTheme.primaryTeal.withOpacity(0.35);
    final iconColor = isLive ? AppTheme.purpleGlow : AppTheme.primaryTeal;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: bannerBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            isLive
                ? Icons.cloud_done_rounded
                : isChecking
                    ? Icons.sync_rounded
                    : Icons.science_outlined,
            size: 18,
            color: iconColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
                children: [
                  TextSpan(
                    text: isLive
                        ? 'LIVE TELEMETRY ACTIVE: '
                        : 'DEMO & SIMULATION MODE: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isLive ? AppTheme.purpleGlow : AppTheme.primaryTeal,
                    ),
                  ),
                  TextSpan(
                    text: isLive
                        ? 'Connected to Python FastAPI threat detection backend.'
                        : 'Simulated threat models & AI data are active for demonstration. Backend API can be linked in Settings.',
                  ),
                ],
              ),
            ),
          ),
          if (onSettingsTap != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onSettingsTap,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Configure API',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppTheme.primaryTeal),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
