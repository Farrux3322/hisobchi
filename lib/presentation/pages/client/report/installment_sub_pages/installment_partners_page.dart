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
import 'package:shimmer/shimmer.dart';

class InstallmentPartnersPage extends StatelessWidget {
  const InstallmentPartnersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InstallmentPartnersCubit(InstallmentReportRepository())..load(),
      child: const _PartnersView(),
    );
  }
}

class _PartnersView extends StatefulWidget {
  const _PartnersView();

  @override
  State<_PartnersView> createState() => _PartnersViewState();
}

class _PartnersViewState extends State<_PartnersView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackArrowButton(),
        title: const Text(
          "Mijozlar bo'yicha",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(66),
          child: _CurrencyTabBar(controller: _tabController),
        ),
      ),
      body: BlocBuilder<InstallmentPartnersCubit, PartnersState>(
        builder: (context, state) {
          return TabBarView(
            controller: _tabController,
            children: [
              _PartnersTabContent(currencyTypeId: 1, currencyLabel: 'UZS', state: state),
              _PartnersTabContent(currencyTypeId: 2, currencyLabel: 'USD', state: state),
            ],
          );
        },
      ),
    );
  }
}

// ─── Tab Content ──────────────────────────────────────────────────────────────

class _PartnersTabContent extends StatefulWidget {
  final int currencyTypeId;
  final String currencyLabel;
  final PartnersState state;

  const _PartnersTabContent({
    required this.currencyTypeId,
    required this.currencyLabel,
    required this.state,
  });

  @override
  State<_PartnersTabContent> createState() => _PartnersTabContentState();
}

class _PartnersTabContentState extends State<_PartnersTabContent> {
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
      final s = context.read<InstallmentPartnersCubit>().state;
      if (!s.isLoadingMore && s.hasMoreFor(widget.currencyTypeId)) {
        context.read<InstallmentPartnersCubit>().loadMore(widget.currencyTypeId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final cubit = context.read<InstallmentPartnersCubit>();
    final partners = state.forCurrency(widget.currencyTypeId);
    final isLoading = state.status == Status.loading && partners.isEmpty;

    return RefreshIndicator(
      onRefresh: () async {
        cubit.load(sort: state.sort);
        await Future.delayed(const Duration(milliseconds: 400));
      },
      color: AppTheme.colors.primary,
      child: ListView(
        controller: _scroll,
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h + MediaQuery.of(context).padding.bottom),
        children: [
          // ── Sort Bar ──
          _SortBar(
            sort: state.sort,
            isLoading: isLoading,
            onChanged: (s) => cubit.changeSort(s),
          ),
          SizedBox(height: 14.h),

          // ── Content ──
          if (isLoading)
            _PartnersShimmer()
          else if (partners.isEmpty)
            _EmptyCard()
          else ...[
            Padding(
              padding: EdgeInsets.only(bottom: 10.h, left: 2.w),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      '${partners.length} ta mijoz',
                      style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: const Color(0xFFF59E0B)),
                    ),
                  ),
                ],
              ),
            ),
            ...partners.map((p) => _PartnerCard(partner: p, currency: widget.currencyLabel, sort: state.sort)),
            if (state.isLoadingMore) _LoadMoreShimmer(),
          ],
        ],
      ),
    );
  }
}

// ─── Sort Bar ─────────────────────────────────────────────────────────────────

class _SortBar extends StatelessWidget {
  final String sort;
  final bool isLoading;
  final ValueChanged<String> onChanged;

