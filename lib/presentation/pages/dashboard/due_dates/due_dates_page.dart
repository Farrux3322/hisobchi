import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hisobchi/domain/common/data/user_data.dart';
import 'package:hisobchi/infrastructure/dto/models/due_dates/due_dates_model.dart';
import 'package:hisobchi/infrastructure/repository/due_dates/due_dates_repository.dart';
import 'package:hisobchi/presentation/assets/asset_index.dart';
import 'package:hisobchi/presentation/assets/theme/app_theme.dart';
import 'package:hisobchi/presentation/components/utils/price_extension.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../components/back_button.dart';
import 'cubit/due_dates_cubit.dart';

// ─── Phone formatter ─────────────────────────────────────────────────────────
String _formatPhone(String phone) {
  final clean = phone.replaceAll(RegExp(r'\D'), '');
  if (clean.length == 9) {
    return '+998 ${clean.substring(0, 2)} ${clean.substring(2, 5)} ${clean.substring(5, 7)} ${clean.substring(7, 9)}';
  } else if (clean.length == 12 && clean.startsWith('998')) {
    return '+998 ${clean.substring(3, 5)} ${clean.substring(5, 8)} ${clean.substring(8, 10)} ${clean.substring(10, 12)}';
  }
  return phone;
}

String _formatMoney(String amount) {
  return PriceFormatter.priceFormat(amount);
}

Future<void> _makeCall(String phone) async {
  final uri = Uri(scheme: 'tel', path: phone);
  if (await canLaunchUrl(uri)) await launchUrl(uri);
}

Future<void> _sendSms({
  required String phone,
  required String partnerName,
  required String amount,
  required String currency,
  required bool isCredit,
  String? dueDate,
  int? daysOverdue,
}) async {
  final sender = UserData.name;
  final senderPhone = _formatPhone(UserData.phone);
  final footer = '\nBeruvchi: $sender\nTel: $senderPhone\nManba: E-Hisob';
  String message;

  if (!isCredit) {
    message = 'Hurmatli $partnerName, Sizdan $amount $currency miqdoridagi to\'lov qabul qilindi.\nQabul qiluvchi: $sender\nTel: $senderPhone\nHamkorlik uchun rahmat\nManba: E-Hisob';
  } else if (daysOverdue != null && daysOverdue > 0) {
    message = 'Hurmatli $partnerName, $amount $currency qarz muddati $daysOverdue kun o\'tib ketdi.\nIltimos, tez orada to\'lovni amalga oshiring.$footer';
  } else if (dueDate != null && dueDate.isNotEmpty) {
    message = 'Hurmatli $partnerName, Siz olgan $amount $currency qarz muddati yaqinlashmoqda.\nQaytarish sanasi: $dueDate$footer';
  } else {
    message = 'Hurmatli $partnerName, Sizda $amount $currency qarz mavjud.$footer';
  }

  final uri = Uri.parse('sms:$phone?body=${Uri.encodeComponent(message)}');
  if (await canLaunchUrl(uri)) await launchUrl(uri);
}

/// Entry point — opens the page with a given [initialTabIndex] and [type] key.
/// [qarzType]         e.g. "qarz_expired" / "qarz_today" / "qarz_3_days"
/// [installmentType]  e.g. "installment_expired" / "installment_today" / "installment_3_days"
class DueDatesPage extends StatelessWidget {
  final String title;
  final String qarzType;
  final String installmentType;
  final int initialTabIndex;
  final int qarzCount;
  final int installmentCount;

  const DueDatesPage({
    super.key,
    required this.title,
    required this.qarzType,
    required this.installmentType,
    this.initialTabIndex = 0,
    this.qarzCount = 0,
    this.installmentCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final repo = DueDatesRepository();
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => QarzDueDatesCubit(repo: repo, type: qarzType)..load()),
        BlocProvider(create: (_) => InstallmentDueDatesCubit(repo: repo, type: installmentType)..load()),
      ],
      child: _DueDatesView(
        title: title,
        initialTabIndex: initialTabIndex,
        qarzCount: qarzCount,
        installmentCount: installmentCount,
      ),
    );
  }
}

