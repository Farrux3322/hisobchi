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
            color: Colors.black.withValues(alpha: 0.03),
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
            'So\'nggi 6 oy ($currency)',
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 24.h),
          SizedBox(
            height: 200.h,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxY(),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipRoundedRadius: 8,
                    getTooltipColor: (_) => const Color(0xFF1E293B),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        rod.toY.toStringAsFixed(0),
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: stats.asMap().entries.map((entry) {
                  final index = entry.key;
                  final stat = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: stat.income,
                        color: const Color(0xFF22C55E),
                        width: 12.w,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      BarChartRodData(
                        toY: stat.expense,
                        color: const Color(0xFFEF4444),
                        width: 12.w,
                        borderRadius: BorderRadius.circular(4.r),
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
    const style = TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.bold, fontSize: 11);
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

  double _getMaxY() {
    double max = 0;
    for (var stat in stats) {
      if (stat.income > max) max = stat.income;
      if (stat.expense > max) max = stat.expense;
    }
    return max * 1.2;
  }
}
