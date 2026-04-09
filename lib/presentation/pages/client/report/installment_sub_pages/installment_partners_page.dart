import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hisobchi/application/installment_report/installment_sub_cubits.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/infrastructure/dto/models/installment_report/installment_report_models.dart';
import 'package:hisobchi/infrastructure/repository/installment_report/installment_report_repository.dart';
import 'package:hisobchi/presentation/assets/theme/app_theme.dart';
import 'package:hisobchi/presentation/components/back_button.dart';
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
          "Hamkorlar bo'yicha",
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
      final state = context.read<InstallmentPartnersCubit>().state;
      if (!state.isLoadingMore && state.hasMoreFor(widget.currencyTypeId)) {
        context.read<InstallmentPartnersCubit>().loadMore(widget.currencyTypeId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final cubit = context.read<InstallmentPartnersCubit>();
    final partners = state.forCurrency(widget.currencyTypeId);

    return RefreshIndicator(
      onRefresh: () async {
        cubit.load(sort: state.sort);
        await Future.delayed(const Duration(milliseconds: 400));
      },
      color: AppTheme.colors.primary,
      child: ListView(
        controller: _scroll,
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
        children: [
          _Section(
            title: "Hamkorlar bo'yicha",
            icon: Icons.people_alt_outlined,
            iconColor: const Color(0xFFF59E0B),
            trailing: _SortSelector(
              sort: state.sort,
              onChanged: (s) => cubit.changeSort(s),
            ),
            child: state.status == Status.loading && partners.isEmpty
                ? _SectionShimmer(height: 240.h)
                : partners.isEmpty
                    ? const _EmptySection(message: 'Hamkorlar topilmadi')
                    : Column(
                        children: [
                          ...partners.map((p) => _PartnerCard(partner: p, currency: widget.currencyLabel)),
                          if (state.isLoadingMore)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              child: Center(
                                child: SizedBox(
                                  width: 22.w,
                                  height: 22.w,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.colors.primary),
                                ),
                              ),
                            ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}

// ─── Partner Card ─────────────────────────────────────────────────────────────

class _PartnerCard extends StatelessWidget {
  final InstallmentPartnerReportModel partner;
  final String currency;

  const _PartnerCard({required this.partner, required this.currency});

  @override
  Widget build(BuildContext context) {
    final hasOverdue = (double.tryParse(partner.overdueAmount) ?? 0) > 0;
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: hasOverdue
              ? const Color(0xFFEF4444).withValues(alpha: 0.15)
              : const Color(0xFF94A3B8).withValues(alpha: 0.08),
        ),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(color: AppTheme.colors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    partner.partnerName.isNotEmpty ? partner.partnerName[0].toUpperCase() : '?',
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: AppTheme.colors.primary),
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
                    Row(
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 11.sp, color: const Color(0xFF94A3B8)),
                        SizedBox(width: 3.w),
                        Text('${partner.activePlans} faol reja', style: TextStyle(fontSize: 11.sp, color: const Color(0xFF94A3B8))),
                        if (partner.lastPaymentAt != null) ...[
                          SizedBox(width: 8.w),
                          Icon(Icons.access_time_rounded, size: 11.sp, color: const Color(0xFF94A3B8)),
                          SizedBox(width: 3.w),
                          Text(partner.lastPaymentAt!, style: TextStyle(fontSize: 11.sp, color: const Color(0xFF94A3B8))),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    PriceFormatter.priceFormat(partner.totalRemaining),
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: const Color(0xFF3B82F6)),
                  ),
                  Text(currency, style: TextStyle(fontSize: 10.sp, color: Colors.black54, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(child: _PartnerAmountRow(label: 'Berilgan', amount: partner.totalGiven, currency: currency, color: const Color(0xFF475569))),
              SizedBox(width: 8.w),
              Expanded(child: _PartnerAmountRow(label: "To'langan", amount: partner.totalPaid, currency: currency, color: const Color(0xFF22C55E))),
              if (hasOverdue) ...[
                SizedBox(width: 8.w),
                Expanded(child: _PartnerAmountRow(label: "Muddati o'tgan", amount: partner.overdueAmount, currency: currency, color: const Color(0xFFEF4444))),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _PartnerAmountRow extends StatelessWidget {
  final String label;
  final String amount;
  final String currency;
  final Color color;

  const _PartnerAmountRow({required this.label, required this.amount, required this.currency, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 9.sp, color: const Color(0xFF94A3B8))),
        Text(
          '${PriceFormatter.priceFormat(amount)} $currency',
          style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700, color: color),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _SortSelector extends StatelessWidget {
  final String sort;
  final ValueChanged<String> onChanged;

  const _SortSelector({required this.sort, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SortChip(label: 'Qolgan', value: 'remaining', current: sort, onChanged: onChanged),
        SizedBox(width: 4.w),
        _SortChip(label: 'Berilgan', value: 'total_given', current: sort, onChanged: onChanged),
      ],
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final String value;
  final String current;
  final ValueChanged<String> onChanged;

  const _SortChip({required this.label, required this.value, required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final selected = current == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: selected ? AppTheme.colors.primary : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: selected ? Colors.white : const Color(0xFF64748B)),
        ),
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
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
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

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final Widget child;
  final Widget? trailing;

  const _Section({
    required this.title,
    required this.icon,
    this.iconColor,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14.sp, color: iconColor ?? AppTheme.colors.primary),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(title, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B))),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }
}

class _SectionShimmer extends StatelessWidget {
  final double height;
  const _SectionShimmer({required this.height});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: Container(height: height, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.r))),
    );
  }
}

class _EmptySection extends StatelessWidget {
  final String message;
  const _EmptySection({this.message = "Ma'lumot topilmadi"});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Text(message, style: TextStyle(fontSize: 13.sp, color: const Color(0xFF94A3B8))),
      ),
    );
  }
}
