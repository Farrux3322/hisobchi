import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/application/partner_installment_report/partner_installment_report_bloc.dart';
import 'package:hisobchi/application/partner_installment_report/partner_installment_report_event.dart';
import 'package:hisobchi/application/partner_installment_report/partner_installment_report_state.dart';
import 'package:hisobchi/domain/common/constants.dart';
import 'package:hisobchi/features/payment_schedule/data/models/payment_partner_model.dart';
import 'package:hisobchi/features/payment_schedule/presentation/pages/installment_list_page.dart';
import 'package:hisobchi/infrastructure/dto/models/partner_installment_report/partner_installment_report_models.dart';
import 'package:hisobchi/infrastructure/dto/models/partner/partner_model.dart';
import 'package:hisobchi/infrastructure/repository/partner_installment_report/partner_installment_report_repository.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/components/back_button.dart';
import 'package:hisobchi/presentation/components/utils/price_extension.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:shimmer/shimmer.dart';

// ─── Entry point ─────────────────────────────────────────────────────────────

class PartnerInstallmentReportPage extends StatelessWidget {
  const PartnerInstallmentReportPage({super.key, required this.partnerModel});

  final PartnerModel partnerModel;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PartnerInstallmentReportBloc(
        repo: PartnerInstallmentReportRepository(),
      )..add(LoadPartnerReportEvent(partnerModel.id ?? 0)),
      child: _ReportView(partnerModel: partnerModel),
    );
  }
}

// ─── Main View ────────────────────────────────────────────────────────────────

class _ReportView extends StatefulWidget {
  const _ReportView({required this.partnerModel});
  final PartnerModel partnerModel;

  @override
  State<_ReportView> createState() => _ReportViewState();
}

class _ReportViewState extends State<_ReportView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Tab o'zgarganda UI qayta render + USD lazy-load
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
        context.read<PartnerInstallmentReportBloc>().add(
              SelectCurrencyTypeEvent(_tabController.index + 1),
            );
      }
    });
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
        title: Column(
          children: [
            const Text(
              "Muddatli to'lov hisoboti",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
            Text(
              widget.partnerModel.name ?? '',
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(62),
          child: _CurrencyTabBar(controller: _tabController),
        ),
      ),
      // Har bir tab o'z yuklanishi va xatoligini mustaqil boshqaradi
      body: TabBarView(
        controller: _tabController,
        children: [
          _ReportTabContent(
            currencyTypeId: 1,
            currencyLabel: 'UZS',
            partnerModel: widget.partnerModel,
          ),
          _ReportTabContent(
            currencyTypeId: 2,
            currencyLabel: 'USD',
            partnerModel: widget.partnerModel,
          ),
        ],
      ),
    );
  }
}

// ─── Per-currency Tab Content ─────────────────────────────────────────────────

class _ReportTabContent extends StatelessWidget {
  const _ReportTabContent({
    required this.currencyTypeId,
    required this.currencyLabel,
    required this.partnerModel,
  });

  final int currencyTypeId;
  final String currencyLabel;
  final PartnerModel partnerModel;

