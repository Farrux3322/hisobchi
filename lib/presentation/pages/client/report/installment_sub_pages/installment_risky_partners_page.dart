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

class InstallmentRiskyPartnersPage extends StatelessWidget {
  const InstallmentRiskyPartnersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InstallmentRiskyCubit(InstallmentReportRepository())..load(),
      child: const _RiskyPartnersView(),
    );
  }
}

class _RiskyPartnersView extends StatefulWidget {
  const _RiskyPartnersView();

  @override
  State<_RiskyPartnersView> createState() => _RiskyPartnersViewState();
}

class _RiskyPartnersViewState extends State<_RiskyPartnersView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    setState(() {});
    if (!_tabController.indexIsChanging) return;
    final cubit = context.read<InstallmentRiskyCubit>();
    // Reload with currency filter when tab changes
    final currencyTypeId = _tabController.index == 0 ? 1 : 2;
    cubit.load(currencyTypeId: currencyTypeId);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackArrowButton(),
        title: const Text(
          'Muammoli mijozlar'
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(66),
          child: _CurrencyTabBar(controller: _tabController),
        ),
      ),
      body: BlocBuilder<InstallmentRiskyCubit, RiskyState>(
        builder: (context, state) {
          return TabBarView(
            controller: _tabController,
            children: [
              _RiskyTabContent(currencyTypeId: 1, currencyLabel: 'UZS', state: state),
              _RiskyTabContent(currencyTypeId: 2, currencyLabel: 'USD', state: state),
            ],
          );
        },
      ),
    );
  }
}

class _RiskyTabContent extends StatelessWidget {
  final int currencyTypeId;
  final String currencyLabel;
  final RiskyState state;

  const _RiskyTabContent({
    required this.currencyTypeId,
    required this.currencyLabel,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<InstallmentRiskyCubit>().load(currencyTypeId: currencyTypeId);
        await Future.delayed(const Duration(milliseconds: 400));
      },
      color: AppTheme.colors.primary,
      child: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
        children: [
          _Section(
            icon: Icons.warning_amber_rounded,
            iconColor: const Color(0xFFEF4444),
            child: state.status == Status.loading && state.data.isEmpty
                ? _SectionShimmer(height: 200.h)
                : state.data.isEmpty
                    ? const _EmptySection(message: "Muammoli hamkorlar yo'q")
                    : Column(
                        children: state.data
                            .map((p) => _RiskyPartnerCard(partner: p, currency: currencyLabel))
                            .toList(),
                      ),
          ),
        ],
      ),
    );
  }
}

// ─── Risky Partner Card ───────────────────────────────────────────────────────

class _RiskyPartnerCard extends StatelessWidget {
  final InstallmentRiskyPartnerModel partner;
  final String currency;

  const _RiskyPartnerCard({required this.partner, required this.currency});

  Color get _riskColor {
    switch (partner.riskLevel) {
      case 'high':
        return const Color(0xFFEF4444);
      case 'medium':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF22C55E);
    }
  }

  String get _riskLabel {
    switch (partner.riskLevel) {
      case 'high':
        return 'Yuqori';
      case 'medium':
        return "O'rta";
      default:
        return 'Past';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _riskColor.withValues(alpha: 0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(color: _riskColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    partner.partnerName.isNotEmpty ? partner.partnerName[0].toUpperCase() : '?',
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: _riskColor),
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
                    if (partner.partnerPhone.isNotEmpty)
                      Text(
                        _formatPhone(partner.partnerPhone),
                        style: TextStyle(fontSize: 11.sp, color: const Color(0xFF94A3B8)),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: _riskColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${partner.riskScore} %', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w900, color: _riskColor)),
                        Text(' xavf', style: TextStyle(fontSize: 9.sp, color: _riskColor.withValues(alpha: 0.8))),
                      ],
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(_riskLabel, style: TextStyle(fontSize: 10.sp, color: _riskColor, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _RiskyMiniStat(
                  label: "Muddati o'tgan to'lovlar",
                  value: '${partner.overdueItems} ta',
                  color: const Color(0xFFEF4444),
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: _RiskyMiniStat(
                  label: "O'rtacha kechikish",
                  value: '${partner.avgDaysOverdue} kun',
                  color: const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          _RiskyRemainingCard(
            amount: PriceFormatter.priceFormat(partner.totalRemaining),
            currency: currency,
          ),
        ],
      ),
    );
  }
}

class _RiskyMiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _RiskyMiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(7.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 9.sp, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
          SizedBox(height: 2.h),
          Text(value, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _RiskyRemainingCard extends StatelessWidget {
  final String amount;
  final String currency;

  const _RiskyRemainingCard({required this.amount, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border(left: BorderSide(color: const Color(0xFFEF4444), width: 3.w)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Qolgan qarz',
                  style: TextStyle(fontSize: 9.sp, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 2.h),
                Text(
                  amount,
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: const Color(0xFFEF4444)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              currency,
              style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w700, color: const Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared Helpers ───────────────────────────────────────────────────────────

String _formatPhone(String phone) {
  final clean = phone.replaceAll(RegExp(r'\D'), '');
  if (clean.length == 9) {
    return '+998 ${clean.substring(0, 2)} ${clean.substring(2, 5)} ${clean.substring(5, 7)} ${clean.substring(7, 9)}';
  } else if (clean.length == 12 && clean.startsWith('998')) {
    return '+998 ${clean.substring(3, 5)} ${clean.substring(5, 8)} ${clean.substring(8, 10)} ${clean.substring(10, 12)}';
  }
  return phone;
}

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
  final IconData icon;
  final Color? iconColor;
  final Widget child;
  final Widget? trailing;

  const _Section({
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
      child:child,
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
