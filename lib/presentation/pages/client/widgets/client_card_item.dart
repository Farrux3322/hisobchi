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
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: partnerModel?.deletedAt == null ? AppTheme.colors.divider : Colors.red.shade200),
        boxShadow: [BoxShadow(color: AppTheme.colors.divider, blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Avatar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: CachedNetworkImage(
                        
                        imageUrl: (partnerModel?.files ?? []).isNotEmpty
                            ? partnerModel?.files?.first ?? ''
                            : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQEM7h-3_xucDg6PXVOyOxh9QOnMkS0dvydRA&s',
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => CupertinoActivityIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                    SizedBox(width: 14.w),

                    // Name and Balance
                    Expanded(
                      child: Text(
                        partnerModel?.name ?? '',
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppTheme.colors.black),
                      ),
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              _formatBalance(partnerModel?.balance?.uzs ?? 0),
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: (partnerModel?.balance?.uzs ?? 0) >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                              ),
                            ),
                            Text(
                              ' UZS',
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w600,
                                color: (partnerModel?.balance?.uzs ?? 0) >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 8.w),
                        Row(
                          children: [
                            Text(
                              _formatBalance(partnerModel?.balance?.usd ?? 0),
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: (partnerModel?.balance?.usd ?? 0) >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                              ),
                            ),
                            Text(
                              ' USD',
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w600,
                                color: (partnerModel?.balance?.uzs ?? 0) >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),

                SizedBox(height: 10.h),

                // Phone and Date
                Container(
                  padding: EdgeInsets.symmetric(horizontal:  12,vertical: 6.w),
                  decoration: BoxDecoration(color: AppTheme.colors.colorF9F9FD, borderRadius: BorderRadius.circular(8.r)),
                  child: Row(
                    children: [
                      SvgPicture.asset(AppIcons.phone),
                      SizedBox(width: 6.w),
                      Text(
                        PhoneFormatter.formatPhoneNumber(partnerModel?.phone ?? ''),
                        style: TextStyle(fontSize: 12.sp, color: AppTheme.colors.gray),
                      ),
                      Spacer(),
                      SvgPicture.asset(AppIcons.date),
                      SizedBox(width: 6.w),
                      Text(
                        partnerModel?.createdAt?.split(" ").first ?? '',
                        style: TextStyle(fontSize: 12.sp, color: AppTheme.colors.gray),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