class _DueDatesView extends StatefulWidget {
  final String title;
  final int initialTabIndex;
  final int qarzCount;
  final int installmentCount;

  const _DueDatesView({
    required this.title,
    required this.initialTabIndex,
    required this.qarzCount,
    required this.installmentCount,
  });

  @override
  State<_DueDatesView> createState() => _DueDatesViewState();
}

class _DueDatesViewState extends State<_DueDatesView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTabIndex);
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
        leading: BackArrowButton(),
        title: Text(widget.title)
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSegmentedTab(),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [_QarzTab(), _InstallmentTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedTab() {
    final selectedIndex = _tabController.index;
    final tabs = [
      (label: 'Qarzdor', count: widget.qarzCount),
      (label: 'Muddatli to\'lov', count: widget.installmentCount),
    ];

    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) {
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Tab 0
                Expanded(
                  child: GestureDetector(
                    onTap: () => _tabController.animateTo(0),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tabs[0].label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: selectedIndex == 0 ? FontWeight.w800 : FontWeight.w500,
                              color: selectedIndex == 0 ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                            ),
                          ),
                          if (tabs[0].count > 0) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: selectedIndex == 0 ? const Color(0xFF0F172A).withValues(alpha: 0.1) : const Color(0xFFCBD5E1).withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${tabs[0].count}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: selectedIndex == 0 ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // || divider
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 2, height: 12, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 2),
                    Container(width: 2, height: 12, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2))),
                  ],
                ),

                // Tab 1
                Expanded(
                  child: GestureDetector(
                    onTap: () => _tabController.animateTo(1),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tabs[1].label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: selectedIndex == 1 ? FontWeight.w800 : FontWeight.w500,
                              color: selectedIndex == 1 ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                            ),
                          ),
                          if (tabs[1].count > 0) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: selectedIndex == 1 ? const Color(0xFF0F172A).withValues(alpha: 0.1) : const Color(0xFFCBD5E1).withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${tabs[1].count}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: selectedIndex == 1 ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Qarz Tab ────────────────────────────────────────────────────────────────

class _QarzTab extends StatefulWidget {
  const _QarzTab();

  @override
  State<_QarzTab> createState() => _QarzTabState();
}

class _QarzTabState extends State<_QarzTab> {
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
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent * 0.9) {
      context.read<QarzDueDatesCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QarzDueDatesCubit, QarzDueDatesState>(
      builder: (context, state) {
        if (state.status == DueDatesStatus.loading) {
          return _ShimmerList();
        }
        if (state.status == DueDatesStatus.failure) {
          return _ErrorView(message: state.error ?? 'Xatolik yuz berdi', onRetry: () => context.read<QarzDueDatesCubit>().load());
        }
        if (state.items.isEmpty) {
          return const _EmptyView(message: 'Ma\'lumot topilmadi');
        }
        return RefreshIndicator(
          onRefresh: () => context.read<QarzDueDatesCubit>().refresh(),
          color: AppTheme.colors.primary,
          child: ListView.separated(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
            itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
            separatorBuilder: (_, __) => SizedBox(height: 10.h),
            itemBuilder: (context, index) {
              if (index >= state.items.length) return _LoadMoreIndicator();
              return _QarzCard(item: state.items[index]);
            },
          ),
        );
      },
    );
  }
}

// ─── Installment Tab ─────────────────────────────────────────────────────────

class _InstallmentTab extends StatefulWidget {
  const _InstallmentTab();

  @override
  State<_InstallmentTab> createState() => _InstallmentTabState();
}

class _InstallmentTabState extends State<_InstallmentTab> {
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
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent * 0.9) {
      context.read<InstallmentDueDatesCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InstallmentDueDatesCubit, InstallmentDueDatesState>(
      builder: (context, state) {
        if (state.status == DueDatesStatus.loading) {
          return _ShimmerList();
        }
        if (state.status == DueDatesStatus.failure) {
          return _ErrorView(message: state.error ?? 'Xatolik yuz berdi', onRetry: () => context.read<InstallmentDueDatesCubit>().load());
        }
        if (state.items.isEmpty) {
          return const _EmptyView(message: 'Ma\'lumot topilmadi');
        }
        return RefreshIndicator(
          onRefresh: () => context.read<InstallmentDueDatesCubit>().refresh(),
          color: AppTheme.colors.primary,
          child: ListView.separated(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
            itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
            separatorBuilder: (_, __) => SizedBox(height: 10.h),
            itemBuilder: (context, index) {
              if (index >= state.items.length) return _LoadMoreIndicator();
              return _InstallmentCard(item: state.items[index]);
            },
          ),
        );
      },
    );
  }
}

