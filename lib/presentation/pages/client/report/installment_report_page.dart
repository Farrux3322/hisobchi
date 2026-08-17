import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ehisob/application/installment_report/installment_report_bloc.dart';
import 'package:ehisob/application/installment_report/installment_report_event.dart';
import 'package:ehisob/application/installment_report/installment_report_state.dart';
import 'package:ehisob/domain/common/constants.dart';
import 'package:ehisob/infrastructure/dto/models/installment_report/installment_report_models.dart';
import 'package:ehisob/infrastructure/repository/installment_report/installment_report_repository.dart';
import 'package:ehisob/presentation/assets/theme/app_theme.dart';
import 'package:ehisob/presentation/components/back_button.dart';
import 'package:ehisob/presentation/components/utils/price_extension.dart';
import 'package:shimmer/shimmer.dart';
import 'installment_sub_pages/installment_recovery_page.dart';
import 'installment_sub_pages/installment_forecast_page.dart';
import 'installment_sub_pages/installment_monthly_page.dart';
import 'installment_sub_pages/installment_risky_partners_page.dart';
import 'installment_sub_pages/installment_partners_page.dart';

class InstallmentReportPage extends StatelessWidget {
  const InstallmentReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InstallmentReportBloc(repo: InstallmentReportRepository())
        ..add(const LoadInstallmentSummaryOnlyEvent()),
      child: const _InstallmentReportView(),
    );
  }
}

// ─── Main View ────────────────────────────────────────────────────────────────

class _InstallmentReportView extends StatefulWidget {
  const _InstallmentReportView();

  @override
  State<_InstallmentReportView> createState() => _InstallmentReportViewState();
}

class _InstallmentReportViewState extends State<_InstallmentReportView>
    with SingleTickerProviderStateMixin {
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackArrowButton(),
        title: const Text(
          "Muddatli to'lov hisoboti",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(66),
          child: _CurrencyTabBar(controller: _tabController),
        ),
      ),
      body: BlocBuilder<InstallmentReportBloc, InstallmentReportState>(
        builder: (context, state) {
          if (state.summaryStatus == Status.loading && state.summaries.isEmpty) {
            return _Shimmer();
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _CurrencyTabContent(currencyTypeId: 1, currencyLabel: 'UZS'),
              _CurrencyTabContent(currencyTypeId: 2, currencyLabel: 'USD'),
            ],
          );
        },
      ),
    );
  }
}

// ─── Currency Tab Bar ─────────────────────────────────────────────────────────

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

// ─── Per-currency Tab Content ─────────────────────────────────────────────────

class _CurrencyTabContent extends StatelessWidget {
  final int currencyTypeId;
  final String currencyLabel;
  const _CurrencyTabContent({required this.currencyTypeId, required this.currencyLabel});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InstallmentReportBloc, InstallmentReportState>(
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () async {
            context.read<InstallmentReportBloc>().add(const LoadInstallmentSummaryOnlyEvent());
            await Future.delayed(const Duration(milliseconds: 400));
          },
          color: AppTheme.colors.primary,
          child: ListView(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h+MediaQuery.of(context).padding.bottom),
            children: [
              // 1. Summary
              _SummarySection(
                summary: state.summaryFor(currencyTypeId),
                status: state.summaryStatus,
                currency: currencyLabel,
              ),
              SizedBox(height: 20.h),

              // 2. Section label
              Padding(
                padding: EdgeInsets.only(left: 2.w, bottom: 10.h),
                child: Text(
                  "Hisobot bo'limlari",
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.3,
                  ),
                ),
              ),

              // 3. Navigation entry cards
              _ReportEntryCard(
                icon: Icons.trending_up_rounded,
                color: const Color(0xFF22C55E),
                title: 'Undirish samaradorligi',
                subtitle: "To'lov samaradorligi va undirilgan summalar",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InstallmentRecoveryPage())),
              ),
              SizedBox(height: 10.h),
              _ReportEntryCard(
                icon: Icons.calendar_month_rounded,
                color: const Color(0xFF6366F1),
                title: "Kutilayotgan to'lovlar",
                subtitle: '30/60/90 kunlik prognoz',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InstallmentForecastPage())),
              ),
              SizedBox(height: 10.h),
              _ReportEntryCard(
                icon: Icons.bar_chart_rounded,
                color: const Color(0xFF3B82F6),
                title: 'Oylik dinamika',
                subtitle: "Oylar bo'yicha to'lov grafigi",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InstallmentMonthlyPage())),
              ),
              SizedBox(height: 10.h),
              _ReportEntryCard(
                icon: Icons.warning_amber_rounded,
                color: const Color(0xFFEF4444),
                title: 'Muammoli mijozlar',
                subtitle: "Kechiktirilgan va xavfli mijozlar ro'yxati",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InstallmentRiskyPartnersPage())),
              ),
              SizedBox(height: 10.h),
              _ReportEntryCard(
                icon: Icons.people_alt_outlined,
                color: const Color(0xFFF59E0B),
                title: "Mijozlar bo'yicha",
                subtitle: "Mijoz bo'yicha muddatli to'lov hisoboti",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InstallmentPartnersPage())),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Report Entry Card ────────────────────────────────────────────────────────

