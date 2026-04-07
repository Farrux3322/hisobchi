import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hisobchi/presentation/components/back_button.dart';
import 'package:intl/intl.dart';

import '../../../../presentation/assets/asset_index.dart';
import '../../data/models/payment_history_model.dart';
import '../cubit/payment_history_cubit.dart';

class PaymentHistoryPage extends StatelessWidget {
  final int installmentId;
  final String partnerName;

  const PaymentHistoryPage({super.key, required this.installmentId, required this.partnerName});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PaymentHistoryCubit(installmentId: installmentId)..loadHistory(),
      child: _PaymentHistoryView(partnerName: partnerName),
    );
  }
}

class _PaymentHistoryView extends StatelessWidget {
  final String partnerName;

  const _PaymentHistoryView({required this.partnerName});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentHistoryCubit, PaymentHistoryState>(
      listenWhen: (prev, curr) => curr.errorMessage != null && prev.errorMessage != curr.errorMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!), backgroundColor: AppTheme.colors.red, behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 3)));
          context.read<PaymentHistoryCubit>().clearError();
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.colors.background,
        appBar: _buildAppBar(context),
        body: BlocBuilder<PaymentHistoryCubit, PaymentHistoryState>(
          builder: (context, state) {
            if (state.status == PaymentHistoryStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == PaymentHistoryStatus.failure) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: _ErrorView(message: state.errorMessage ?? 'Xatolik yuz berdi', onRetry: () => context.read<PaymentHistoryCubit>().loadHistory()),
              );
            }

            if (state.status == PaymentHistoryStatus.success && state.items.isEmpty) {
              return const _EmptyView();
            }

            return _HistoryList(items: state.items);
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.colors.white,
      elevation: 0,
      leading: BackArrowButton(),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "To'lovlar tarixi",
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: AppTheme.colors.black),
          ),
          Text(
            partnerName,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppTheme.colors.black),
          ),
        ],
      ),
    );
  }
}

// ─── History List ─────────────────────────────────────────────────────────────

class _HistoryList extends StatelessWidget {
  final List<PaymentHistoryModel> items;