// ─── Qarz Card ───────────────────────────────────────────────────────────────

class _QarzCard extends StatelessWidget {
  final QarzDueItem item;
  const _QarzCard({required this.item});

  Color get _statusColor {
    if (item.daysOverdue != null && item.daysOverdue! > 0) return const Color(0xFFEF4444);
    if (item.daysLeft != null && item.daysLeft! <= 3) return const Color(0xFFF59E0B);
    return const Color(0xFF3B82F6);
  }

  Color get _statusBg {
    if (item.daysOverdue != null && item.daysOverdue! > 0) return const Color(0xFFFFF0ED);
    if (item.daysLeft != null && item.daysLeft! <= 3) return const Color(0xFFFFFBEB);
    return const Color(0xFFEFF6FF);
  }

  String get _dueBadgeText {
    if (item.daysOverdue != null && item.daysOverdue! > 0) return '${item.daysOverdue} kun kechikkan';
    if (item.daysLeft != null) return '${item.daysLeft} kun qoldi';
    return item.status;
  }

  IconData get _statusIcon {
    if (item.daysOverdue != null && item.daysOverdue! > 0) return Icons.warning_amber_rounded;
    if (item.daysLeft != null && item.daysLeft! <= 3) return Icons.hourglass_bottom_rounded;
    return Icons.schedule_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final scheduled = double.tryParse(item.scheduledAmount) ?? 1;
    final paid = double.tryParse(item.paidAmount) ?? 0;
    final progress = (paid / scheduled).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () => _QarzDetailSheet.show(context, item),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: _statusColor.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38.w,
                        height: 38.w,
                        decoration: BoxDecoration(color: _statusColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: Center(
                          child: Text(
                            item.partnerName.isNotEmpty ? item.partnerName[0].toUpperCase() : '?',
                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: _statusColor),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.partnerName, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)), maxLines: 1, overflow: TextOverflow.ellipsis),
                            SizedBox(height: 2.h),
                            Row(
                              children: [
                                Icon(Icons.phone_outlined, size: 12.sp, color: const Color(0xFF94A3B8)),
                                SizedBox(width: 3.w),
                                Text(_formatPhone(item.partnerPhone), style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(color: _statusBg, borderRadius: BorderRadius.circular(8.r)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_statusIcon, size: 11.sp, color: _statusColor),
                            SizedBox(width: 3.w),
                            Text(_dueBadgeText, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: _statusColor)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      _AmountChip(label: 'Jami', amount: item.scheduledAmount, currency: item.currencyTypeName, color: const Color(0xFF475569)),
                      SizedBox(width: 8.w),
                      _AmountChip(label: 'To\'langan', amount: item.paidAmount, currency: item.currencyTypeName, color: const Color(0xFF22C55E)),
                      SizedBox(width: 8.w),
                      _AmountChip(label: 'Qolgan', amount: item.remainingAmount, currency: item.currencyTypeName, color: const Color(0xFFEF4444), bold: true),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  _ProgressBar(progress: progress, color: _statusColor),
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.status, style: TextStyle(fontSize: 11.sp, color: _statusColor, fontWeight: FontWeight.w600)),
                      Text('${(progress * 100).toStringAsFixed(0)}% to\'langan', style: TextStyle(fontSize: 11.sp, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(14.r), bottomRight: Radius.circular(14.r)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 12.sp, color: const Color(0xFF94A3B8)),
                  SizedBox(width: 4.w),
                  Text('Muddat: ${item.dueDate}', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w500)),
                  const Spacer(),
                  _CurrencyBadge(currency: item.currencyTypeName),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Installment Card ────────────────────────────────────────────────────────

class _InstallmentCard extends StatelessWidget {
  final InstallmentDueItem item;
  const _InstallmentCard({required this.item});

  Color get _statusColor {
    if (item.daysOverdue != null && item.daysOverdue! > 0) return const Color(0xFFEF4444);
    if (item.daysLeft != null && item.daysLeft! <= 3) return const Color(0xFFF59E0B);
    return const Color(0xFF3B82F6);
  }

  Color get _statusBg {
    if (item.daysOverdue != null && item.daysOverdue! > 0) return const Color(0xFFFFF0ED);
    if (item.daysLeft != null && item.daysLeft! <= 3) return const Color(0xFFFFFBEB);
    return const Color(0xFFEFF6FF);
  }

  String get _dueBadgeText {
    if (item.daysOverdue != null && item.daysOverdue! > 0) return '${item.daysOverdue} kun kechikkan';
    if (item.daysLeft != null) return '${item.daysLeft} kun qoldi';
    return item.statusLabel;
  }

  @override
  Widget build(BuildContext context) {
    final paid = double.tryParse(item.planPaid) ?? 0;
    final total = double.tryParse(item.planTotal) ?? 1;
    final progress = (paid / total).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () => _InstallmentDetailSheet.show(context, item),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: _statusColor.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38.w,
                        height: 38.w,
                        decoration: BoxDecoration(color: _statusColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: Center(
                          child: Text(
                            item.partnerName.isNotEmpty ? item.partnerName[0].toUpperCase() : '?',
                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: _statusColor),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.partnerName, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B)), maxLines: 1, overflow: TextOverflow.ellipsis),
                            SizedBox(height: 2.h),
                            Row(
                              children: [
                                Icon(Icons.phone_outlined, size: 12.sp, color: const Color(0xFF94A3B8)),
                                SizedBox(width: 3.w),
                                Text(_formatPhone(item.partnerPhone), style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(color: _statusBg, borderRadius: BorderRadius.circular(8.r)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(item.daysOverdue != null && item.daysOverdue! > 0 ? Icons.warning_amber_rounded : Icons.hourglass_bottom_rounded, size: 11.sp, color: _statusColor),
                            SizedBox(width: 3.w),
                            Text(_dueBadgeText, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: _statusColor)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8.r)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 13.sp, color: const Color(0xFF64748B)),
                        SizedBox(width: 5.w),
                        Text(item.isAdvance ? '${item.itemNumber}-to\'lov (avans)' : '${item.itemNumber}-to\'lov', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF475569))),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      _AmountChip(label: 'To\'lov', amount: item.amount, currency: item.currencyTypeName, color: const Color(0xFF475569)),
                      SizedBox(width: 8.w),
                      _AmountChip(label: 'To\'langan', amount: item.paidAmount, currency: item.currencyTypeName, color: const Color(0xFF22C55E)),
                      SizedBox(width: 8.w),
                      _AmountChip(label: 'Qolgan', amount: item.remaining, currency: item.currencyTypeName, color: const Color(0xFFEF4444), bold: true),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Text('Reja:', style: TextStyle(fontSize: 11.sp, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
                      SizedBox(width: 4.w),
                      Expanded(child: _ProgressBar(progress: progress, color: _statusColor)),
                      SizedBox(width: 8.w),
                      Text('${(progress * 100).toStringAsFixed(0)}%', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: _statusColor)),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Jami reja: ${PriceFormatter.priceFormat(item.planTotal)} ${item.currencyTypeName}', style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B))),
                      Text(item.statusLabel, style: TextStyle(fontSize: 11.sp, color: _statusColor, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(14.r), bottomRight: Radius.circular(14.r)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 12.sp, color: const Color(0xFF94A3B8)),
                  SizedBox(width: 4.w),
                  Text('Muddat: ${item.dueDate}', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w500)),
                  const Spacer(),
                  _CurrencyBadge(currency: item.currencyTypeName),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared small widgets ─────────────────────────────────────────────────────

class _AmountChip extends StatelessWidget {
  final String label;
  final String amount;
  final String currency;
  final Color color;
  final bool bold;

  const _AmountChip({required this.label, required this.amount, required this.currency, required this.color, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10.sp, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
          SizedBox(height: 2.h),
          Text(
            PriceFormatter.priceFormat(amount),
            style: TextStyle(fontSize: 12.sp, fontWeight: bold ? FontWeight.w800 : FontWeight.w600, color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(currency, style: TextStyle(fontSize: 10.sp, color: const Color(0xFF94A3B8))),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;
  final Color color;

  const _ProgressBar({required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: Stack(
            children: [
              Container(height: 6.h, width: constraints.maxWidth, color: color.withValues(alpha: 0.12)),
              Container(height: 6.h, width: constraints.maxWidth * progress, color: color),
            ],
          ),
        );
      },
    );
  }
}

// ─── Currency badge ───────────────────────────────────────────────────────────

class _CurrencyBadge extends StatelessWidget {
  final String currency;
  const _CurrencyBadge({required this.currency});

  @override
  Widget build(BuildContext context) {
    final isUsd = currency == 'USD';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: isUsd ? const Color(0xFFEFF6FF) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        currency,
        style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: isUsd ? const Color(0xFF3B82F6) : const Color(0xFF22C55E)),
      ),
    );
  }
}

// ─── Shared sheet helpers ─────────────────────────────────────────────────────

Widget _sheetHandle() => Builder(
      builder: (ctx) => Container(
        margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
        width: 36.w,
        height: 4.h,
        decoration: BoxDecoration(color: AppTheme.colors.gray.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10.r)),
      ),
    );

Widget _sheetInfoTile({required String label, required String value, required Color color, required IconData icon, bool isUrgent = false, Widget? trailing}) {
  return Container(
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: const Color(0xFFF1F5F9)),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))],
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 12.sp, color: color.withValues(alpha: 0.5)),
                  SizedBox(width: 6.w),
                  Expanded(child: Text(label, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: Colors.black54, letterSpacing: 0.4), maxLines: 1, overflow: TextOverflow.ellipsis)),
                ],
              ),
              SizedBox(height: 4.h),
              Text(value, style: TextStyle(fontSize: 14.sp, fontWeight: isUrgent ? FontWeight.w800 : FontWeight.w700, color: isUrgent ? color : const Color(0xFF1E293B)), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        if (trailing != null) ...[SizedBox(width: 8.w), trailing],
      ],
    ),
  );
}

