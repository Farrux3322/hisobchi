import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../presentation/assets/asset_index.dart';
import '../../data/models/enums.dart';
import '../../data/models/installment_item_model.dart';
import '../../data/models/installment_plan_model.dart';
import '../cubit/installment_detail_cubit.dart';
import 'installment_plan_info_page.dart';
import 'payment_history_page.dart';

class InstallmentDetailPage extends StatelessWidget {
  final int id;

  const InstallmentDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => InstallmentDetailCubit()..loadDetail(id), child: const _DetailView());
  }
}

class _DetailView extends StatefulWidget {
  const _DetailView();

  @override
  State<_DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends State<_DetailView> {
  bool _hasChanges = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InstallmentDetailCubit, InstallmentDetailState>(
      listener: (context, state) {
        if (state.actionError != null) {
          _showErrorSnackbar(context, state.actionError!);
          context.read<InstallmentDetailCubit>().clearActionError();
        }
      },
      builder: (context, state) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            Navigator.pop(context, _hasChanges);
          },
          child: Scaffold(backgroundColor: AppTheme.colors.background, appBar: _buildAppBar(context, state), body: _buildBody(context, state)),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, InstallmentDetailState state) {
    return AppBar(
      backgroundColor: AppTheme.colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context, _hasChanges),
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 16),
        ),
      ),
      title: Text(
        "Bo'lib to'lash",
        style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w800, color: AppTheme.colors.black),
      ),
      actions: [
        if (state.plan != null && state.plan!.isActive)
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: AppTheme.colors.black),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
            onSelected: (v) {
              if (v == 'cancel') _confirmCancel(context);
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'cancel',
                child: Row(
                  children: [
                    Icon(Icons.cancel_outlined, color: AppTheme.colors.red, size: 18.r),
                    SizedBox(width: 8.w),
                    Text(
                      'Shartnomani bekor qilish',
                      style: TextStyle(color: AppTheme.colors.red, fontSize: 14.sp),
                    ),
                  ],
                ),
              ),
            ],
          ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildBody(BuildContext context, InstallmentDetailState state) {
    if (state.status == InstallmentDetailStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == InstallmentDetailStatus.failure) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 56.r, color: AppTheme.colors.red),
            SizedBox(height: 12.h),
            Text(
              state.errorMessage ?? 'Xatolik',
              style: TextStyle(fontSize: 14.sp, color: AppTheme.colors.gray),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => context.read<InstallmentDetailCubit>().loadDetail(installmentId),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.colors.primary, foregroundColor: Colors.white),
              child: const Text('Qayta urinish'),
            ),
          ],
        ),
      );
    }

    if (state.plan == null) return const SizedBox.shrink();

    final plan = state.plan!;
    final isPaying = state.status == InstallmentDetailStatus.paying;
    final isCancelling = state.status == InstallmentDetailStatus.cancelling;

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => context.read<InstallmentDetailCubit>().loadDetail(plan.id),
            color: AppTheme.colors.primary,
            backgroundColor: AppTheme.colors.white,
            displacement: 20.h,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _SummaryCard(
                        plan: plan,
                        onHistoryTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentHistoryPage(installmentId: plan.id, partnerName: plan.partnerName),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      _ProgressCard(plan: plan),
                      SizedBox(height: 20.h),
                      _SectionTitle(title: "To'lov jadvali", count: plan.items.length),
                      SizedBox(height: 12.h),
                    ]),
                  ),
                ),
                if (plan.items.isEmpty)
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    sliver: SliverToBoxAdapter(child: _EmptyItems()),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, plan.isActive ? 110.h : 30.h),
                    sliver: SliverList.separated(
                      itemCount: plan.items.length,
                      separatorBuilder: (_, __) => const SizedBox.shrink(),
                      itemBuilder: (_, i) => _ItemCard(item: plan.items[i], currency: plan.currencyTypeName),
                    ),
                  ),
                SliverPadding(
                  padding: EdgeInsets.only(bottom: plan.isActive ? 0 : 30.h),
                  sliver: const SliverToBoxAdapter(),
                ),
              ],
            ),
          ),
        ),

        // To'lov qabul qilish tugmasi — faqat faol rejalar uchun
        if (plan.isActive)
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
            decoration: BoxDecoration(
              color: AppTheme.colors.background,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(24.r), topRight: Radius.circular(24.r)),
            ),
            child: ElevatedButton.icon(
              onPressed: (isPaying || isCancelling) ? null : () => _showPaymentSheet(context, plan),
              icon: isPaying
                  ? SizedBox(
                      width: 18.r,
                      height: 18.r,
                      child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Icon(Icons.payments_rounded, size: 20.r),
              label: Text(
                isPaying ? "To'lanmoqda..." : "To'lov qabul qilish",
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.colors.primary,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
              ),
            ),
          ),
      ],
    );
  }

  // ─── To'lov sheet ─────────────────────────────────────────────────────────

  void _showPaymentSheet(BuildContext context, InstallmentPlanModel plan) {
    final cubit = context.read<InstallmentDetailCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: _PaymentSheet(
          plan: plan,
          cubit: cubit,
          onSuccess: () {
            _hasChanges = true;
            if (context.mounted) _showSuccessSnackbar(context, "To'lov qabul qilindi");
          },
          onError: (msg) {
            if (context.mounted) _showErrorSnackbar(context, msg);
          },
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          'Rejani bekor qilish',
          style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w800),
        ),
        content: Text(
          "Ushbu bo'lib to'lash rejasini bekor qilmoqchimisiz? Bu amalni qaytarib bo'lmaydi.",
          style: TextStyle(fontSize: 14.sp, color: AppTheme.colors.gray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Yoq', style: TextStyle(color: AppTheme.colors.gray)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final ok = await context.read<InstallmentDetailCubit>().cancelPlan();
              if (ok) {
                _hasChanges = true;
                if (context.mounted) _showSuccessSnackbar(context, 'Reja bekor qilindi');
              }
            },
            child: Text(
              'Ha, bekor qilish',
              style: TextStyle(color: AppTheme.colors.red, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  int get installmentId => (context.read<InstallmentDetailCubit>().state.plan?.id ?? 0);

  void _showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: AppTheme.colors.green, behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)));
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: AppTheme.colors.red, behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 3)));
  }
}

