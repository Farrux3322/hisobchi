import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SummaryGrid extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;
  final int operationsCount;
  final String currency;

  const SummaryGrid({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.operationsCount,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Jami kirim',
                  value: _formatMoney(totalIncome),
                  icon: Icons.trending_up_rounded,
                  color: const Color(0xFF22C55E),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Jami chiqim',
                  value: _formatMoney(totalExpense),
                  icon: Icons.trending_down_rounded,
                  color: const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Operatsiyalar',
                  value: operationsCount.toString(),
                  icon: Icons.description_outlined,
                  color: const Color(0xFF64748B),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Qarzlar',
                  value: '2', // Mock or calculated
                  icon: Icons.receipt_long_outlined,
                  color: const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
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
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              color: const Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatMoney(double value) {
    return value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
  }
}