Widget _sheetAmountRow(String label, String amount, String currency, {Color? color, bool isBold = false}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
      RichText(
        text: TextSpan(children: [
          TextSpan(text: PriceFormatter.priceFormat(amount), style: TextStyle(fontSize: isBold ? 15.sp : 14.sp, fontWeight: isBold ? FontWeight.w800 : FontWeight.w700, color: color ?? const Color(0xFF334155))),
          TextSpan(text: ' $currency', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8))),
        ]),
      ),
    ],
  );
}

Widget _sheetPhoneActions(String phone, String partnerName, String amount, String currency, bool isCredit, String? dueDate, int? daysOverdue) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      GestureDetector(
        onTap: () => _sendSms(phone: phone, partnerName: partnerName, amount: amount, currency: currency, isCredit: isCredit, dueDate: dueDate, daysOverdue: daysOverdue),
        child: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(color: const Color(0xFF6366F1).withValues(alpha: 0.1), shape: BoxShape.circle),
          child: SvgPicture.asset(AppIcons.sms, width: 18.w, height: 18.w, colorFilter: const ColorFilter.mode(Color(0xFF6366F1), BlendMode.srcIn)),
        ),
      ),
      SizedBox(width: 8.w),
      GestureDetector(
        onTap: () => _makeCall(phone),
        child: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), shape: BoxShape.circle),
          child: SvgPicture.asset(AppIcons.phone, width: 18.w, height: 18.w, colorFilter: const ColorFilter.mode(Color(0xFF10B981), BlendMode.srcIn)),
        ),
      ),
    ],
  );
}