  const _HistoryList({required this.items});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentHistoryCubit, PaymentHistoryState>(
      builder: (context, state) {
        // State dan eng yangi items ni olamiz (bekor qilgandan keyin yangilanadi)
        final liveItems = state.items.isNotEmpty ? state.items : items;

        // Faqat eng birinchi isCancelled==false element swipe qilinishi mumkin
        final cancellableId = liveItems.firstWhere((e) => !e.isCancelled, orElse: () => liveItems.first).id;
        final hasCancellable = liveItems.any((e) => !e.isCancelled);

        return ListView.builder(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
          itemCount: liveItems.length,
          itemBuilder: (context, index) {
            final item = liveItems[index];
            final isCancelling = state.isCancelling(item.id);
            final canSwipe = hasCancellable && item.id == cancellableId && !isCancelling;

            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Slidable(
                  key: ValueKey(item.id),
                  enabled: canSwipe,
                  endActionPane: ActionPane(
                    extentRatio: 0.35,
                    motion: const StretchMotion(),
                    children: [
                      CustomSlidableAction(
                        onPressed: (_) => _confirmCancel(context, item),
                        backgroundColor: AppTheme.colors.red,
                        foregroundColor: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        padding: EdgeInsets.zero,
                        child: Text('Bekor qilish'),
                      ),
                    ],
                  ),
                  child: _HistoryCard(item: item, isFirst: index == 0, isCancelling: isCancelling),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmCancel(BuildContext context, PaymentHistoryModel item) {
    final fmt = NumberFormat('#,###', 'en_US');
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: AppTheme.colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20.r, offset: Offset(0, 10.r))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60.r,
                height: 60.r,
                decoration: BoxDecoration(color: AppTheme.colors.red.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(Icons.priority_high_rounded, color: AppTheme.colors.red, size: 30.r),
              ),
              SizedBox(height: 20.h),
              Text(
                "Tasdiqlash",
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: AppTheme.colors.black),
              ),
              SizedBox(height: 12.h),
              Text(
                "Siz haqiqatan ham ushbu to'lovni bekor qilmoqchimisiz?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: AppTheme.colors.gray, fontWeight: FontWeight.w500, height: 1.4),
              ),
              SizedBox(height: 20.h),
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: AppTheme.colors.background,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppTheme.colors.divider.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(color: AppTheme.colors.white, borderRadius: BorderRadius.circular(10.r)),
                      child: Icon(Icons.payments_outlined, color: AppTheme.colors.primary, size: 20.r),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${fmt.format(item.amount).replaceAll(',', ' ')} UZS",
                            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: AppTheme.colors.black),
                          ),
                          Text(
                            item.createdAt,
                            style: TextStyle(fontSize: 11.sp, color: AppTheme.colors.gray),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Text(
                        "Yo'q, qaytish",
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppTheme.colors.gray),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        final ok = await context.read<PaymentHistoryCubit>().cancelPayment(item.id);
                        if (ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text("To'lov muvaffaqiyatli bekor qilindi"),
                              backgroundColor: AppTheme.colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.colors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Text(
                        "Ha, bekor qil",
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── History Card ─────────────────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  final PaymentHistoryModel item;
  final bool isFirst;
  final bool isCancelling;

  const _HistoryCard({required this.item, required this.isFirst, required this.isCancelling});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###', 'en_US');
    final isCancelled = item.isCancelled;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: isCancelled ? Border.all(color: AppTheme.colors.red.withValues(alpha: 0.15), width: 1.2) : null,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(14.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: isCancelled ? AppTheme.colors.red.withValues(alpha: 0.08) : AppTheme.colors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Icon(isCancelled ? Icons.money_off_rounded : Icons.payments_rounded, size: 22.r, color: isCancelled ? AppTheme.colors.red : AppTheme.colors.primary),
                  ),
                ),
                SizedBox(width: 12.w),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Yuqori qator: label (chap) + summa valyuta (o'ng)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "To'lov",
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppTheme.colors.black),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,

                            children: [
                              if (isCancelled) ...[
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                                  decoration: BoxDecoration(color: AppTheme.colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6.r)),
                                  child: Text(
                                    'BEKOR',
                                    style: TextStyle(fontSize: 8.sp, fontWeight: FontWeight.w800, color: AppTheme.colors.red, letterSpacing: 0.5),
                                  ),
                                ),
                                SizedBox(width: 6.w),
                              ],
                              Text(
                                fmt.format(item.amount).replaceAll(',', ' '),
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w900,
                                  color: isCancelled ? AppTheme.colors.red.withValues(alpha: 0.6) : const Color(0xFF10B981),
                                  decoration: isCancelled ? TextDecoration.lineThrough : null,
                                  decorationColor: AppTheme.colors.red,
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                'UZS',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,
                                  color: isCancelled ? AppTheme.colors.red.withValues(alpha: 0.5) : const Color(0xFF10B981).withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Text(
                            item.receivedByName,
                            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppTheme.colors.black.withValues(alpha: 0.75)),
                          ),
                          Expanded(
                            child: Text(
                              item.createdAt,
                              textAlign: TextAlign.end,
                              style: TextStyle(fontSize: 11.sp, color: AppTheme.colors.black, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ─── Footer Section (Note & Cancel Info) ───────────────────────────
          if (item.note.isNotEmpty || (isCancelled && (item.cancelledByName?.isNotEmpty ?? false)))
            Padding(
              padding: EdgeInsets.all(14.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.note.isNotEmpty)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.notes_rounded, size: 14.r, color: AppTheme.colors.gray.withValues(alpha: 0.7)),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            item.note,
                            style: TextStyle(fontSize: 12.sp, color: AppTheme.colors.gray, fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),

                  if (isCancelled && (item.cancelledByName?.isNotEmpty ?? false)) ...[
                    if (item.note.isNotEmpty) SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: AppTheme.colors.red.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: AppTheme.colors.red.withValues(alpha: 0.08)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lock_reset_rounded, size: 14.r, color: AppTheme.colors.red),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Bekor qiluvchi: ${item.cancelledByName}",
                                  style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: AppTheme.colors.red),
                                ),
                                if (item.cancelledAt?.isNotEmpty ?? false)
                                  Text(
                                    item.cancelledAt ?? '',
                                    style: TextStyle(fontSize: 10.sp, color: AppTheme.colors.gray),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

          // Loading Overlay for Cancelling
          if (isCancelling)
            Container(
              height: 2,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(2)),
              child: LinearProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.colors.red), backgroundColor: AppTheme.colors.red.withValues(alpha: 0.1)),
            ),
        ],
      ),
    );
  }
}

// ─── Empty View ───────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(color: AppTheme.colors.primary.withValues(alpha: 0.08), shape: BoxShape.circle),
            child: Icon(Icons.receipt_long_rounded, size: 48.r, color: AppTheme.colors.primary),
          ),
          SizedBox(height: 16.h),
          Text(
            "To'lovlar tarixi yo'q",
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppTheme.colors.black),
          ),
          SizedBox(height: 6.h),
          Text(
            "Hech qanday to'lov amalga oshirilmagan",
            style: TextStyle(fontSize: 13.sp, color: AppTheme.colors.gray),
          ),
        ],
      ),
    );
  }
}

// ─── Error View ───────────────────────────────────────────────────────────────

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
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.colors.primary, foregroundColor: Colors.white),
            child: const Text('Qayta urinish'),
          ),
        ],
      ),
    );
  }
}
