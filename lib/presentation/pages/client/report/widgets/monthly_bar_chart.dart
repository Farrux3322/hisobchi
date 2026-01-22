import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/dashboard_models.dart';

class MonthlyBarChart extends StatelessWidget {
  final List<MonthlyStat> stats;
  final String currency;

  const MonthlyBarChart({
    super.key,
    required this.stats,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
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
            'Oylik statistika',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'So\'nggi ${stats.length} oy ($currency)',
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 24.h),
          SizedBox(
            height: 260.h,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxY(),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipRoundedRadius: 8,
                    tooltipMargin: 5,
                    getTooltipColor: (_) => const Color(0xFF1E293B),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        _formatNumber(rod.toY),
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: _getBottomTitles,
                      reservedSize: 32,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: _getLeftTitles,
                      reservedSize: 42,
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: const Color(0xFFF1F5F9),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
                    left: BorderSide(color: Color(0xFFF1F5F9), width: 1),
                  ),
                ),
                barGroups: stats.asMap().entries.map((entry) {
                  final index = entry.key;
                  final stat = entry.value;
                  return BarChartGroupData(
                    x: index,
                    showingTooltipIndicators: [0, 1],
                    barRods: [
                      BarChartRodData(
                        toY: stat.income,
                        color: const Color(0xFF22C55E),
                        width: 32.w,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(8.r), topRight: Radius.circular(8.r)),
                      ),
                      BarChartRodData(
                        toY: stat.expense,
                        color: const Color(0xFFEF4444),
                        width: 32.w,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(8.r), topRight: Radius.circular(8.r)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend('Kirim', const Color(0xFF22C55E)),
              SizedBox(width: 24.w),
              _buildLegend('Chiqim', const Color(0xFFEF4444)),
            ],
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

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3.r)),
        ),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _getBottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w600, fontSize: 10);
    final index = value.toInt();
    if (index >= 0 && index < stats.length) {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 8,
        child: Text(stats[index].month, style: style),
      );
    }
    return const SizedBox.shrink();
  }
  
  Widget _getLeftTitles(double value, TitleMeta meta) {
    if (value == meta.max) return const SizedBox.shrink();
    
    const style = TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w600, fontSize: 10);
    
    String text;
    if (value >= 1000000) {
      text = '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
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

  double _getMaxY() {
    double max = 0;
    for (var stat in stats) {
      if (stat.income > max) max = stat.income;
      if (stat.expense > max) max = stat.expense;
    }
    return max * 1.2;
  }
}