// ─── Qarz detail bottom sheet ─────────────────────────────────────────────────

class _QarzDetailSheet extends StatelessWidget {
  final QarzDueItem item;
  const _QarzDetailSheet({required this.item});

  static void show(BuildContext context, QarzDueItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _QarzDetailSheet(item: item),
    );
  }

  Color get _statusColor {
    if (item.daysOverdue != null && item.daysOverdue! > 0) return const Color(0xFFEF4444);
    if (item.daysLeft != null && item.daysLeft! <= 3) return const Color(0xFFF59E0B);
    return const Color(0xFF3B82F6);
  }

  @override
  Widget build(BuildContext context) {
    final isCredit = item.type == 'credit';
    final brandColor = isCredit ? const Color(0xFFE11D48) : const Color(0xFF10B981);
    final surfaceColor = isCredit ? const Color(0xFFFFF1F2) : const Color(0xFFECFDF5);
    final borderColor = isCredit ? const Color(0xFFFECDD3) : const Color(0xFFD1FAE5);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.colors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 40, offset: const Offset(0, -12))],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sheetHandle(),
              // Header
              Container(
                padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
                decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(20.r), border: Border.all(color: borderColor)),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(color: brandColor, shape: BoxShape.circle, boxShadow: [BoxShadow(color: brandColor.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))]),
                      child: Icon(isCredit ? Icons.north_east_rounded : Icons.south_west_rounded, color: Colors.white, size: 16.sp),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(isCredit ? 'QARZ' : 'KIRIM', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: brandColor.withValues(alpha: 0.6), letterSpacing: 1)),
                          RichText(
                            text: TextSpan(children: [
                              TextSpan(text: '${isCredit ? '-' : '+'}${PriceFormatter.priceFormat(item.remainingAmount)} ', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A), letterSpacing: -0.5)),
                              TextSpan(text: item.currencyTypeName, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF64748B))),
                            ]),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.8), shape: BoxShape.circle),
                        child: Icon(Icons.close_rounded, size: 18.sp, color: AppTheme.colors.gray),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              // Name + date
              Row(
                children: [
                  Expanded(child: _sheetInfoTile(label: 'Mijoz', value: item.partnerName, color: const Color(0xFF6366F1), icon: Icons.person_rounded)),
                  SizedBox(width: 12.w),
                  Expanded(child: _sheetInfoTile(label: 'Yaratilgan', value: item.createdAt, color: const Color(0xFFF59E0B), icon: Icons.calendar_today_rounded)),
                ],
              ),
              // Phone
              if (item.partnerPhone.isNotEmpty) ...[
                SizedBox(height: 12.h),
                _sheetInfoTile(
                  label: 'Telefon',
                  value: _formatPhone(item.partnerPhone),
                  color: const Color(0xFF8B5CF6),
                  icon: Icons.phone_rounded,
                  trailing: _sheetPhoneActions(item.partnerPhone, item.partnerName, PriceFormatter.priceFormat(item.remainingAmount), item.currencyTypeName, isCredit, item.dueDate, item.daysOverdue),
                ),
              ],
              // Due date + status
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: _sheetInfoTile(
                      label: item.daysOverdue != null && item.daysOverdue! > 0 ? 'Muddati o\'tgan' : 'Qaytarish sanasi',
                      value: item.dueDate,
                      color: _statusColor,
                      icon: item.daysOverdue != null && item.daysOverdue! > 0 ? Icons.error_outline_rounded : Icons.schedule_rounded,
                      isUrgent: item.daysOverdue != null && item.daysOverdue! > 0,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(child: _sheetInfoTile(label: 'Holati', value: item.status, color: const Color(0xFF10B981), icon: Icons.info_outline_rounded)),
                ],
              ),
              // Overdue banner
              if (item.daysOverdue != null && item.daysOverdue! > 0) ...[
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(16.r), border: Border.all(color: const Color(0xFFFECDD3))),
                  child: Row(
                    children: [
                      Container(padding: EdgeInsets.all(6.w), decoration: BoxDecoration(color: const Color(0xFFEF4444).withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(Icons.notification_important_rounded, size: 16.sp, color: const Color(0xFFEF4444))),
                      SizedBox(width: 10.w),
                      Expanded(child: Text('${item.daysOverdue} kun muddati o\'tgan', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: const Color(0xFFB91C1C)))),
                    ],
                  ),
                ),
              ] else if (item.daysLeft != null && item.daysLeft! > 0) ...[
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(16.r), border: Border.all(color: const Color(0xFFFDE68A))),
                  child: Row(
                    children: [
                      Container(padding: EdgeInsets.all(6.w), decoration: BoxDecoration(color: const Color(0xFFF59E0B).withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(Icons.schedule_rounded, size: 16.sp, color: const Color(0xFFF59E0B))),
                      SizedBox(width: 10.w),
                      Expanded(child: Text('${item.daysLeft} kun qoldi', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: const Color(0xFFB45309)))),
                    ],
                  ),
                ),
              ],
              // Amounts detail
              SizedBox(height: 14.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16.r), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [Icon(Icons.account_balance_wallet_rounded, size: 12.sp, color: const Color(0xFF94A3B8)), SizedBox(width: 6.w), Text('Summa tafsilotlari', style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8), letterSpacing: 0.8))]),
                    SizedBox(height: 8.h),
                    _sheetAmountRow('Rejalashtirilgan:', item.scheduledAmount, item.currencyTypeName),
                    SizedBox(height: 4.h),
                    _sheetAmountRow('To\'langan:', item.paidAmount, item.currencyTypeName, color: const Color(0xFF10B981)),
                    SizedBox(height: 4.h),
                    _sheetAmountRow('Qoldiq:', item.remainingAmount, item.currencyTypeName, color: const Color(0xFF6366F1), isBold: true),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Installment detail bottom sheet ─────────────────────────────────────────

