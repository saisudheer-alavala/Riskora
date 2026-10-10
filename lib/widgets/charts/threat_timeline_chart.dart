import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class ThreatTimelineChart extends StatelessWidget {
  const ThreatTimelineChart({super.key});

  @override
  Widget build(BuildContext context) {
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Threat Detection Activity',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '7-day multi-channel scan telemetry',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPill('Detections', AppTheme.riskHigh),
                  const SizedBox(width: 8),
                  _buildPill('Resolved', AppTheme.purpleGlow),
                ],
              ),
            ],
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppTheme.border.withOpacity(0.4),
                    strokeWidth: 0.8,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 4,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}',
                        style: GoogleFonts.jetBrainsMono(
                          color: AppTheme.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        final index = value.toInt();
                        if (index >= 0 && index < days.length) {
                          return Text(
                            days[index],
                            style: GoogleFonts.inter(
                              color: AppTheme.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 16,
                lineBarsData: [
                  // Detections line
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 4),
                      FlSpot(1, 7),
                      FlSpot(2, 5),
                      FlSpot(3, 11),
                      FlSpot(4, 9),
                      FlSpot(5, 14),
                      FlSpot(6, 8),
                    ],
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: AppTheme.riskHigh,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 3.5,
                        color: AppTheme.riskHigh,
                        strokeWidth: 1.5,
                        strokeColor: AppTheme.surface,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.riskHigh.withOpacity(0.25),
                          AppTheme.riskHigh.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Resolved line
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 2),
                      FlSpot(1, 5),
                      FlSpot(2, 4),
                      FlSpot(3, 8),
                      FlSpot(4, 7),
                      FlSpot(5, 10),
                      FlSpot(6, 6),
                    ],
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: AppTheme.purpleGlow,
                    barWidth: 2.2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.purpleGlow.withOpacity(0.18),
                          AppTheme.purpleGlow.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill(String title, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
