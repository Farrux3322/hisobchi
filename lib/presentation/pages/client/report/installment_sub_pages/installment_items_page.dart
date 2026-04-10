import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hisobchi/application/installment_report/installment_sub_cubits.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/dto/models/installment_report/installment_report_models.dart';
import 'package:hisobchi/infrastructure/repository/installment_report/installment_report_repository.dart';
import 'package:hisobchi/presentation/assets/theme/app_theme.dart';
import 'package:hisobchi/presentation/components/back_button.dart';
import 'package:hisobchi/presentation/components/utils/phone_formatter.dart';
import 'package:hisobchi/presentation/components/utils/price_extension.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../features/payment_schedule/presentation/pages/installment_detail_page.dart';

class InstallmentItemsPage extends StatelessWidget {
  final String status;
  final String statusLabel;
  final int currencyTypeId;
  final String currencyLabel;
  final Color statusColor;

  const InstallmentItemsPage({
    super.key,
    required this.status,
    required this.statusLabel,
    required this.currencyTypeId,
    required this.currencyLabel,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InstallmentItemsCubit(InstallmentReportRepository())
        ..load(status: status, currencyTypeId: currencyTypeId),
      child: _ItemsView(
        statusLabel: statusLabel,
        currencyLabel: currencyLabel,
        statusColor: statusColor,
      ),
    );
  }
}

// ─── View ─────────────────────────────────────────────────────────────────────

class _ItemsView extends StatefulWidget {
  final String statusLabel;
  final String currencyLabel;
  final Color statusColor;

  const _ItemsView({
    required this.statusLabel,
    required this.currencyLabel,
    required this.statusColor,
  });

  @override
  State<_ItemsView> createState() => _ItemsViewState();
}