class _InstallmentDetailSheet extends StatelessWidget {
  final InstallmentDueItem item;
  const _InstallmentDetailSheet({required this.item});

  static void show(BuildContext context, InstallmentDueItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _InstallmentDetailSheet(item: item),
    );
  }

  Color get _statusColor {
    if (item.daysOverdue != null && item.daysOverdue! > 0) return const Color(0xFFEF4444);
    if (item.daysLeft != null && item.daysLeft! <= 3) return const Color(0xFFF59E0B);
    return const Color(0xFF3B82F6);
  }

  @override
  Widget build(BuildContext context) {
    final paid = double.tryParse(item.planPaid) ?? 0;
    final total = double.tryParse(item.planTotal) ?? 1;
    final progress = (paid / total).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.colors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 40, offset: const Offset(0, -12))],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sheetHandle(),
              // Header
              Container(
                padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(20.r), border: Border.all(color: const Color(0xFFBFDBFE))),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(color: const Color(0xFF3B82F6), shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))]),
                      child: Icon(Icons.receipt_long_rounded, color: Colors.white, size: 16.sp),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.isAdvance ? 'AVANS TO\'LOV' : '${item.itemNumber}-TO\'LOV', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: const Color(0xFF3B82F6).withValues(alpha: 0.7), letterSpacing: 1)),
                          RichText(
                            text: TextSpan(children: [
                              TextSpan(text: '${PriceFormatter.priceFormat(item.remaining)} ', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A), letterSpacing: -0.5)),
                              TextSpan(text: item.currencyTypeName, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF64748B))),
                            ]),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.8), shape: BoxShape.circle),
                        child: Icon(Icons.close_rounded, size: 18.sp, color: AppTheme.colors.gray),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              // Partner name + date
              Row(
                children: [
                  Expanded(child: _sheetInfoTile(label: 'Mijoz', value: item.partnerName, color: const Color(0xFF6366F1), icon: Icons.person_rounded)),
                  SizedBox(width: 12.w),
                  Expanded(child: _sheetInfoTile(label: 'Muddat', value: item.dueDate, color: _statusColor, icon: Icons.calendar_today_rounded, isUrgent: item.daysOverdue != null && item.daysOverdue! > 0)),
                ],
              ),
              // Phone
              if (item.partnerPhone.isNotEmpty) ...[
                SizedBox(height: 12.h),
                _sheetInfoTile(
                  label: 'Telefon',
                  value: _formatPhone(item.partnerPhone),
                  color: const Color(0xFF8B5CF6),
                  icon: Icons.phone_rounded,
                  trailing: _sheetPhoneActions(item.partnerPhone, item.partnerName, PriceFormatter.priceFormat(item.remaining), item.currencyTypeName, true, item.dueDate, item.daysOverdue),
                ),
              ],
              // Status + holat
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(child: _sheetInfoTile(label: 'Holati', value: item.statusLabel, color: _statusColor, icon: Icons.info_outline_rounded, isUrgent: item.daysOverdue != null && item.daysOverdue! > 0)),
                  SizedBox(width: 12.w),
                  Expanded(child: _sheetInfoTile(label: 'Reja holati', value: item.planStatus, color: const Color(0xFF10B981), icon: Icons.assignment_outlined)),
                ],
              ),
              // Overdue / days left banner
              if (item.daysOverdue != null && item.daysOverdue! > 0) ...[
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(16.r), border: Border.all(color: const Color(0xFFFECDD3))),
                  child: Row(
                    children: [
                      Container(padding: EdgeInsets.all(6.w), decoration: BoxDecoration(color: const Color(0xFFEF4444).withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(Icons.notification_important_rounded, size: 16.sp, color: const Color(0xFFEF4444))),
                      SizedBox(width: 10.w),
                      Expanded(child: Text('${item.daysOverdue} kun muddati o\'tgan', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: const Color(0xFFB91C1C)))),
                    ],
                  ),
                ),
              ] else if (item.daysLeft != null && item.daysLeft! > 0) ...[
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(16.r), border: Border.all(color: const Color(0xFFFDE68A))),
                  child: Row(
                    children: [
                      Container(padding: EdgeInsets.all(6.w), decoration: BoxDecoration(color: const Color(0xFFF59E0B).withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(Icons.schedule_rounded, size: 16.sp, color: const Color(0xFFF59E0B))),
                      SizedBox(width: 10.w),
                      Expanded(child: Text('${item.daysLeft} kun qoldi', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: const Color(0xFFB45309)))),
                    ],
                  ),
                ),
              ],
              // This payment amounts
              SizedBox(height: 14.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16.r), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [Icon(Icons.receipt_outlined, size: 12.sp, color: const Color(0xFF94A3B8)), SizedBox(width: 6.w), Text('To\'lov tafsiloti', style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8), letterSpacing: 0.8))]),
                    SizedBox(height: 8.h),
                    _sheetAmountRow('To\'lov summasi:', item.amount, item.currencyTypeName),
                    SizedBox(height: 4.h),
                    _sheetAmountRow('To\'langan:', item.paidAmount, item.currencyTypeName, color: const Color(0xFF10B981)),
                    SizedBox(height: 4.h),
                    _sheetAmountRow('Qolgan:', item.remaining, item.currencyTypeName, color: const Color(0xFF6366F1), isBold: true),
                  ],
                ),
              ),
              // Plan progress
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16.r), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [Icon(Icons.bar_chart_rounded, size: 12.sp, color: const Color(0xFF94A3B8)), SizedBox(width: 6.w), Text('Reja jarayoni', style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w800, color: const Color(0xFF94A3B8), letterSpacing: 0.8))]),
                    SizedBox(height: 10.h),
                    _ProgressBar(progress: progress, color: _statusColor),
                    SizedBox(height: 8.h),
                    _sheetAmountRow('Jami reja:', item.planTotal, item.currencyTypeName),
                    SizedBox(height: 4.h),
                    _sheetAmountRow('To\'langan:', item.planPaid, item.currencyTypeName, color: const Color(0xFF10B981)),
                    SizedBox(height: 4.h),
                    _sheetAmountRow('Qolgan:', item.planRemaining, item.currencyTypeName, color: const Color(0xFF6366F1), isBold: true),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadMoreIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Center(child: SizedBox(width: 24.w, height: 24.w, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.colors.primary))),
    );
  }
}

class _ShimmerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
        itemCount: 6,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (_, __) => Container(
          height: 160.h,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14.r)),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String message;
  const _EmptyView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 56.sp, color: const Color(0xFFCBD5E1)),
          SizedBox(height: 12.h),
          Text(message, style: TextStyle(fontSize: 14.sp, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
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
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 52.sp, color: const Color(0xFFCBD5E1)),
            SizedBox(height: 12.h),
            Text(message, style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B)), textAlign: TextAlign.center),
            SizedBox(height: 16.h),
            TextButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh_rounded, size: 18.sp),
              label: const Text('Qayta urinish'),
              style: TextButton.styleFrom(foregroundColor: AppTheme.colors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