  const _SortBar({required this.sort, required this.isLoading, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const options = [
      ('remaining', Icons.hourglass_bottom_rounded, 'Qolgan summa'),
      ('total_given', Icons.account_balance_wallet_outlined, 'Berilgan summa'),
    ];

    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: options.map((opt) {
          final value = opt.$1;
          final icon = opt.$2;
          final label = opt.$3;
          final selected = sort == value;
          return Expanded(
            child: GestureDetector(
              onTap: isLoading ? null : () => onChanged(value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                margin: EdgeInsets.all(3.r),
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.colors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: selected
                      ? [BoxShadow(color: AppTheme.colors.primary.withValues(alpha: 0.30), blurRadius: 8, offset: const Offset(0, 3))]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 14.sp, color: selected ? Colors.white : const Color(0xFF94A3B8)),
                    SizedBox(width: 6.w),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: selected ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Partner Card ─────────────────────────────────────────────────────────────

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

class _PartnerCard extends StatelessWidget {
  final InstallmentPartnerReportModel partner;
  final String currency;
  final String sort;

  const _PartnerCard({required this.partner, required this.currency, required this.sort});

  @override
  Widget build(BuildContext context) {
    final avatarColor = _avatarColor(partner.partnerName);
    final totalGiven = double.tryParse(partner.totalGiven) ?? 0;
    final totalPaid = double.tryParse(partner.totalPaid) ?? 0;
    final totalRemaining = double.tryParse(partner.totalRemaining) ?? 0;
    final overdue = double.tryParse(partner.overdueAmount) ?? 0;
    final hasOverdue = overdue > 0;

    final paidRatio = totalGiven > 0 ? (totalPaid / totalGiven).clamp(0.0, 1.0) : 0.0;
    final overdueRatio = totalGiven > 0 ? (overdue / totalGiven).clamp(0.0, 1.0) : 0.0;
    final pendingRatio = totalGiven > 0 ? ((totalRemaining - overdue) / totalGiven).clamp(0.0, 1.0) : 0.0;
    final paidPct = (paidRatio * 100).toStringAsFixed(0);

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: hasOverdue
              ? const Color(0xFFEF4444).withValues(alpha: 0.20)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: hasOverdue
                ? const Color(0xFFEF4444).withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 10.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42.w,
                  height: 42.w,
                  decoration: BoxDecoration(
                    color: avatarColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: avatarColor.withValues(alpha: 0.25), width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      partner.partnerName.isNotEmpty ? partner.partnerName[0].toUpperCase() : '?',
                      style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w800, color: avatarColor),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        partner.partnerName,
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: AppTheme.colors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(5.r),
                            ),
                            child: Text(
                              '${partner.activePlans} faol reja',
                              style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: AppTheme.colors.primary),
                            ),
                          ),
                          if (partner.partnerPhone.isNotEmpty) ...[
                            SizedBox(width: 6.w),
                            Icon(Icons.phone_outlined, size: 10.sp, color: const Color(0xFFCBD5E1)),
                            SizedBox(width: 2.w),
                            Flexible(
                              child: Text(
                                PhoneFormatter.formatPhoneNumber(partner.partnerPhone),
                                style: TextStyle(fontSize: 10.sp, color: const Color(0xFF94A3B8)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (partner.lastPaymentAt != null) ...[
                        SizedBox(height: 3.h),
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded, size: 10.sp, color: const Color(0xFFCBD5E1)),
                            SizedBox(width: 3.w),
                            Text(
                              "So'ngi: ${partner.lastPaymentAt}",
                              style: TextStyle(fontSize: 10.sp, color: const Color(0xFFCBD5E1), fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      sort == 'total_given'
                          ? PriceFormatter.priceFormat(partner.totalGiven)
                          : PriceFormatter.priceFormat(partner.totalRemaining),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: sort == 'total_given' ? const Color(0xFF475569) : const Color(0xFF3B82F6),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(currency, style: TextStyle(fontSize: 9.sp, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
                        SizedBox(width: 3.w),
                        Text(
                          sort == 'total_given' ? 'berilgan' : 'qoldi',
                          style: TextStyle(fontSize: 9.sp, color: const Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Progress Bar ──
          if (totalGiven > 0) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "To'lov jarayoni",
                        style: TextStyle(fontSize: 10.sp, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "$paidPct% to'landi",
                        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700, color: const Color(0xFF22C55E)),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6.r),
                    child: SizedBox(
                      height: 7.h,
                      child: Row(
                        children: [
                          if (paidRatio > 0)
                            Expanded(
                              flex: (paidRatio * 1000).toInt().clamp(1, 1000000),
                              child: Container(color: const Color(0xFF22C55E)),
                            ),
                          if (pendingRatio > 0)
                            Expanded(
                              flex: (pendingRatio * 1000).toInt().clamp(1, 1000000),
                              child: Container(color: const Color(0xFF3B82F6).withValues(alpha: 0.30)),
                            ),
                          if (overdueRatio > 0)
                            Expanded(
                              flex: (overdueRatio * 1000).toInt().clamp(1, 1000000),
                              child: Container(color: const Color(0xFFEF4444)),
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
            padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 12.h),
            child: Row(
              children: [
                Expanded(child: _AmountChip(label: 'Berilgan', amount: partner.totalGiven, currency: currency, color: const Color(0xFF475569))),
                SizedBox(width: 8.w),
                Expanded(child: _AmountChip(label: "To'langan", amount: partner.totalPaid, currency: currency, color: const Color(0xFF22C55E))),
                if (hasOverdue) ...[
                  SizedBox(width: 8.w),
                  Expanded(child: _AmountChip(label: "Muddati o'tgan", amount: partner.overdueAmount, currency: currency, color: const Color(0xFFEF4444), isAlert: true)),
                ],
              ],
            ),
          ),
        ],
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
  final bool isAlert;

  const _AmountChip({required this.label, required this.amount, required this.currency, required this.color, this.isAlert = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isAlert ? 0.07 : 0.05),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withValues(alpha: isAlert ? 0.25 : 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isAlert) ...[
                Icon(Icons.warning_amber_rounded, size: 9.sp, color: color),
                SizedBox(width: 2.w),
              ],
              Flexible(
                child: Text(label, style: TextStyle(fontSize: 9.sp, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Text(PriceFormatter.priceFormat(amount), style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(currency, style: TextStyle(fontSize: 8.sp, color: color.withValues(alpha: 0.65), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─── Shimmer Skeletons ────────────────────────────────────────────────────────

class _PartnersShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: Column(children: List.generate(5, (_) => _ShimmerCard())),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 42.w, height: 42.w, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(height: 13.h, width: 140.w, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6.r))),
                  SizedBox(height: 6.h),
                  Container(height: 10.h, width: 90.w, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6.r))),
                ]),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Container(height: 13.h, width: 70.w, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6.r))),
                SizedBox(height: 5.h),
                Container(height: 10.h, width: 40.w, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6.r))),
              ]),
            ],
          ),
          SizedBox(height: 12.h),
          Container(height: 7.h, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6.r))),
          SizedBox(height: 12.h),
          Row(
            children: [0, 1, 2].expand((i) => [
              if (i > 0) SizedBox(width: 8.w),
              Expanded(child: Container(height: 52.h, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.r)))),
            ]).toList(),
          ),
        ],
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

// ─── Empty Card ───────────────────────────────────────────────────────────────

class _EmptyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 48.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Icon(Icons.people_outline_rounded, size: 38.sp, color: const Color(0xFFCBD5E1)),
          SizedBox(height: 10.h),
          Text('Mijozlar topilmadi', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8))),
          SizedBox(height: 4.h),
          Text("Muddatli to'lov ma'lumotlari yo'q", style: TextStyle(fontSize: 11.sp, color: const Color(0xFFCBD5E1))),
        ],
      ),
    );
  }
}

// ─── Shared Helpers ───────────────────────────────────────────────────────────

class _CurrencyTabBar extends StatelessWidget {
  final TabController controller;
  const _CurrencyTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Container(
          height: 46,
          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              _TabItem(label: 'UZS Hisob', selected: controller.index == 0, onTap: () => controller.animateTo(0)),
              _TabDivider(),
              _TabItem(label: 'USD Hisob', selected: controller.index == 1, onTap: () => controller.animateTo(1)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabItem({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              color: selected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 2, height: 12, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 2),
          Container(width: 2, height: 12, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2))),
        ],
      );
}
