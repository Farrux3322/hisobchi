import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../presentation/assets/asset_index.dart';
import '../bloc/payment_schedule_bloc.dart';
import '../bloc/payment_schedule_event.dart';
import '../bloc/payment_schedule_state.dart';
import '../widgets/common/ps_bottom_buttons.dart';
import '../widgets/common/ps_info_box.dart';
import '../widgets/common/ps_installment_card.dart';
import '../widgets/common/ps_step_indicator.dart';

class Step3FreeSchedulePage extends StatelessWidget {
  const Step3FreeSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentScheduleBloc, PaymentScheduleState>(
      builder: (context, state) {
        final totalFree = state.freeInstallments.fold<double>(
          0.0,
          (sum, item) => sum + item.amount,
        );
        final isValid = (totalFree - state.totalAmount).abs() < 0.01;
        final remaining = state.totalAmount - totalFree;

        return Scaffold(
          backgroundColor: AppTheme.colors.background,
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const PSStepIndicator(currentStep: 2),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '3-bosqich · Erkin grafik',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.colors.black,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          if (isValid)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: AppTheme.colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle_rounded, size: 16.r, color: AppTheme.colors.green),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'To\'g\'ri',
                                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppTheme.colors.green),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 12.h),

                      // Info box with total status
                      PSInfoBox(
                        type: isValid ? InfoBoxType.success : InfoBoxType.warning,
                        title: isValid ? 'To\'liq taqsimlandi' : 'Taqsimot qoldi',
                        description: isValid
                            ? 'Jami ${NumberFormat('#,###').format(totalFree)} so\'m muvaffaqiyatli rejalashtirildi.'
                            : 'Qolgan summa: ${NumberFormat('#,###').format(remaining.abs())} so\'m. Iltimos, barcha summani taqsimlang.',
                      ),
                      SizedBox(height: 12.h),

                      // Installment cards
                      ...state.freeInstallments.asMap().entries.map((entry) {
                        final item = entry.value;

                        return PSInstallmentCard(
                          item: item,
                          currency: state.currency,
                          isEditable: true,
                          onLabelEdit: (label) {
                            context.read<PaymentScheduleBloc>().add(PaymentFreeInstallmentUpdated(item.copyWith(label: label)));
                          },
                          onAmountEdit: (amount) {
                            context.read<PaymentScheduleBloc>().add(PaymentFreeInstallmentUpdated(item.copyWith(amount: amount)));
                          },
                          onDateEdit: (date) {
                            context.read<PaymentScheduleBloc>().add(PaymentFreeInstallmentUpdated(item.copyWith(dueDate: date)));
                          },
                          onDelete: item.isAdvance
                              ? null
                              : () {
                                  _showDeleteConfirm(context, item);
                                },
                        );
                      }),

                      // Add installment button
                      SizedBox(height: 8.h),
                      GestureDetector(
                        onTap: () {
                          context.read<PaymentScheduleBloc>().add(const PaymentFreeInstallmentAdded());
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          decoration: BoxDecoration(
                            color: AppTheme.colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: AppTheme.colors.primary, width: 2.w),
                            boxShadow: [
                              BoxShadow(color: AppTheme.colors.primary.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_circle_outline_rounded, color: AppTheme.colors.primary, size: 24.r),
                              SizedBox(width: 10.w),
                              Text(
                                'Yangi qism qo\'shish',
                                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppTheme.colors.primary),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ),
              PSBottomButtons(
                showBack: true,
                continueLabel: 'Saqlash va SMS',
                continueColor: isValid ? AppTheme.colors.green : AppTheme.colors.disable,
                isLoading: state.status == PaymentScheduleStatus.loading,
                onBack: () {
                  context.read<PaymentScheduleBloc>().add(const PaymentStepBack());
                },
                onContinue: isValid
                    ? () {
                        context.read<PaymentScheduleBloc>().add(const PaymentScheduleSubmitted());
                      }
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirm(BuildContext context, dynamic item) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text('O\'chirish', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        content: Text('${item.label} ni ro\'yxatdan o\'chirishni xohlaysizmi?', style: TextStyle(fontSize: 15.sp)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Bekor qilish', style: TextStyle(color: AppTheme.colors.gray)),
          ),
          TextButton(
            onPressed: () {
              context.read<PaymentScheduleBloc>().add(PaymentFreeInstallmentRemoved(item.id));
              Navigator.pop(dialogContext);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.colors.red),
            child: Text('O\'chirish', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