  PaymentPartnerModel get _paymentPartner => PaymentPartnerModel(
        id: partnerModel.id?.toString() ?? '',
        name: partnerModel.name ?? '',
        phone: partnerModel.phone,
      );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PartnerInstallmentReportBloc,
        PartnerInstallmentReportState>(
      builder: (context, state) {
        final snap = state.snapshotFor(currencyTypeId);

        // Birinchi marta yuklanayotgan
        if (snap.isInitialLoading) return const _FullShimmer();

        // Xatolik va ma'lumot yo'q
        if (snap.mainStatus == Status.error && snap.stat == null) {
          return _FullError(
            message: snap.error ?? 'Xatolik yuz berdi',
            onRetry: () => context
                .read<PartnerInstallmentReportBloc>()
                .add(const RefreshPartnerReportEvent()),
          );
        }

        // Hali yuklanmagan tab (USD ga o'tilmagan) — bo'sh ko'rsatmaymiz
        if (snap.isUnloaded) return const _FullShimmer();

        return RefreshIndicator(
          onRefresh: () async {
            context
                .read<PartnerInstallmentReportBloc>()
                .add(const RefreshPartnerReportEvent());
            await Future.delayed(const Duration(milliseconds: 500));
          },
          color: AppTheme.colors.primary,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              16.w,
              16.h,
              16.w,
              32.h + MediaQuery.of(context).padding.bottom,
            ),
            children: [
              // ── 1. Statistika ──
              _StatsSection(
                stat: snap.stat,
                currency: currencyLabel,
                onStatusTap: (status) => pushScreen(
                  context,
                  screen: InstallmentListPage(
                    partner: _paymentPartner,
                    initialStatus: status,
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // ── 2. Rejalar ──
              _PlansSection(plans: snap.plans, currency: currencyLabel),
              SizedBox(height: 16.h),

              // ── 3. To'lov tarixi ──
              _PaymentsSection(payments: snap.payments, currency: currencyLabel),
              SizedBox(height: 16.h),

              // ── 4. Qismlar jadvali ──
              _ItemsSection(
                items: snap.items,
                currencyLabel: currencyLabel,
                snap: snap,
              ),
              SizedBox(height: 16.h),

              // ── 5. Oylik dinamika ──
              _MonthlySection(snap: snap),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 1 — Statistika
// ═══════════════════════════════════════════════════════════════════════════════

class _StatsSection extends StatelessWidget {
  const _StatsSection({
    required this.stat,
    required this.currency,
    required this.onStatusTap,
  });

  final PartnerInstallmentStatModel? stat;
  final String currency;

  /// status: 'active' | 'completed' | 'cancelled'
  final ValueChanged<String> onStatusTap;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.dashboard_rounded,
      iconColor: AppTheme.colors.primary,
      title: 'Umumiy statistika',
      child: stat == null
          ? _SectionShimmer(height: 160.h)
          : Column(
              children: [
                // Rejalar soni: faol / tugallangan / bekor
                Row(
                  children: [
                    Expanded(
                      child: _MetricChip(
                        label: 'Faol',
                        value: '${stat!.activePlans}',
                        icon: Icons.play_circle_outline_rounded,
                        color: AppTheme.colors.primary,
                        onTap: () => onStatusTap('active'),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _MetricChip(
                        label: 'Tugallangan',
                        value: '${stat!.completedPlans}',
                        icon: Icons.check_circle_outline_rounded,
                        color: const Color(0xFF22C55E),
                        onTap: () => onStatusTap('completed'),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _MetricChip(
                        label: 'Bekor',
                        value: '${stat!.cancelledPlans}',
                        icon: Icons.cancel_outlined,
                        color: const Color(0xFF94A3B8),
                        onTap: () => onStatusTap('cancelled'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),

                // Berilgan + To'langan (teng ikki karta)
                Row(
                  children: [
                    Expanded(
                      child: _AmountCard(
                        label: 'Berilgan',
                        amount: stat!.totalGiven,
                        currency: currency,
                        color: const Color(0xFF6366F1),
                        icon: Icons.account_balance_wallet_outlined,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _AmountCard(
                        label: "To'langan",
                        amount: stat!.totalPaid,
                        currency: currency,
                        color: const Color(0xFF22C55E),
                        icon: Icons.check_circle_outline_rounded,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),

                // Qolgan — to'liq kenglik
                _WideAmountCard(
                  label: 'Qolgan',
                  amount: stat!.totalRemaining,
                  currency: currency,
                  color: const Color(0xFFF59E0B),
                  textColor: const Color(0xFF1E293B),
                  icon: Icons.hourglass_bottom_rounded,
                ),

                // Muddati o'tgan banner (faqat mavjud bo'lsa)
                if (stat!.hasOverdue) ...[
                  SizedBox(height: 8.h),
                  _OverdueBanner(
                    amount: stat!.overdueAmount,
                    currency: currency,
                  ),
                ],
              ],
            ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 2 — Rejalar
// ═══════════════════════════════════════════════════════════════════════════════

class _PlansSection extends StatefulWidget {
  const _PlansSection({required this.plans, required this.currency});

  final List<PartnerInstallmentPlanModel> plans;
  final String currency;

  @override
  State<_PlansSection> createState() => _PlansSectionState();
}

class _PlansSectionState extends State<_PlansSection> {
  static const _previewCount = 2;
  bool _expanded = false;

  @override
  void didUpdateWidget(_PlansSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Ma'lumot o'zgarganda collapse'ga qaytarish
    if (oldWidget.plans != widget.plans) _expanded = false;
  }

  @override
  Widget build(BuildContext context) {
    final plans = widget.plans;
    final hasMore = plans.length > _previewCount;
    final visible = (_expanded || !hasMore) ? plans : plans.take(_previewCount).toList();
    final hiddenCount = plans.length - _previewCount;

    return _SectionCard(
      icon: Icons.calendar_month_rounded,
      iconColor: const Color(0xFF6366F1),
      title: "Muddatli to'lov rejalari",
      trailing: plans.isNotEmpty
          ? _CountBadge(count: plans.length, color: const Color(0xFF6366F1))
          : null,
      child: plans.isEmpty
          ? const _EmptySection(message: "Rejalar mavjud emas")
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ko'rinadigan rejalar
                ...visible.map((plan) => Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: _PlanCard(plan: plan, currency: widget.currency),
                    )),

                // "Barchasini ko'rish / Yig'ish" tugmasi
                if (hasMore)
                  _PlansToggleButton(
                    expanded: _expanded,
                    hiddenCount: hiddenCount,
                    onTap: () => setState(() => _expanded = !_expanded),
                  ),
              ],
            ),
    );
  }
}

class _PlansToggleButton extends StatelessWidget {
  const _PlansToggleButton({
    required this.expanded,
    required this.hiddenCount,
    required this.onTap,
    this.color = const Color(0xFF6366F1),
  });

  final bool expanded;
  final int hiddenCount;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Ink(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: color.withValues(alpha: 0.18)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                expanded ? "Yig'ish" : "Yana $hiddenCount ta ko'rish",
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              SizedBox(width: 6.w),
              AnimatedRotation(
                turns: expanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18.sp,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.currency});

  final PartnerInstallmentPlanModel plan;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: plan.statusColor.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: sana + status
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 12.sp,
                color: const Color(0xFF94A3B8),
              ),
              SizedBox(width: 4.w),
              Text(
                plan.createdAt,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              // Muddati o'tgan qismlar badge
              if (plan.overdueItemsCount > 0) ...[
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    '${plan.overdueItemsCount} muddati o\'tgan',
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: const Color(0xFFEF4444),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: 6.w),
              ],
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: plan.statusBgColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  plan.statusLabel,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: plan.statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // Jami summa + qismlar soni
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jami summa',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${PriceFormatter.priceFormat(plan.totalAmount)} $currency',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Qismlar',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${plan.itemsCount} ta',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: plan.progress,
              backgroundColor: const Color(0xFFE2E8F0),
              color: plan.statusColor,
              minHeight: 6.h,
            ),
          ),
          SizedBox(height: 8.h),

          // To'langan / Qolgan
          Row(
            children: [
              _MiniAmount(
                label: "To'langan",
                amount: '${PriceFormatter.priceFormat(plan.paidAmount)} $currency',
                color: const Color(0xFF22C55E),
              ),
              const Spacer(),
              _MiniAmount(
                label: 'Qolgan',
                amount: '${PriceFormatter.priceFormat(plan.totalRemaining)} $currency',
                color: plan.remainingDouble > 0
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF94A3B8),
                align: CrossAxisAlignment.end,
              ),
            ],
          ),

          // Grafik turi
          if (plan.scheduleType == 'equal' || plan.scheduleType == 'custom') ...[
            SizedBox(height: 8.h),
            Divider(height: 1, color: const Color(0xFFE2E8F0)),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(
                  plan.scheduleType == 'equal'
                      ? Icons.calculate_rounded
                      : Icons.edit_calendar_rounded,
                  size: 12.sp,
                  color: const Color(0xFF94A3B8),
                ),
                SizedBox(width: 4.w),
                Text(
                  plan.scheduleType == 'equal'
                      ? "Teng bo'lib to'lash"
                      : 'Erkin grafik',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: const Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 3 — To'lov tarixi
// ═══════════════════════════════════════════════════════════════════════════════

class _PaymentsSection extends StatefulWidget {
  const _PaymentsSection({required this.payments, required this.currency});

  final List<PartnerInstallmentPaymentModel> payments;
  final String currency;

  @override
  State<_PaymentsSection> createState() => _PaymentsSectionState();
}

class _PaymentsSectionState extends State<_PaymentsSection> {
  static const _previewCount = 2;
  bool _expanded = false;

  @override
  void didUpdateWidget(_PaymentsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.payments != widget.payments) _expanded = false;
  }

  @override
  Widget build(BuildContext context) {
    final payments = widget.payments;
    final hasMore = payments.length > _previewCount;
    final visible =
        (_expanded || !hasMore) ? payments : payments.take(_previewCount).toList();
    final hiddenCount = payments.length - _previewCount;

    return _SectionCard(
      icon: Icons.receipt_long_rounded,
      iconColor: const Color(0xFF22C55E),
      title: "To'lov tarixi",
      trailing: payments.isNotEmpty
          ? _CountBadge(count: payments.length, color: const Color(0xFF22C55E))
          : null,
      child: payments.isEmpty
          ? const _EmptySection(message: "To'lovlar mavjud emas")
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...visible.map(
                  (p) => Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: _PaymentTile(payment: p, currency: widget.currency),
                  ),
                ),
                if (hasMore)
                  _PlansToggleButton(
                    expanded: _expanded,
                    hiddenCount: hiddenCount,
                    color: const Color(0xFF22C55E),
                    onTap: () => setState(() => _expanded = !_expanded),
                  ),
              ],
            ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({required this.payment, required this.currency});

  final PartnerInstallmentPaymentModel payment;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final isCancelled = payment.isCancelled;
    final color = isCancelled ? const Color(0xFF94A3B8) : const Color(0xFF22C55E);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(7.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              isCancelled
                  ? Icons.cancel_outlined
                  : Icons.check_circle_outline_rounded,
              size: 16.sp,
              color: color,
            ),
          ),
          SizedBox(width: 10.w),

          // Reja № + sana + note
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "To'lov",
                  // 'Reja №${payment.planId}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 3.h),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 11.sp,
                      color: const Color(0xFF94A3B8),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      payment.createdAt,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (payment.note != null && payment.note!.isNotEmpty) ...[
                  SizedBox(height: 6.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      payment.note!,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: const Color(0xFF64748B),
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 10.w),

          // O'ngda: Summa
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${isCancelled ? '' : '+'}${PriceFormatter.priceFormat(payment.amount)} $currency',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: isCancelled
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF1E293B),
                  decoration: isCancelled
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              if (isCancelled) ...[
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF94A3B8).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    'Bekor',
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ] else ...[
                SizedBox(height: 2.h),
                Text(
                  "To'landi",
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: const Color(0xFF22C55E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 4 — Qismlar jadvali
// ═══════════════════════════════════════════════════════════════════════════════

class _ItemsSection extends StatefulWidget {
  const _ItemsSection({
    required this.items,
    required this.currencyLabel,
    required this.snap,
  });

  final List<PartnerInstallmentItemModel> items;
  final String currencyLabel;
  final PartnerCurrencySnapshot snap;

  @override
  State<_ItemsSection> createState() => _ItemsSectionState();
}

class _ItemsSectionState extends State<_ItemsSection> {
  static const _previewCount = 2;
  bool _expanded = false;

  @override
  void didUpdateWidget(_ItemsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) _expanded = false;
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    final hasMore = items.length > _previewCount;
    final visible = (_expanded || !hasMore) ? items : items.take(_previewCount).toList();
    final hiddenCount = items.length - _previewCount;

    return _SectionCard(
      icon: Icons.format_list_numbered_rounded,
      iconColor: const Color(0xFF3B82F6),
      title: 'Qismlar jadvali',
      trailing: items.isNotEmpty
          ? _CountBadge(count: items.length, color: const Color(0xFF3B82F6))
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter bar
          _ItemFilterBar(
            selected: widget.snap.itemsStatusFilter,
            onSelect: (status) => context
                .read<PartnerInstallmentReportBloc>()
                .add(FilterItemsByStatusEvent(status)),
          ),
          SizedBox(height: 10.h),

          // Content
          if (widget.snap.itemsStatus == Status.loading)
            _SectionShimmer(height: 120.h)
          else if (items.isEmpty)
            const _EmptySection(message: 'Qismlar mavjud emas')
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...visible.map(
                  (item) => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: _ItemCard(item: item, currency: widget.currencyLabel),
                  ),
                ),
                if (hasMore)
                  _PlansToggleButton(
                    expanded: _expanded,
                    hiddenCount: hiddenCount,
                    color: const Color(0xFF3B82F6),
                    onTap: () => setState(() => _expanded = !_expanded),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ItemFilterBar extends StatelessWidget {
  const _ItemFilterBar({required this.selected, required this.onSelect});

  final String? selected;
  final ValueChanged<String?> onSelect;

  static const _filters = <(String?, String)>[
    (null, 'Barchasi'),
    ('overdue', 'Muddati o\'tdi'),
    ('pending', 'Kutilmoqda'),
    ('partial', 'Qisman'),
    ('paid', 'To\'langan'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((f) {
          final (status, label) = f;
          final isSelected = selected == status;
          final chipColor = _colorForStatus(status);

          return Padding(
            padding: EdgeInsets.only(right: 6.w),
            child: GestureDetector(
              onTap: () => onSelect(status),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? chipColor
                      : chipColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected
                        ? chipColor
                        : chipColor.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : chipColor,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _colorForStatus(String? status) {
    switch (status) {
      case 'overdue':
        return const Color(0xFFEF4444);
      case 'pending':
        return const Color(0xFF94A3B8);
      case 'partial':
        return const Color(0xFF3B82F6);
      case 'paid':
        return const Color(0xFF22C55E);
      default:
        return AppTheme.colors.primary;
    }
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item, required this.currency});

  final PartnerInstallmentItemModel item;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: item.statusColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: item.statusColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Raqam
              Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: item.isAdvance
                      ? const Color(0xFF6366F1).withValues(alpha: 0.12)
                      : item.statusBgColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Text(
                    item.isAdvance ? 'A' : '${item.itemNumber}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                      color: item.isAdvance
                          ? const Color(0xFF6366F1)
                          : item.statusColor,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),

              // Summa + sana
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${PriceFormatter.priceFormat(item.amount)} $currency',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 10.sp,
                          color: const Color(0xFF94A3B8),
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          item.dueDate,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                        if (item.paidAt != null) ...[
                          SizedBox(width: 6.w),
                          Icon(
                            Icons.check_rounded,
                            size: 10.sp,
                            color: const Color(0xFF22C55E),
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            item.paidAt!,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: const Color(0xFF22C55E),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Status chip
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: item.statusBgColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  item.statusLabel,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: item.statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          // Progress bar (faqat partial/near/overdue uchun)
          if (item.status != 'paid' && item.status != 'pending') ...[
            SizedBox(height: 8.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(3.r),
              child: LinearProgressIndicator(
                value: item.progress,
                backgroundColor: const Color(0xFFE2E8F0),
                color: item.statusColor,
                minHeight: 5.h,
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "To'langan: ${PriceFormatter.priceFormat(item.paidAmount)}",
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
                Text(
                  "Qolgan: ${PriceFormatter.priceFormat(item.remaining)}",
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: item.statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 5 — Oylik dinamika
// ═══════════════════════════════════════════════════════════════════════════════

class _MonthlySection extends StatelessWidget {
  const _MonthlySection({required this.snap});

  final PartnerCurrencySnapshot snap;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.bar_chart_rounded,
      iconColor: const Color(0xFF8B5CF6),
      title: 'Oylik dinamika',
      trailing: _YearSelector(
        year: snap.selectedYear,
        onChanged: (y) => context
            .read<PartnerInstallmentReportBloc>()
            .add(ChangePartnerReportYearEvent(y)),
      ),
      child: snap.monthlyStatus == Status.loading && snap.monthlyDynamics.isEmpty
          ? _SectionShimmer(height: 200.h)
          : snap.monthlyDynamics.isEmpty
              ? const _EmptySection(message: 'Oylik ma\'lumotlar mavjud emas')
              : _GroupedBarChart(months: snap.monthlyDynamics),
    );
  }
}

class _GroupedBarChart extends StatefulWidget {
  const _GroupedBarChart({required this.months});
  final List<PartnerMonthlyDynamicModel> months;

  @override
  State<_GroupedBarChart> createState() => _GroupedBarChartState();
}

class _GroupedBarChartState extends State<_GroupedBarChart> {
  int? _touched;

  String _compact(double v) {
    if (v >= 1000000000) return '${(v / 1000000000).toStringAsFixed(1)}B';
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final months = widget.months;
    final maxVal = months.fold(0.0, (m, d) => d.maxValue > m ? d.maxValue : m);

    if (maxVal == 0) {
      return const _EmptySection(message: "Bu yilda ma'lumot mavjud emas");
    }

    final barGroups = months.asMap().entries.map((e) {
      final i = e.key;
      final m = e.value;
      final isTouched = _touched == i;

      // Qiymati > 0 bo'lgan rod'lar uchun har doim tooltip ko'rsatamiz
      final alwaysShow = <int>[
        if (m.plannedAmount > 0) 0,
        if (m.collectedAmount > 0) 1,
      ];

      return BarChartGroupData(
        x: i,
        barsSpace: 2.w,
        showingTooltipIndicators: alwaysShow,
        barRods: [
          // Rejalashtirilgan — indigo
          BarChartRodData(
            toY: m.plannedAmount,
            width: 10.w,
            borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
            color: const Color(0xFF6366F1)
                .withValues(alpha: isTouched ? 1.0 : 0.80),
          ),
          // To'langan — yashil
          BarChartRodData(
            toY: m.collectedAmount,
            width: 10.w,
            borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
            color: const Color(0xFF22C55E)
                .withValues(alpha: isTouched ? 1.0 : 0.80),
          ),
        ],
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Legend
        Row(
          children: [
            _LegendDot(color: const Color(0xFF6366F1), label: 'Rejalangan'),
            SizedBox(width: 14.w),
            _LegendDot(color: const Color(0xFF22C55E), label: "To'langan"),
          ],
        ),
        SizedBox(height: 12.h),

        // Chart
        SizedBox(
          height: 240.h,
          child: BarChart(
            BarChartData(
              // Tooltip'lar bar ustida chiqishi uchun ko'proq bo'sh joy
              maxY: maxVal * 1.65,
              groupsSpace: 8.w,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (group) {
                    // Tegishli rod rangini qaytaradi
                    return Colors.transparent;
                  },
                  tooltipRoundedRadius: 4.r,
                  tooltipPadding: EdgeInsets.symmetric(
                      horizontal: 3.w, vertical: 2.h),
                  tooltipMargin: 4,
                  fitInsideHorizontally: true,
                  fitInsideVertically: false,
                  getTooltipItem: (group, _, rod, rodIndex) {
                    final m = months[group.x];
                    final amount =
                        rodIndex == 0 ? m.plannedAmount : m.collectedAmount;
                    if (amount <= 0) return null;
                    final color = rodIndex == 0
                        ? const Color(0xFF6366F1)
                        : const Color(0xFF22C55E);
                    return BarTooltipItem(
                      _compact(amount),
                      TextStyle(
                        fontSize: 8.sp,
                        color: color,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    );
                  },
                ),
                touchCallback: (event, resp) {
                  if (resp?.spot == null ||
                      event is FlPointerExitEvent ||
                      event is FlTapUpEvent) {
                    setState(() => _touched = null);
                  } else {
                    setState(
                        () => _touched = resp!.spot!.touchedBarGroupIndex);
                  }
                },
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 26.h,
                    getTitlesWidget: (v, _) => Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Text(
                        months[v.toInt()].uzLabel,
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: const Color(0xFF94A3B8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                leftTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: const Color(0xFFF1F5F9),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: barGroups,
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Divider(height: 1, color: const Color(0xFFE2E8F0)),
        SizedBox(height: 8.h),

        // Jami
        Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 11.sp,
              color: const Color(0xFF94A3B8),
            ),
            SizedBox(width: 5.w),
            Expanded(
              child: Text(
                'Jami rejalangan: ${_compact(months.fold(0.0, (s, m) => s + m.plannedAmount))} '
                '· To\'langan: ${_compact(months.fold(0.0, (s, m) => s + m.collectedAmount))}',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

// ─── Section Card ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
    this.trailing,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, size: 14.sp, color: iconColor),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                  ),
                ),
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

// ─── Metric Chip ──────────────────────────────────────────────────────────────

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Ink(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: color.withValues(alpha: 0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, size: 13.sp, color: color),
                  if (onTap != null)
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 9.sp,
                      color: color.withValues(alpha: 0.5),
                    ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9.sp,
                  color: const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Half-width Amount Card ───────────────────────────────────────────────────

class _AmountCard extends StatelessWidget {
  const _AmountCard({
    required this.label,
    required this.amount,
    required this.currency,
    required this.color,
    required this.icon,
  });

  final String label;
  final String amount;
  final String currency;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.07),
              blurRadius: 6,
              offset: const Offset(0, 2)),
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
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
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
                        child: Icon(icon, size: 11.sp, color: color),
                      ),
                      SizedBox(height: 5.h),
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
                      SizedBox(height: 2.h),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 5.w, vertical: 1.h),
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

// ─── Full-width Amount Card ───────────────────────────────────────────────────

class _WideAmountCard extends StatelessWidget {
  const _WideAmountCard({
    required this.label,
    required this.amount,
    required this.currency,
    required this.color,
    required this.icon,
    this.textColor,
  });

  final String label;
  final String amount;
  final String currency;
  final Color color;
  final Color? textColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final tc = textColor ?? color;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13.r),
        border: Border.all(color: color.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 3)),
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
                  padding:
                      EdgeInsets.symmetric(horizontal: 13.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.10),
                        color.withValues(alpha: 0.03),
                      ],
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
                        child: Icon(icon, size: 15.sp, color: tc),
                      ),
                      SizedBox(width: 10.w),
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
                                fontSize: 17.sp,
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
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 7.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          currency,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: tc,
                            fontWeight: FontWeight.w800,
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

// ─── Overdue Banner ───────────────────────────────────────────────────────────

class _OverdueBanner extends StatelessWidget {
  const _OverdueBanner({required this.amount, required this.currency});

  final String amount;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFFECDD3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 16.sp,
            color: const Color(0xFFEF4444),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              "Muddati o'tgan: ${PriceFormatter.priceFormat(amount)} $currency",
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFB91C1C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Year Selector ────────────────────────────────────────────────────────────

class _YearSelector extends StatelessWidget {
  const _YearSelector({required this.year, required this.onChanged});

  final int year;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final current = DateTime.now().year;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => onChanged(year - 1),
          child: Icon(
            Icons.chevron_left_rounded,
            size: 18.sp,
            color: const Color(0xFF64748B),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            '$year',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
        ),
        GestureDetector(
          onTap: year < current ? () => onChanged(year + 1) : null,
          child: Icon(
            Icons.chevron_right_rounded,
            size: 18.sp,
            color: year < current
                ? const Color(0xFF64748B)
                : const Color(0xFFCBD5E1),
          ),
        ),
      ],
    );
  }
}

// ─── Currency TabBar ──────────────────────────────────────────────────────────

class _CurrencyTabBar extends StatelessWidget {
  const _CurrencyTabBar({required this.controller});
  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _TabItem(
                label: 'UZS Hisob',
                selected: controller.index == 0,
                onTap: () => controller.animateTo(0),
              ),
              _TabDivider(),
              _TabItem(
                label: 'USD Hisob',
                selected: controller.index == 1,
                onTap: () => controller.animateTo(1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

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
              fontSize: 14,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              color: selected
                  ? const Color(0xFF0F172A)
                  : const Color(0xFF64748B),
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
          Container(
            width: 2,
            height: 12,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 2),
          Container(
            width: 2,
            height: 12,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      );
}

// ─── Count Badge ──────────────────────────────────────────────────────────────

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count, required this.color});

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        '$count ta',
        style: TextStyle(
          fontSize: 11.sp,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─── Mini amount label ────────────────────────────────────────────────────────

class _MiniAmount extends StatelessWidget {
  const _MiniAmount({
    required this.label,
    required this.amount,
    required this.color,
    this.align = CrossAxisAlignment.start,
  });

  final String label;
  final String amount;
  final Color color;
  final CrossAxisAlignment align;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9.sp,
            color: const Color(0xFF94A3B8),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          amount,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ─── Legend Dot ───────────────────────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3.r),
          ),
        ),
        SizedBox(width: 5.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─── Section Shimmer ──────────────────────────────────────────────────────────

class _SectionShimmer extends StatelessWidget {
  const _SectionShimmer({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }
}

// ─── Empty Section ────────────────────────────────────────────────────────────

class _EmptySection extends StatelessWidget {
  const _EmptySection({this.message = "Ma'lumot topilmadi"});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Text(
          message,
          style: TextStyle(fontSize: 13.sp, color: const Color(0xFF94A3B8)),
        ),
      ),
    );
  }
}

// ─── Full-screen Shimmer ──────────────────────────────────────────────────────

class _FullShimmer extends StatelessWidget {
  const _FullShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        ...List.generate(
          5,
          (i) => Shimmer.fromColors(
            baseColor: Colors.grey[200]!,
            highlightColor: Colors.grey[50]!,
            child: Container(
              height: i == 0 ? 180.h : 120.h,
              margin: EdgeInsets.only(bottom: 14.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Full-screen Error ────────────────────────────────────────────────────────

class _FullError extends StatelessWidget {
  const _FullError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56.r,
              color: const Color(0xFFEF4444),
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Qayta urinish'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.colors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
