import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BalanceLineChart extends StatelessWidget {
  final List<FlSpot> spots;
  final List<String> labels;
  final String currency;

  const BalanceLineChart({
    super.key,
    required this.spots,
    required this.labels,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final barData = LineChartBarData(
      spots: spots,
      isCurved: true,
      color: const Color(0xFF2F6BFF),
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
          radius: 4,
          color: Colors.white,
          strokeWidth: 2,
          strokeColor: const Color(0xFF2F6BFF),
        ),
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF2F6BFF).withOpacity(0.15),
            const Color(0xFF2F6BFF).withOpacity(0.0),
          ],
        ),
      ),
    );

    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Balans dinamikasi',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Oxirgi operatsiyalar ($currency)',
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 24.h),
          SizedBox(
            height: 260.h,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: const Color(0xFFF1F5F9),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: _getLeftTitles,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 1,
                      getTitlesWidget: _getBottomTitles,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
                    left: BorderSide(color: Color(0xFFF1F5F9), width: 1),
                  ),
                ),
                lineBarsData: [barData],
                lineTouchData: LineTouchData(
                  enabled: false, // Disable touch to prevent flickering with permanent tooltips
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => const Color(0xFF1E293B),
                    tooltipMargin: 5,
                    tooltipRoundedRadius: 6.r,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          _formatNumber(spot.y),
                          TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 9.sp,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                showingTooltipIndicators: spots.asMap().entries.map((entry) {
                  return ShowingTooltipIndicators([
                    LineBarSpot(barData, 0, barData.spots[entry.key]),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double value) {
    final absValue = value.abs();
    if (absValue >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (absValue >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }

  Widget _getLeftTitles(double value, TitleMeta meta) {
    if (value == meta.max || value == meta.min) return const SizedBox.shrink();
    
    const style = TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w600, fontSize: 10);
    
    String text;
    final absValue = value.abs();
    if (absValue >= 1000000) {
      text = '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (absValue >= 1000) {
      text = '${(value / 1000).toStringAsFixed(0)}K';
    } else {
      text = value.toStringAsFixed(0);
    }
    
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8,
      child: Text(text, style: style),
    );
  }

  Widget _getBottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w600, fontSize: 10);
    final index = value.toInt();
    if (index >= 0 && index < labels.length) {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 8,
        child: Text(labels[index], style: style),
      );
    }
    return const SizedBox.shrink();
  }
}