// ─── Summary Card ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final InstallmentPlanModel plan;
  final VoidCallback onHistoryTap;

  const _SummaryCard({required this.plan, required this.onHistoryTap});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###', 'en_US');
    final currLabel = plan.currency == PaymentCurrency.uzs ? 'UZS' : 'USD';

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  plan.partnerName,
                  style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w800, color: AppTheme.colors.black),
                ),
              ),
              _StatusChip(status: plan.status),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(height: 1, color: AppTheme.colors.divider.withValues(alpha: 0.5)),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _InfoTile(label: 'Jami summa ($currLabel)', value: fmt.format(plan.totalAmount).replaceAll(',', ' '), icon: Icons.account_balance_wallet_rounded),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _InfoTile(label: 'Qismlar soni', value: '${plan.totalCount} ta', icon: Icons.format_list_numbered_rounded),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _TappableInfoTile(
                  label: "To'langan ($currLabel)",
                  value: fmt.format(plan.paidAmount).replaceAll(',', ' '),
                  icon: Icons.check_circle_outline_rounded,
                  valueColor: const Color(0xFF22C55E),
                  onTap: onHistoryTap,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _InfoTile(
                  label: 'Qolgan qarz ($currLabel)',
                  value: fmt.format(plan.remaining).replaceAll(',', ' '),
                  icon: Icons.hourglass_empty_rounded,
                  valueColor: plan.remaining > 0 ? AppTheme.colors.red : AppTheme.colors.gray,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Divider(height: 1, color: AppTheme.colors.divider.withValues(alpha: 0.5)),
          SizedBox(height: 12.h),

          InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => InstallmentPlanInfoPage(plan: plan))),
            borderRadius: BorderRadius.circular(10.r),
            child: Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: (AppTheme.colors.gray).withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: (AppTheme.colors.primary).withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 16.r, color: AppTheme.colors.primary),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Batafsil ma'lumot",
                            style: TextStyle(fontSize: 14.sp, color: AppTheme.colors.black, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, size: 13.r, color: AppTheme.colors.black),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _InfoTile({required this.label, required this.value, required this.icon, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(color: AppTheme.colors.background, borderRadius: BorderRadius.circular(10.r)),
      child: Row(
        children: [
          Icon(icon, size: 16.r, color: AppTheme.colors.gray),
          SizedBox(width: 6.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 10.sp, color: AppTheme.colors.black, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: valueColor ?? AppTheme.colors.black),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TappableInfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;
  final VoidCallback onTap;

  const _TappableInfoTile({required this.label, required this.value, required this.icon, required this.onTap, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: (valueColor ?? AppTheme.colors.primary).withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: (valueColor ?? AppTheme.colors.primary).withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16.r, color: valueColor ?? AppTheme.colors.primary),
            SizedBox(width: 6.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(fontSize: 10.sp, color: AppTheme.colors.black, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, size: 13.r, color: AppTheme.colors.black),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    value,
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: valueColor ?? AppTheme.colors.black),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Progress Card ────────────────────────────────────────────────────────────

class _ProgressCard extends StatelessWidget {
  final InstallmentPlanModel plan;

  const _ProgressCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final progress = plan.totalAmount > 0 ? (plan.paidAmount / plan.totalAmount).clamp(0.0, 1.0) : 0.0;
    final paidCount = plan.items.where((i) => i.isPaid).length;
    final total = plan.items.length;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "To'lov holati",
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppTheme.colors.black),
              ),
              Text(
                '$paidCount / $total qism',
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppTheme.colors.primary),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          _SegmentedProgressBar(items: plan.items, totalAmount: plan.totalAmount, height: 10),
          SizedBox(height: 6.h),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: plan.status.color),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section title ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final int count;

  const _SectionTitle({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: AppTheme.colors.black),
        ),
        SizedBox(width: 8.w),
        if (count > 0)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(color: AppTheme.colors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6.r)),
            child: Text(
              '$count ta',
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppTheme.colors.primary),
            ),
          ),
      ],
    );
  }
}

