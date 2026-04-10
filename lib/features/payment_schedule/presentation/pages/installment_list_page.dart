import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi/presentation/components/back_button.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import '../../../../presentation/assets/asset_index.dart';
import '../../../../presentation/components/subscription/subscription_guard.dart';
import '../../../../presentation/pages/client/report/installment_report_page.dart';
import '../../data/models/enums.dart';
import '../../data/models/installment_item_model.dart';
import '../../data/models/installment_plan_model.dart';
import '../../data/models/payment_partner_model.dart';
import '../cubit/installment_list_cubit.dart';
import 'installment_detail_page.dart';
import 'payment_schedule_page.dart';

class InstallmentListPage extends StatelessWidget {
  final PaymentPartnerModel partner;

  const InstallmentListPage({super.key, required this.partner});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InstallmentListCubit(partnerId: int.tryParse(partner.id) ?? 0)..load(),
      child: _InstallmentListView(partner: partner),
    );
  }
}

class _InstallmentListView extends StatelessWidget {
  final PaymentPartnerModel partner;

  const _InstallmentListView({required this.partner});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.colors.white,
        elevation: 0,
        leading: BackArrowButton(),
        title: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bo'lib to'lash",
              style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w800, color: AppTheme.colors.black),
            ),
            Text(
              partner.name,
              style: TextStyle(fontSize: 12.sp, color: AppTheme.colors.gray, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      floatingActionButton: SubscriptionGuard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 56.w,
              height: 56.w,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18.r),
                child: FloatingActionButton(
                  tooltip: "Mijozlar hisoboti",
                  heroTag: 'client_report_fab',
                  elevation: 0,
                  focusElevation: 0,
                  hoverElevation: 0,
                  highlightElevation: 0,
                  onPressed: () {
                    // if (!context.hasPermission('report_partners.view')) {
                    //   Toast.showWarningToast(message: "Sizda bunday huquq yo'q");
                    //   return;
                    // }
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const InstallmentReportPage()));
                  },
                  backgroundColor: AppTheme.colors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.r),
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                  ),
                  child: Icon(Icons.analytics_rounded, color: AppTheme.colors.white, size: 28.sp),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: 56.w,
              height: 56.w,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18.r),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: FloatingActionButton(
                    heroTag: 'client_fab_1',
                    elevation: 0,
                    focusElevation: 0,
                    hoverElevation: 0,
                    highlightElevation: 0,
                    onPressed: ()=> _openCreate(context),
                    // onPressed: () {
                    //   if (!context.hasPermission('partners.create')) {
                    //     Toast.showWarningToast(message: "Sizda bunday huquq yo'q");
                    //     return;
                    //   }
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) => BlocProvider(
                    //         create: (context) => FileUploadBloc(repository: FileUploadRepository()),
                    //         child: const ClientAddPage(),
                    //       ),
                    //     ),
                    //   ).then((v) {
                    //     if (v is PartnerModel && context.mounted) {
                    //       Navigator.push(context, MaterialPageRoute(builder: (_) => AccountPage(partnerModel: v))).then((_) {
                    //         if (context.mounted) {
                    //           context.read<PartnerBloc>().add(const GetAllEvent());
                    //         }
                    //       });
                    //     } else if (v == true && context.mounted) {
                    //       context.read<PartnerBloc>().add(const GetAllEvent());
                    //     }
                    //   });
                    // },
                    backgroundColor: AppTheme.colors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.r),
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                    ),
                    child: Icon(Icons.add, color: Colors.white, size: 36.sp),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // floatingActionButton: SubscriptionGuard(
      //   child: SizedBox(
      //     width: 56.w,
      //     height: 56.w,
      //     child: FloatingActionButton(
      //       heroTag: 'project_fab',
      //       elevation: 4,
      //       onPressed: () => _openCreate(context),
      //       backgroundColor: AppTheme.colors.primary,
      //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      //       child: Icon(Icons.add, color: Colors.white, size: 36.sp),
      //     ),
      //   ),
      // ),
      body: Column(
        children: [
          _StatusFilterBar(),
          Expanded(
            child: BlocBuilder<InstallmentListCubit, InstallmentListState>(
              builder: (context, state) {
                if (state.status == InstallmentListStatus.loading && state.plans.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.status == InstallmentListStatus.failure) {
                  return _ErrorView(message: state.errorMessage ?? 'Xatolik yuz berdi', onRetry: () => context.read<InstallmentListCubit>().load(refresh: true));
                }
                if (state.plans.isEmpty) {
                  return _EmptyView(onAdd: () => _openCreate(context));
                }
                final cubit = context.read<InstallmentListCubit>();
                return RefreshIndicator(
                  onRefresh: () => cubit.load(refresh: true),
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
                    itemCount: state.plans.length,
                    separatorBuilder: (_, __) => SizedBox(height: 10.h),
                    itemBuilder: (_, i) => _PlanCard(plan: state.plans[i], onTap: () => _openDetail(context, state.plans[i])),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openCreate(BuildContext context) {
    pushScreen(context, screen: PaymentSchedulePage(initialPartner: partner)).then((created) {
      if (created == true && context.mounted) {
        context.read<InstallmentListCubit>().refresh();
      }
    });
  }

  void _openDetail(BuildContext context, InstallmentPlanModel plan) {
    pushScreen(context, screen: InstallmentDetailPage(id: plan.id)).then((changed) {
      if (changed == true && context.mounted) {
        context.read<InstallmentListCubit>().refresh();
      }
    });
  }
}

// ─── Status Filter Bar ────────────────────────────────────────────────────────

class _StatusFilterBar extends StatelessWidget {
  static const _statuses = [null, 'active', 'completed', 'cancelled'];
  static const _labels = ['Barchasi', 'Faol', "To'langan", 'Bekor'];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InstallmentListCubit, InstallmentListState>(
      buildWhen: (prev, curr) => prev.filterStatus != curr.filterStatus,
      builder: (context, state) {
        final selectedIndex = _statuses.indexOf(state.filterStatus).clamp(0, _statuses.length - 1);

        return Container(
          color: AppTheme.colors.white,
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
          child: MergeSemantics(
            child: CupertinoSlidingSegmentedControl<int>(
              groupValue: selectedIndex,
              backgroundColor: CupertinoColors.systemGrey6,
              thumbColor: AppTheme.colors.white,
              padding: EdgeInsets.all(3.r),
              children: {for (int i = 0; i < _labels.length; i++) i: _SegmentTab(label: _labels[i], isSelected: selectedIndex == i)},
              onValueChanged: (index) {
                if (index == null) return;
                context.read<InstallmentListCubit>().setStatusFilter(_statuses[index]);
              },
            ),
          ),
        );
      },
    );
  }
}

class _SegmentTab extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _SegmentTab({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 7.h),
      child: Text(
        label,
        style: TextStyle(fontSize: 13.sp, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? AppTheme.colors.primary : AppTheme.colors.gray),
      ),
    );
  }
}

// ─── Plan Card ────────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final InstallmentPlanModel plan;
  final VoidCallback onTap;

  const _PlanCard({required this.plan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###', 'en_US');
    final progress = plan.totalAmount > 0 ? (plan.paidAmount / plan.totalAmount).clamp(0.0, 1.0) : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppTheme.colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: sana + status
            Row(
              children: [
                Icon(Icons.calendar_month_outlined, size: 16.r, color: AppTheme.colors.gray),
                SizedBox(width: 4.w),
                Text(
                  plan.createdAt,
                  style: TextStyle(fontSize: 12.sp, color: AppTheme.colors.gray, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                _StatusChip(status: plan.status),
              ],
            ),
            SizedBox(height: 10.h),

            // Jami summa
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jami summa',
                        style: TextStyle(fontSize: 11.sp, color: AppTheme.colors.gray, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        fmt.format(plan.totalAmount).replaceAll(',', ' '),
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: AppTheme.colors.black),
                      ),
                    ],
                  ),
                ),
                // Qismlar soni
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Qismlar',
                      style: TextStyle(fontSize: 11.sp, color: AppTheme.colors.gray, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${plan.totalCount} ta',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppTheme.colors.black),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Progress bar
            plan.items.isNotEmpty
                ? _SegmentedProgressBar(items: plan.items, totalAmount: plan.totalAmount)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: LinearProgressIndicator(value: progress, backgroundColor: AppTheme.colors.divider.withValues(alpha: 0.3), color: plan.status.color, minHeight: 6.h),
                  ),
            SizedBox(height: 8.h),

            // To'langan / Qolgan
            Row(
              children: [
                _AmountLabel(label: "To'langan", amount: fmt.format(plan.paidAmount).replaceAll(',', ' '), color: const Color(0xFF22C55E)),
                const Spacer(),
                _AmountLabel(
                  label: 'Qolgan',
                  amount: fmt.format(plan.remaining).replaceAll(',', ' '),
                  color: plan.remaining > 0 ? AppTheme.colors.red : AppTheme.colors.gray,
                  align: CrossAxisAlignment.end,
                ),
              ],
            ),

            // Grafik turi
            if (plan.scheduleType == PaymentScheduleType.equal || plan.scheduleType == PaymentScheduleType.custom) ...[
              SizedBox(height: 10.h),
              Divider(height: 1, color: AppTheme.colors.divider.withValues(alpha: 0.5)),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Icon(plan.scheduleType == PaymentScheduleType.equal ? Icons.calculate_rounded : Icons.edit_calendar_rounded, size: 14.r, color: AppTheme.colors.gray),
                  SizedBox(width: 4.w),
                  Text(
                    plan.scheduleType == PaymentScheduleType.equal ? "Teng bo'lib to'lash" : 'Erkin grafik',
                    style: TextStyle(fontSize: 12.sp, color: AppTheme.colors.gray, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '•',
                    style: TextStyle(color: AppTheme.colors.divider, fontSize: 12.sp),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    plan.currencyTypeName,
                    style: TextStyle(fontSize: 12.sp, color: AppTheme.colors.gray, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Segmented Progress Bar ───────────────────────────────────────────────────

class _SegmentedProgressBar extends StatelessWidget {
  final List<InstallmentItemModel> items;
  final double totalAmount;

  const _SegmentedProgressBar({required this.items, required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty || totalAmount <= 0) return const SizedBox.shrink();

    const double height = 8;

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
                left: isFirst ? const Radius.circular(4) : Radius.zero,
                right: isLast ? const Radius.circular(4) : Radius.zero,
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
        return const Color(0xFF22C55E);
      case InstallmentStatus.partial:
        return const Color(0xFF3B82F6);
      case InstallmentStatus.near:
        return const Color(0xFFF59E0B);
      case InstallmentStatus.overdue:
        return const Color(0xFFEF4444);
      case InstallmentStatus.pending:
        return const Color(0xFF94A3B8);
    }
  }
}

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

class _AmountLabel extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;
  final CrossAxisAlignment align;

  const _AmountLabel({required this.label, required this.amount, required this.color, this.align = CrossAxisAlignment.start});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10.sp, color: AppTheme.colors.gray, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 2.h),
        Text(
          amount,
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: color),
        ),
      ],
    );
  }
}

// ─── Empty & Error ────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyView({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_note_rounded, size: 64.r, color: AppTheme.colors.divider),
          SizedBox(height: 16.h),
          Text(
            "Bo'lib to'lash rejalari yo'q",
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppTheme.colors.gray),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, size: 56.r, color: AppTheme.colors.red),
          SizedBox(height: 12.h),
          Text(
            message,
            style: TextStyle(fontSize: 14.sp, color: AppTheme.colors.gray),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.colors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: const Text('Qayta urinish'),
          ),
        ],
      ),
    );
  }
}
