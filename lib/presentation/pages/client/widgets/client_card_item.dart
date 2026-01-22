import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hisobchi/infrastructure/dto/models/partner/partner_model.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/utils/phone_formatter.dart';

class ClientCardItem extends StatelessWidget {
  final PartnerModel? partnerModel;
  final VoidCallback? onTap;

  const ClientCardItem({super.key, required this.partnerModel, this.onTap});

  String formatCurrency(num amount) {
    final absAmount = amount.abs();
    if (absAmount >= 1000000) {
      return '${(absAmount / 1000000).toStringAsFixed(3)} \$';
    } else if (absAmount >= 1000) {
      return '${(absAmount / 1000).toStringAsFixed(1)}K \$';
    }
    return '${absAmount.toStringAsFixed(0)} \$';
  }

  String _formatBalance(num amount) {
    // Format number with spaces as thousand separators
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final parts = absAmount.toStringAsFixed(0).split('.');
    final integerPart = parts[0];

    // Add spaces every 3 digits from right
    String formatted = '';
    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        formatted += ' ';
      }
      formatted += integerPart[i];
    }

    return '${isNegative ? '-' : ''}$formatted';
  }

  @override
  Widget build(BuildContext context) {
    final bool isUZSPositive = (partnerModel?.balance?.uzs ?? 0) >= 0;
    final bool isUSDPositive = (partnerModel?.balance?.usd ?? 0) >= 0;

    return Container(
      margin: EdgeInsets.only(bottom: 7.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: partnerModel?.deletedAt == null 
              ? const Color(0xFFF1F5F9) 
              : Colors.red.shade100,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar with subtle shadow
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: CachedNetworkImage(
                          imageUrl: (partnerModel?.files ?? []).isNotEmpty
                              ? partnerModel?.files?.first.url ?? ''
                              : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQEM7h-3_xucDg6PXVOyOxh9QOnMkS0dvydRA&s',
                          width: 48.w,
                          height: 48.w,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const CupertinoActivityIndicator(),
                          errorWidget: (context, url, error) => const Icon(Icons.person, color: Colors.grey),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),

                    // Name, Phone and Date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            partnerModel?.name ?? 'Noma\'lum',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            PhoneFormatter.formatPhoneNumber(partnerModel?.phone ?? ''),
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),

                        ],
                      ),
                    ),
                    
                    // Balance section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildBalanceRow(
                          amount: partnerModel?.balance?.uzs ?? 0,
                          currency: 'UZS',
                        ),
                        SizedBox(height: 4.h),
                        _buildBalanceRow(
                          amount: partnerModel?.balance?.usd ?? 0,
                          currency: 'USD',
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 12.sp, color: const Color(0xFF94A3B8)),
                        SizedBox(width: 4.w),
                        Text(
                          partnerModel?.createdAt?.split(" ").first ?? '',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                   Row(
                     children: [
                       Text(
                         'Batafsil',
                         style: TextStyle(
                           fontSize: 12.sp,
                           color: AppTheme.colors.primary,
                           fontWeight: FontWeight.bold,
                         ),
                       ),
                       Icon(
                         Icons.chevron_right_rounded,
                         size: 16.sp,
                         color: AppTheme.colors.primary,
                       ),
                     ],
                   )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceRow({
    required num amount,
    required String currency,
  }) {
    final Color color;
    if (amount == 0) {
      color = const Color(0xFF1E293B);
    } else if (amount > 0) {
      color = const Color(0xFF10B981);
    } else {
      color = const Color(0xFFEF4444);
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          _formatBalance(amount),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(width: 2.w),
        Text(
          currency,
          style: TextStyle(
            fontSize: 9.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
