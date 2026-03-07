import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final String currency;
  final int operationsCount;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.currency,
    required this.operationsCount,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = balance >= 0;
    final positiveGradient = [const Color(0xFF22C55E), const Color(0xFF16A34A)];
    final negativeGradient = [const Color(0xFFEF4444), const Color(0xFFDC2626)];

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal:  16.w).copyWith(bottom: 10.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isPositive ? positiveGradient : negativeGradient,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: (isPositive ? positiveGradient[0] : negativeGradient[0]).withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: -5,
            top: -5,
            child: Icon(
              isPositive ? Icons.north_east_rounded : Icons.south_west_rounded,
              size: 30.sp,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sync_alt, color: Colors.white, size: 12.sp),
                  SizedBox(width: 4.w),
                  Text(
                    '$operationsCount ta operatsiya',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              (() {
                final String? subtitle = balance < 0 ? 'Hamkor qarzi' : (balance > 0 ? 'Hamkor haqqi' : null);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Joriy balans',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                );
              })(),
              SizedBox(height: 4.h),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: balance),
                duration: const Duration(seconds: 1),
                curve: Curves.easeOutExpo,
                builder: (context, value, child) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Spacer(),
                      Text(
                        '${value >= 0 ? '+' : ''}${_formatPrice(value)}',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 24.sp,

                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 4.w, bottom: 4.h),
                        child: Text(
                          currency,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ],
                  );
                },
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
