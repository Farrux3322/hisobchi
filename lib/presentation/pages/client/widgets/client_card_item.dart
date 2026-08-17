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
    // final bool isUZSPositive = (partnerModel?.balance?.uzs ?? 0) >= 0;
    // final bool isUSDPositive = (partnerModel?.balance?.usd ?? 0) >= 0;

    final bool isDeleted = partnerModel?.deletedAt != null;

    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 7.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 8))],
            border: Border.all(color: !isDeleted ? const Color(0xFFF1F5F9) : Colors.red.shade200, width: !isDeleted ? 1 : 1.5),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20.r),
              child: Opacity(
                opacity: isDeleted ? 0.7 : 1.0,
                child: ColorFiltered(
                  colorFilter: isDeleted
                      ? const ColorFilter.matrix([0.2126, 0.7152, 0.0722, 0, 0, 0.2126, 0.7152, 0.0722, 0, 0, 0.2126, 0.7152, 0.0722, 0, 0, 0, 0, 0, 1, 0])
                      : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
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
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
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
                                  placeholder: (context, url) => Shimmer.fromColors(
                                    baseColor: const Color(0xFFF1F5F9),
                                    highlightColor: Colors.white,
                                    child: Container(width: 48.w, height: 48.w, color: Colors.white),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    width: 48.w,
                                    height: 48.w,
                                    color: const Color(0xFFF1F5F9),
                                    child: Icon(Icons.person_rounded, color: const Color(0xFFCBD5E1), size: 24.sp),
                                  ),
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
                                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B), height: 1.2),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                    Text(
                                      PhoneFormatter.formatPhoneNumber(partnerModel?.phone ?? ''),
                                      style: TextStyle(fontSize: 10.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w600, letterSpacing: 0.3),
                                    ),
                                ],
                              ),
                            ),

                            // Balance section
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _buildBalanceRow(amount: partnerModel?.balance?.uzs ?? 0, currency: 'UZS'),
                                SizedBox(height: 4.h),
                                _buildBalanceRow(amount: partnerModel?.balance?.usd ?? 0, currency: 'USD'),
                              ],
                            ),
                          ],
                        ),

                        if (partnerModel?.installmentRemaining?.hasAnyValue == true) ...[
                          SizedBox(height: 10.h),
                          _InstallmentRow(remaining: partnerModel!.installmentRemaining!),
                        ],

                        SizedBox(height: 12.h),

                        // Footer
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SvgPicture.asset(AppIcons.date),
                                SizedBox(width: 4.w),
                                Text(
                                  partnerModel?.createdAt?.split(" ").first ?? '',
                                  style: TextStyle(fontSize: 11.sp, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Flexible(
                                    child: Text(
                                      partnerModel?.activity ?? '',
                                      style: TextStyle(fontSize: 11.sp, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (isDeleted)
          Positioned(
            bottom: 12.h,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: const Color(0xFFFCA5A5), width: 0.5),
                  boxShadow: [BoxShadow(color: Colors.red.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(AppIcons.delete, width: 14, height: 14),
                    SizedBox(width: 4.w),
                    Text(
                      'O\'chirilgan',
                      style: TextStyle(fontSize: 10.sp, color: const Color(0xFFB91C1C), fontWeight: FontWeight.w700, letterSpacing: 0.2),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _fmtNum(num amount) {
    final abs = amount.abs();
    final raw = abs.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      if (i > 0 && (raw.length - i) % 3 == 0) buf.write(' ');
      buf.write(raw[i]);
    }
    return buf.toString();
  }

  Widget _buildBalanceRow({required num amount, required String currency}) {
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
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: color, letterSpacing: -0.5),
        ),
        SizedBox(width: 2.w),
        Text(
          currency,
          style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w700, color: Colors.black54),
        ),
      ],
    );
  }
}

// ─── Installment remaining row ────────────────────────────────────────────────

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
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFFBBF24).withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_month_outlined, size: 13.sp, color: const Color(0xFFD97706)),
          SizedBox(width: 6.w),
          Text(
            "Muddatli to'lov:",
            style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: const Color(0xFF92400E)),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (uzs != 0) _Chip(amount: _fmt(uzs), currency: 'UZS'),
              if (uzs != 0 && usd != 0) SizedBox(height: 2.h),
              if (usd != 0) _Chip(amount: _fmt(usd), currency: 'USD'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String amount;
  final String currency;
  const _Chip({required this.amount, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          amount,
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: const Color(0xFFB45309), letterSpacing: -0.3),
        ),
        SizedBox(width: 2.w),
        Text(
          currency,
          style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w700, color: const Color(0xFFD97706)),
        ),
      ],
    );
  }
}