class _ReportEntryCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ReportEntryCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: color.withValues(alpha: 0.15)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, size: 20.sp, color: color),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 11.sp, color: const Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Icon(Icons.chevron_right_rounded, size: 20.sp, color: const Color(0xFFCBD5E1)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 1. Summary Section ───────────────────────────────────────────────────────

class _SummarySection extends StatelessWidget {
  final InstallmentSummaryModel? summary;
  final Status status;
  final String currency;

  const _SummarySection({this.summary, required this.status, required this.currency});

  @override
  Widget build(BuildContext context) {
    return _Section(
      icon: Icons.dashboard_rounded,
      child: status == Status.loading && summary == null
          ? _SectionShimmer(height: 130.h)
          : summary == null
              ? const _EmptySection()
              : Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _MetricTile(label: 'Faol rejalar', value: '${summary!.activePlans} ta', icon: Icons.play_circle_outline_rounded, color: AppTheme.colors.primary)),
                        SizedBox(width: 10.w),
                        Expanded(child: _MetricTile(label: 'Tugallangan', value: '${summary!.completedPlans} ta', icon: Icons.check_circle_outline_rounded, color: const Color(0xFF22C55E))),
                        SizedBox(width: 10.w),
                        Expanded(child: _MetricTile(label: 'Bekor qilingan', value: '${summary!.cancelledPlans} ta', icon: Icons.cancel_outlined, color: const Color(0xFF94A3B8))),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    // ── Berilgan + To'langan — 2 ta ──
                    Row(
                      children: [
                        Expanded(
                          child: _AmountTile(
                            label: 'Berilgan',
                            amount: summary!.totalGiven,
                            currency: currency,
                            color: const Color(0xFF6366F1),
                            icon: Icons.account_balance_wallet_outlined,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _AmountTile(
                            label: "To'langan",
                            amount: summary!.totalPaid,
                            currency: currency,
                            color: const Color(0xFF22C55E),
                            icon: Icons.check_circle_outline_rounded,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    // ── Qolgan — full width (asosiy) ──
                    _WideAmountTile(
                      label: 'Qolgan',
                      amount: summary!.totalRemaining,
                      currency: currency,
                      color: const Color(0xFFF59E0B),
                      textColor: const Color(0xFF1E293B),
                      icon: Icons.hourglass_bottom_rounded,
                    ),
                    if ((double.tryParse(summary!.overdueAmount) ?? 0) > 0) ...[
                      SizedBox(height: 10.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: const Color(0xFFFECDD3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, size: 16.sp, color: const Color(0xFFEF4444)),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                "Muddati o'tgan: ${PriceFormatter.priceFormat(summary!.overdueAmount)} $currency",
                                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: const Color(0xFFB91C1C)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
    );
  }
}

// ─── Shared Section Widget ────────────────────────────────────────────────────

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
      child: child,
    );
  }
}

// ─── Shared small tiles ───────────────────────────────────────────────────────

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricTile({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(height: 4.h),
          Text(value, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: TextStyle(fontSize: 9.sp, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ── Wide card: Berilgan (full width) ─────────────────────────────────────────

class _WideAmountTile extends StatelessWidget {
  final String label;
  final String amount;
  final String currency;
  final Color color;
  final Color? textColor;
  final IconData icon;

  const _WideAmountTile({
    required this.label,
    required this.amount,
    required this.currency,
    required this.color,
    this.textColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final tc = textColor ?? color;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13.r),
        border: Border.all(color: color.withValues(alpha: 0.30)),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.14), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 5, color: color),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 13.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withValues(alpha: 0.12), color.withValues(alpha: 0.04)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(9.r),
                        ),
                        child: Icon(icon, size: 16.sp, color: tc),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: tc.withValues(alpha: 0.60),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              PriceFormatter.priceFormat(amount),
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w900,
                                color: tc,
                                height: 1.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(7.r),
                        ),
                        child: Text(
                          currency,
                          style: TextStyle(fontSize: 11.sp, color: tc, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Half-width cards: To'langan / Qolgan ─────────────────────────────────────

class _AmountTile extends StatelessWidget {
  final String label;
  final String amount;
  final String currency;
  final Color color;
  final IconData icon;

  const _AmountTile({
    required this.label,
    required this.amount,
    required this.currency,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.07), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11.r),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 3, color: color),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 11.h),
                  color: color.withValues(alpha: 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(5.r),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(7.r),
                        ),
                        child: Icon(icon, size: 12.sp, color: color),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: const Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        PriceFormatter.priceFormat(amount),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                          color: color,
                          height: 1.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          currency,
                          style: TextStyle(
                            fontSize: 8.sp,
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Empty / Shimmer helpers ──────────────────────────────────────────────────

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

class _Shimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[200]!,
          highlightColor: Colors.grey[50]!,
          child: Container(
            height: 180.h,
            margin: EdgeInsets.only(bottom: 16.h),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
          ),
        ),
        ...List.generate(5, (i) => Shimmer.fromColors(
          baseColor: Colors.grey[200]!,
          highlightColor: Colors.grey[50]!,
          child: Container(
            height: 64.h,
            margin: EdgeInsets.only(bottom: 10.h),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14.r)),
          ),
        )),
      ],
    );
  }
}
