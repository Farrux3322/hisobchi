import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ehisob/infrastructure/dto/models/partner/partner_model.dart';
import 'package:ehisob/presentation/assets/asset_index.dart';
import 'package:ehisob/presentation/components/utils/phone_formatter.dart';
import 'package:shimmer/shimmer.dart';

class ClientCardItem extends StatelessWidget {
  final PartnerModel? partnerModel;
  final VoidCallback? onTap;

  const ClientCardItem({super.key, required this.partnerModel, this.onTap});

  String _formatBalance(num amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final parts = absAmount.toStringAsFixed(0).split('.');
    final integerPart = parts[0];

    String formatted = '';
    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        formatted += ' ';
      }
      formatted += integerPart[i];
    }

    return '${isNegative ? '-' : ''}$formatted';
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'M';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDeleted = partnerModel?.deletedAt != null;
    final num uzs = partnerModel?.balance?.uzs ?? 0;
    final num usd = partnerModel?.balance?.usd ?? 0;
    final bool hasDebt = uzs < 0 || usd < 0;
    final bool hasCredit = uzs > 0 || usd > 0;

    final String statusText;
    final Color statusColor;
    final Color statusBg;
    if (hasDebt) {
      statusText = 'Qarzdor';
      statusColor = const Color(0xFFEF4444);
      statusBg = const Color(0xFFFEF2F2);
    } else if (hasCredit) {
      statusText = 'Haqdor';
      statusColor = const Color(0xFF10B981);
      statusBg = const Color(0xFFECFDF5);
    } else {
      statusText = 'Hisob 0';
      statusColor = const Color(0xFF64748B);
      statusBg = const Color(0xFFF1F5F9);
    }

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDeleted ? Colors.red.shade200 : const Color(0xFFF1F5F9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.colors.primary.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18.r),
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Avatar, Name & Phone, Status Pill & Balances
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Container(
                      width: 46.r,
                      height: 46.r,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14.r),
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.colors.primary.withValues(alpha: 0.15),
                            const Color(0xFF6366F1).withValues(alpha: 0.2),
                          ],
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14.r),
                        child: (partnerModel?.files != null && partnerModel!.files!.isNotEmpty)
                            ? CachedNetworkImage(
                                imageUrl: partnerModel!.files!.first.url ?? '',
                                width: 46.r,
                                height: 46.r,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Shimmer.fromColors(
                                  baseColor: const Color(0xFFF1F5F9),
                                  highlightColor: Colors.white,
                                  child: Container(width: 46.r, height: 46.r, color: Colors.white),
                                ),
                                errorWidget: (context, url, error) => Center(
                                  child: Text(
                                    _getInitials(partnerModel?.name ?? ''),
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.colors.primary,
                                    ),
                                  ),
                                ),
                              )
                            : Center(
                                child: Text(
                                  _getInitials(partnerModel?.name ?? ''),
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.colors.primary,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    SizedBox(width: 12.w),

                    // Name, Phone & Status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  partnerModel?.name ?? 'Noma\'lum',
                                  style: TextStyle(
                                    fontSize: 14.5.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1E293B),
                                    letterSpacing: -0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  color: statusBg,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  statusText,
                                  style: TextStyle(
                                    fontSize: 10.5.sp,
                                    fontWeight: FontWeight.w700,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            PhoneFormatter.formatPhoneNumber(partnerModel?.phone ?? ''),
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10.h),

                // Balance summary row
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildBalanceItem('UZS', uzs),
                      Container(width: 1, height: 20.h, color: const Color(0xFFE2E8F0)),
                      _buildBalanceItem('USD', usd),
                    ],
                  ),
                ),

                if (partnerModel?.installmentRemaining?.hasAnyValue == true) ...[
                  SizedBox(height: 8.h),
                  _InstallmentRow(remaining: partnerModel!.installmentRemaining!),
                ],

                SizedBox(height: 10.h),

                // Footer: Date & Activity
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(AppIcons.date, width: 12.sp, height: 12.sp),
                        SizedBox(width: 5.w),
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
                    if ((partnerModel?.activity ?? '').isNotEmpty)
                      Flexible(
                        child: Text(
                          partnerModel?.activity ?? '',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceItem(String currency, num amount) {
    final Color color;
    if (amount == 0) {
      color = const Color(0xFF64748B);
    } else if (amount > 0) {
      color = const Color(0xFF10B981);
    } else {
      color = const Color(0xFFEF4444);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$currency: ',
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
        ),
        Text(
          _formatBalance(amount),
          style: TextStyle(
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

class _InstallmentRow extends StatelessWidget {
  final InstallmentRemaining remaining;
  const _InstallmentRow({required this.remaining});

  static String _fmt(num v) {
    final raw = v.abs().toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      if (i > 0 && (raw.length - i) % 3 == 0) buf.write(' ');
      buf.write(raw[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final uzs = remaining.uzs ?? 0;
    final usd = remaining.usd ?? 0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFFEF3C7)),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_month_outlined, size: 13.sp, color: const Color(0xFFD97706)),
          SizedBox(width: 6.w),
          Text(
            "Muddatli to'lov:",
            style: TextStyle(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF92400E),
            ),
          ),
          const Spacer(),
          if (uzs != 0)
            Text(
              '${_fmt(uzs)} UZS',
              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800, color: const Color(0xFFB45309)),
            ),
          if (uzs != 0 && usd != 0) SizedBox(width: 8.w),
          if (usd != 0)
            Text(
              '${_fmt(usd)} USD',
              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800, color: const Color(0xFFB45309)),
            ),
        ],
      ),
    );
  }
}