// ─── Item Card ─────────────────────────────────────────────────────────────────

class _ItemCard extends StatelessWidget {
  final InstallmentItemModel item;
  final String currency;

  const _ItemCard({required this.item, required this.currency});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###', 'en_US');
    final currLabel = currency == 'UZS' ? 'UZS' : 'USD';

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: item.isAdvance ? const Color(0xFFF97316).withValues(alpha: 0.4) : item.status.color.withValues(alpha: 0.2), width: 1.5.w),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Nom + avans badge
              if (item.isAdvance)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  margin: EdgeInsets.only(right: 8.w),
                  decoration: BoxDecoration(color: const Color(0xFFF97316).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6.r)),
                  child: Text(
                    'AVANS',
                    style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w800, color: const Color(0xFFF97316), letterSpacing: 1),
                  ),
                ),
              Text(
                item.label,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppTheme.colors.black),
              ),
              const Spacer(),
              // Status chip
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(color: item.status.backgroundColor, borderRadius: BorderRadius.circular(10.r)),
                child: Text(
                  item.statusLabel.isNotEmpty ? item.statusLabel : item.status.label,
                  style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700, color: item.status.color),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _MiniInfo(icon: Icons.account_balance_wallet_outlined, label: 'Jami ($currLabel)', value: fmt.format(item.amount).replaceAll(',', ' ')),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _MiniInfo(icon: Icons.check_circle_outline, label: "To'langan ($currLabel)", value: fmt.format(item.paidAmount).replaceAll(',', ' '), valueColor: const Color(0xFF22C55E)),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _MiniInfo(icon: Icons.calendar_today_outlined, label: 'Muddat', value: item.dueDate),
              ),
            ],
          ),
          if (item.paidAt != null) ...[
            SizedBox(height: 6.h),
            Row(
              children: [
                Icon(Icons.access_time_rounded, size: 12.r, color: AppTheme.colors.gray),
                SizedBox(width: 4.w),
                Text(
                  "To'langan: ${item.paidAt}",
                  style: TextStyle(fontSize: 11.sp, color: AppTheme.colors.gray, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
          // Qisman to'lov qoldig'i
          if (item.isPartial) ...[
            SizedBox(height: 6.h),
            Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 12.r, color: const Color(0xFF3B82F6)),
                SizedBox(width: 4.w),
                Text(
                  "Qolgan: ${fmt.format(item.remaining).replaceAll(',', ' ')} $currLabel",
                  style: TextStyle(fontSize: 11.sp, color: const Color(0xFF3B82F6), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _MiniInfo({required this.icon, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 11.r, color: AppTheme.colors.gray),
            SizedBox(width: 3.w),
            Text(
              label,
              style: TextStyle(fontSize: 10.sp, color: AppTheme.colors.gray, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        SizedBox(height: 3.h),
        Text(
          value,
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: valueColor ?? AppTheme.colors.black),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _EmptyItems extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(color: AppTheme.colors.white, borderRadius: BorderRadius.circular(14.r)),
      child: Center(
        child: Text(
          "Qismlar topilmadi",
          style: TextStyle(fontSize: 14.sp, color: AppTheme.colors.gray),
        ),
      ),
    );
  }
}

// ─── Segmented Progress Bar ───────────────────────────────────────────────────

class _SegmentedProgressBar extends StatelessWidget {
  final List<InstallmentItemModel> items;
  final double totalAmount;
  final double height;

  const _SegmentedProgressBar({required this.items, required this.totalAmount, this.height = 8});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty || totalAmount <= 0) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        const gap = 2.0;
        final totalGap = gap * (items.length - 1);
        final availableWidth = totalWidth - totalGap;

        return SizedBox(
          height: height,
          child: Row(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;

              final segWidth = ((item.amount / totalAmount) * availableWidth).clamp(0.0, availableWidth);
              final fillRatio = item.amount > 0 ? (item.paidAmount / item.amount).clamp(0.0, 1.0) : 0.0;

              final isFirst = index == 0;
              final isLast = index == items.length - 1;
              final radius = BorderRadius.horizontal(
                left: isFirst ? Radius.circular(height / 2) : Radius.zero,
                right: isLast ? Radius.circular(height / 2) : Radius.zero,
              );

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (index > 0) const SizedBox(width: gap),
                  SizedBox(
                    width: segWidth,
                    height: height,
                    child: ClipRRect(
                      borderRadius: radius,
                      child: Stack(
                        children: [
                          Container(color: AppTheme.colors.divider.withValues(alpha: 0.25)),
                          FractionallySizedBox(
                            widthFactor: fillRatio,
                            child: Container(color: _segmentColor(item)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Color _segmentColor(InstallmentItemModel item) {
    switch (item.status) {
      case InstallmentStatus.paid:
        return const Color(0xFF22C55E); // yashil
      case InstallmentStatus.partial:
        return const Color(0xFF3B82F6); // ko'k
      case InstallmentStatus.near:
        return const Color(0xFFF59E0B); // sariq
      case InstallmentStatus.overdue:
        return const Color(0xFFEF4444); // qizil
      case InstallmentStatus.pending:
        return const Color(0xFF94A3B8); // kulrang (background ustida ko'rinmaydi)
    }
  }
}

// ─── Status chip ──────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final InstallmentPlanStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(color: status.backgroundColor, borderRadius: BorderRadius.circular(20.r)),
      child: Text(
        status.label,
        style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: status.color),
      ),
    );
  }
}

// ─── Payment Sheet ────────────────────────────────────────────────────────────

class _PaymentSheet extends StatefulWidget {
  final InstallmentPlanModel plan;
  final InstallmentDetailCubit cubit;
  final VoidCallback onSuccess;
  final ValueChanged<String> onError;

  const _PaymentSheet({required this.plan, required this.cubit, required this.onSuccess, required this.onError});

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  bool _isLoading = false;
  late DateTime _paidAt;

  bool get _isOverLimit {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(' ', '')) ?? 0;
    return amount > widget.plan.remaining;
  }

  @override
  void initState() {
    super.initState();
    _paidAt = DateTime.now();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paidAt,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(primary: AppTheme.colors.primary, onPrimary: Colors.white, surface: AppTheme.colors.white),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() => _paidAt = picked);
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(' ', '')) ?? 0;
    if (amount <= 0) return;

    if (amount > widget.plan.remaining) {
      widget.onError("Summa qolgan qarzdan oshib ketdi (max: ${NumberFormat('#,###', 'en_US').format(widget.plan.remaining).replaceAll(',', ' ')})");
      return;
    }

    setState(() => _isLoading = true);

    final ok = await widget.cubit.acceptPayment(amount: amount, note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(), paidAt: _paidAt);

    if (!mounted) return;

    if (ok) {
      Navigator.pop(context); // sheet yopiladi
      widget.onSuccess();
    } else {
      setState(() => _isLoading = false);
      final err = widget.cubit.state.actionError ?? 'Xatolik yuz berdi';
      widget.onError(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###', 'en_US');
    final currLabel = widget.plan.currency == PaymentCurrency.uzs ? 'UZS' : 'USD';

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, MediaQuery.of(context).padding.bottom + 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(color: AppTheme.colors.divider, borderRadius: BorderRadius.circular(10.r)),
            ),
          ),
          SizedBox(height: 20.h),

          // Icon + sarlavha
          Row(
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(color: AppTheme.colors.green.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(Icons.payments_rounded, color: AppTheme.colors.green, size: 22.r),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "To'lov qabul qilish",
                    style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w800, color: AppTheme.colors.black),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "Qolgan: ${fmt.format(widget.plan.remaining).replaceAll(',', ' ')} $currLabel",
                    style: TextStyle(fontSize: 12.sp, color: AppTheme.colors.gray, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Summa
          Text(
            'Summa',
            style: TextStyle(fontSize: 12.sp, color: AppTheme.colors.gray, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 6.h),
          _SheetField(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, _ThousandsSeparatorFormatter(), _MaxValueFormatter(widget.plan.remaining)],
                    enabled: !_isLoading,
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w800, color: _isOverLimit ? AppTheme.colors.red : AppTheme.colors.black),
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: TextStyle(color: AppTheme.colors.divider, fontSize: 22.sp, fontWeight: FontWeight.w800),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    autofocus: true,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(color: AppTheme.colors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8.r)),
                  child: Text(
                    currLabel,
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppTheme.colors.primary),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // To'lov sanasi
          Text(
            "To'lov sanasi",
            style: TextStyle(fontSize: 12.sp, color: AppTheme.colors.gray, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 6.h),
          _SheetField(
            onTap: _isLoading ? null : _pickDate,
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 18.r, color: AppTheme.colors.primary),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    _formatPaidAt(_paidAt),
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppTheme.colors.black),
                  ),
                ),
                Icon(Icons.edit_calendar_rounded, size: 16.r, color: AppTheme.colors.gray),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // Izoh
          Text(
            'Izoh',
            style: TextStyle(fontSize: 12.sp, color: AppTheme.colors.gray, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 6.h),
          _SheetField(
            child: TextField(
              controller: _noteCtrl,
              enabled: !_isLoading,
              style: TextStyle(fontSize: 14.sp, color: AppTheme.colors.black),
              decoration: InputDecoration(
                hintText: "Ixtiyoriy izoh...",
                hintStyle: TextStyle(color: AppTheme.colors.gray.withValues(alpha: 0.6), fontSize: 14.sp),
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          SizedBox(height: 20.h),

          // Tasdiqlash
          ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.colors.primary,
              disabledBackgroundColor: AppTheme.colors.green.withValues(alpha: 0.6),
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 52.h),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            ),
            child: _isLoading
                ? SizedBox(
                    width: 22.r,
                    height: 22.r,
                    child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_rounded, size: 20.r),
                      SizedBox(width: 8.w),
                      Text(
                        "Tasdiqlash",
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Sheet Field ──────────────────────────────────────���──────────────────────
/// TextField ni o'rab, barcha border holatlarini (enabled/focused/error/disabled)
/// Theme orqali InputBorder.none ga o'rnatadi — hech qanday chiziq chiqmaydi.
class _SheetField extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _SheetField({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    final inner = Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: const InputDecorationTheme(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(color: AppTheme.colors.background, borderRadius: BorderRadius.circular(14.r)),
        child: child,
      ),
    );

    if (onTap == null) return inner;

    return GestureDetector(onTap: onTap, child: inner);
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

String _formatPaidAt(DateTime dt) {
  return DateFormat('dd.MM.yyyy').format(dt);
}

// ─── Formatter ────────────────────────────────────────────────────────────────

class _ThousandsSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final number = int.tryParse(newValue.text.replaceAll(RegExp(r'[^0-9]'), ''));
    if (number == null) return oldValue;
    final formatted = NumberFormat('#,###', 'en_US').format(number).replaceAll(',', ' ');
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _MaxValueFormatter extends TextInputFormatter {
  final double max;

  const _MaxValueFormatter(this.max);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final number = double.tryParse(newValue.text.replaceAll(RegExp(r'[^0-9]'), ''));
    if (number == null) return oldValue;
    if (number > max) return oldValue;
    return newValue;
  }
}
