import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final String currency;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = balance >= 0;
    final positiveGradient = [const Color(0xFF22C55E), const Color(0xFF16A34A)];
    final negativeGradient = [const Color(0xFFEF4444), const Color(0xFFDC2626)];

    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isPositive ? positiveGradient : negativeGradient,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: (isPositive ? positiveGradient[0] : negativeGradient[0]).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -10,
            child: Icon(
              isPositive ? Icons.trending_up : Icons.trending_down,
              size: 100,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Joriy balans',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: balance),
                duration: const Duration(seconds: 1),
                curve: Curves.easeOutExpo,
                builder: (context, value, child) {
                  return Text(
                    '${value >= 0 ? '+' : ''}${_formatPrice(value)} $currency',
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                },
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_downward : Icons.arrow_upward,
                      size: 14.sp,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      isPositive ? 'Bizdan olishi kerak' : 'Biz olishimiz kerak',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPrice(double value) {
    // Basic price formatting, you might want to use intl NumberFormat
    return value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
  }
}
