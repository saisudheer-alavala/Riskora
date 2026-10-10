import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class RiskDistributionChart extends StatefulWidget {
  final Map<String, int> distribution;

  const RiskDistributionChart({
    super.key,
    required this.distribution,
  });

  @override
  State<RiskDistributionChart> createState() => _RiskDistributionChartState();
}

class _RiskDistributionChartState extends State<RiskDistributionChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final critical = widget.distribution['Critical'] ?? widget.distribution['Critical (80-100)'] ?? 12;
    final high = widget.distribution['High'] ?? widget.distribution['High (60-79)'] ?? 14;
    final medium = widget.distribution['Medium'] ?? widget.distribution['Medium (40-59)'] ?? 8;
    final low = widget.distribution['Low'] ?? widget.distribution['Low (0-39)'] ?? 4;
    final total = critical + high + medium + low;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border, width: 1),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Risk Score Distribution',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$total Detections',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryTeal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 180,
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              _touchedIndex = -1;
                              return;
                            }
                            _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 3,
                      centerSpaceRadius: 42,
                      sections: [
                        _buildSection(0, critical.toDouble(), AppTheme.riskCritical, 'Crit'),
                        _buildSection(1, high.toDouble(), AppTheme.riskHigh, 'High'),
                        _buildSection(2, medium.toDouble(), AppTheme.riskMedium, 'Med'),
                        _buildSection(3, low.toDouble(), AppTheme.riskLow, 'Low'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem('Critical (80-100)', critical, AppTheme.riskCritical, total),
                      const SizedBox(height: 8),
                      _buildLegendItem('High (60-79)', high, AppTheme.riskHigh, total),
                      const SizedBox(height: 8),
                      _buildLegendItem('Medium (40-59)', medium, AppTheme.riskMedium, total),
                      const SizedBox(height: 8),
                      _buildLegendItem('Low (0-39)', low, AppTheme.riskLow, total),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PieChartSectionData _buildSection(int index, double value, Color color, String title) {
    final isTouched = index == _touchedIndex;
    final radius = isTouched ? 34.0 : 26.0;
    return PieChartSectionData(
      color: color,
      value: value > 0 ? value : 0.1,
      title: isTouched ? '${value.toInt()}' : '',
      radius: radius,
      titleStyle: GoogleFonts.jetBrainsMono(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildLegendItem(String label, int count, Color color, int total) {
    final percentage = total > 0 ? ((count / total) * 100).toStringAsFixed(0) : '0';
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          '$count ($percentage%)',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