class _ItemsViewState extends State<_ItemsView> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent * 0.85) {
      final s = context.read<InstallmentItemsCubit>().state;
      if (!s.isLoadingMore && s.hasMore) {
        context.read<InstallmentItemsCubit>().loadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackArrowButton(),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.statusLabel,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: widget.statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(color: widget.statusColor.withValues(alpha: 0.30)),
              ),
              child: Text(
                widget.currencyLabel,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: widget.statusColor,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<InstallmentItemsCubit, ItemsState>(
        builder: (context, state) {
          final cubit = context.read<InstallmentItemsCubit>();
          final isLoading = state.status == Status.loading && state.items.isEmpty;

          return RefreshIndicator(
            onRefresh: () async {
              cubit.load(
                status: state.itemStatus,
                currencyTypeId: state.currencyTypeId,
              );
              await Future.delayed(const Duration(milliseconds: 400));
            },
            color: AppTheme.colors.primary,
            child: ListView(
              controller: _scroll,
              padding: EdgeInsets.fromLTRB(
                16.w,
                16.h,
                16.w,
                32.h + MediaQuery.of(context).padding.bottom,
              ),
              children: [
                if (isLoading)
                  _ItemsShimmer()
                else if (state.status == Status.error)
                  _ErrorCard(message: state.error ?? 'Xatolik yuz berdi')
                else if (state.items.isEmpty)
                  _EmptyCard(statusLabel: widget.statusLabel)
                else ...[
                  _CountBadge(
                    count: state.items.length,
                    hasMore: state.hasMore,
                    color: widget.statusColor,
                  ),
                  SizedBox(height: 10.h),
                  ...state.items.map(
                    (item) => GestureDetector(
                      onTap: (){
                        pushScreen(context, screen: InstallmentDetailPage(id: item.planId)).then((changed) {
                          // if (changed == true && context.mounted) {
                          //   context.read<InstallmentListCubit>().refresh();
                          // }
                        });
                      },
                      child: _ItemCard(
                        item: item,
                        currency: widget.currencyLabel,
                        statusColor: widget.statusColor,
                      ),
                    ),
                  ),
                  if (state.isLoadingMore) _LoadMoreShimmer(),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Count Badge ──────────────────────────────────────────────────────────────

class _CountBadge extends StatelessWidget {
  final int count;
  final bool hasMore;
  final Color color;

  const _CountBadge({required this.count, required this.hasMore, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            hasMore ? '$count+ ta to\'lov' : '$count ta to\'lov',
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: color),
          ),
        ),
      ],
    );
  }
}

// ─── Item Card ────────────────────────────────────────────────────────────────

Color _avatarColor(String name) {
  const colors = [
    Color(0xFF6366F1), Color(0xFF3B82F6), Color(0xFF22C55E),
    Color(0xFFF59E0B), Color(0xFF8B5CF6), Color(0xFF06B6D4),
    Color(0xFFEC4899), Color(0xFF10B981),
  ];
  if (name.isEmpty) return colors[0];
  final hash = name.codeUnits.fold(0, (a, b) => a + b);
  return colors[hash % colors.length];
}

class _ItemCard extends StatelessWidget {
  final InstallmentItemModel item;
  final String currency;
  final Color statusColor;

  const _ItemCard({
    required this.item,
    required this.currency,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final avatarColor = _avatarColor(item.partnerName);
    final amount = double.tryParse(item.amount) ?? 0;
    final paid = double.tryParse(item.paidAmount) ?? 0;
    final paidRatio = amount > 0 ? (paid / amount).clamp(0.0, 1.0) : 0.0;
    final paidPct = (paidRatio * 100).toStringAsFixed(0);
    final showProgress = paidRatio > 0;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: statusColor.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Left stripe ──
              Container(width: 4, color: statusColor),

              // ── Content ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ──
                    Padding(
                      padding: EdgeInsets.fromLTRB(12.w, 13.h, 12.w, 10.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar
                          Container(
                            width: 40.w,
                            height: 40.w,
                            decoration: BoxDecoration(
                              color: avatarColor.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: avatarColor.withValues(alpha: 0.25),
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                item.partnerName.isNotEmpty
                                    ? item.partnerName[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w800,
                                  color: avatarColor,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),

                          // Name + phone + due date
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.partnerName,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1E293B),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 3.h),
                                if (item.partnerPhone.isNotEmpty)
                                  Row(
                                    children: [
                                      Icon(Icons.phone_outlined, size: 10.sp, color: const Color(0xFFCBD5E1)),
                                      SizedBox(width: 3.w),
                                      Flexible(
                                        child: Text(
                                          PhoneFormatter.formatPhoneNumber(item.partnerPhone),
                                          style: TextStyle(fontSize: 10.sp, color: const Color(0xFF94A3B8)),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                SizedBox(height: 4.h),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today_outlined, size: 10.sp, color: const Color(0xFFCBD5E1)),
                                    SizedBox(width: 3.w),
                                    Text(
                                      item.dueDate,
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: const Color(0xFF64748B),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),

                          // Plan + item number badges
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  'Reja #${item.planId}',
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF475569),
                                  ),
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  '#${item.itemNumber}${item.isAdvance ? ' · Avans' : ''}',
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w700,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ── Progress Bar (only when partial payment exists) ──
                    if (showProgress) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "To'lov jarayoni",
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: const Color(0xFF94A3B8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  "$paidPct% to'landi",
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF22C55E),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5.h),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6.r),
                              child: SizedBox(
                                height: 6.h,
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: (paidRatio * 1000).toInt().clamp(1, 1000000),
                                      child: Container(color: const Color(0xFF22C55E)),
                                    ),
                                    Expanded(
                                      flex: ((1 - paidRatio) * 1000).toInt().clamp(1, 1000000),
                                      child: Container(color: statusColor.withValues(alpha: 0.20)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.h),
                    ],

                    // ── Divider ──
                    Container(height: 1, color: const Color(0xFFF1F5F9)),

                    // ── Amount Chips ──
                    Padding(
                      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 12.h),
                      child: Row(
                        children: [
                          Expanded(
                            child: _AmountChip(
                              label: 'Jami',
                              amount: item.amount,
                              currency: currency,
                              color: const Color(0xFF475569),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: _AmountChip(
                              label: "To'langan",
                              amount: item.paidAmount,
                              currency: currency,
                              color: const Color(0xFF22C55E),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: _AmountChip(
                              label: 'Qolgan',
                              amount: item.remaining,
                              currency: currency,
                              color: const Color(0xFF3B82F6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Amount Chip ─────────────────────────────────────────────────────────────

class _AmountChip extends StatelessWidget {
  final String label;
  final String amount;
  final String currency;
  final Color color;

  const _AmountChip({
    required this.label,
    required this.amount,
    required this.currency,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9.sp,
              color: const Color(0xFF94A3B8),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 3.h),
          Text(
            PriceFormatter.priceFormat(amount),
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800, color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            currency,
            style: TextStyle(
              fontSize: 8.sp,
              color: color.withValues(alpha: 0.65),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shimmer / Empty / Error ──────────────────────────────────────────────────

class _ItemsShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: Column(children: List.generate(6, (_) => _ShimmerCard())),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      height: 140.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
    );
  }
}

class _LoadMoreShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: Column(children: List.generate(2, (_) => _ShimmerCard())),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String statusLabel;
  const _EmptyCard({required this.statusLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 48.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 38.sp, color: const Color(0xFFCBD5E1)),
          SizedBox(height: 10.h),
          Text(
            "$statusLabel bo'yicha to'lovlar topilmadi",
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8)),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            "Bu toifada ma'lumot yo'q",
            style: TextStyle(fontSize: 11.sp, color: const Color(0xFFCBD5E1)),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.20)),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline_rounded, size: 36.sp, color: const Color(0xFFEF4444)),
          SizedBox(height: 8.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 13.sp,
              color: const Color(0xFFEF4444),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
