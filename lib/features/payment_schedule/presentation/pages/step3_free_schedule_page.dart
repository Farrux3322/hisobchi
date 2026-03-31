import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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
          backgroundColor: const Color(0xFFF5F6F8),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const PSStepIndicator(currentStep: 2),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              '3-bosqich · Erkin grafik',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF202020),
                              ),
                            ),
                          ),
                          if (isValid)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00D856).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.check_circle,
                                    size: 16,
                                    color: Color(0xFF00D856),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'To\'g\'ri',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF00D856),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Info box with total status
                      PSInfoBox(
                        type: isValid ? InfoBoxType.success : InfoBoxType.warning,
                        title: isValid ? 'To\'liq' : 'Qoldi',
                        description: isValid
                            ? '${NumberFormat('#,###').format(totalFree)} / ${NumberFormat('#,###').format(state.totalAmount)} so\'m'
                            : 'Qolgan summa: ${NumberFormat('#,###').format(remaining.abs())} so\'m',
                      ),
                      const SizedBox(height: 24),

                      // Installment cards
                      ...state.freeInstallments.asMap().entries.map((entry) {
                        final item = entry.value;

                        return Dismissible(
                          key: ValueKey(item.id),
                          direction: item.isAdvance
                              ? DismissDirection.none
                              : DismissDirection.endToStart,
                          background: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDE5050),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.centerRight,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                title: const Text('O\'chirish'),
                                content: Text(
                                  '${item.label} ni o\'chirishni xohlaysizmi?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext, false),
                                    child: const Text('Bekor qilish'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext, true),
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFFDE5050),
                                    ),
                                    child: const Text('O\'chirish'),
                                  ),
                                ],
                              ),
                            );
                          },
                          onDismissed: (direction) {
                            context.read<PaymentScheduleBloc>().add(
                                  PaymentFreeInstallmentRemoved(item.id),
                                );
                          },
                          child: PSInstallmentCard(
                            item: item,
                            isEditable: true,
                            onLabelEdit: (label) {
                              context.read<PaymentScheduleBloc>().add(
                                    PaymentFreeInstallmentUpdated(
                                      item.copyWith(label: label),
                                    ),
                                  );
                            },
                            onAmountEdit: (amount) {
                              context.read<PaymentScheduleBloc>().add(
                                    PaymentFreeInstallmentUpdated(
                                      item.copyWith(amount: amount),
                                    ),
                                  );
                            },
                            onDateEdit: (date) {
                              context.read<PaymentScheduleBloc>().add(
                                    PaymentFreeInstallmentUpdated(
                                      item.copyWith(dueDate: date),
                                    ),
                                  );
                            },
                            onDelete: item.isAdvance
                                ? null
                                : () {
                                    context.read<PaymentScheduleBloc>().add(
                                          PaymentFreeInstallmentRemoved(item.id),
                                        );
                                  },
                          ),
                        );
                      }),

                      // Add installment button
                      GestureDetector(
                        onTap: () {
                          context.read<PaymentScheduleBloc>().add(
                                const PaymentFreeInstallmentAdded(),
                              );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF006FE5),
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.add_circle_outline,
                                color: Color(0xFF006FE5),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Qism qo\'shish',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF006FE5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              BlocBuilder<PaymentScheduleBloc, PaymentScheduleState>(
                builder: (context, state) {
                  final totalFree = state.freeInstallments.fold<double>(
                    0.0,
                    (sum, item) => sum + item.amount,
                  );
                  final isValid = (totalFree - state.totalAmount).abs() < 0.01;

                  return PSBottomButtons(
                    showBack: true,
                    continueLabel: 'Saqlash va SMS',
                    continueColor: isValid
                        ? const Color(0xFF00D856)
                        : const Color(0xFFE1E0EE),
                    isLoading: state.status == PaymentScheduleStatus.loading,
                    onBack: () {
                      context.read<PaymentScheduleBloc>().add(
                            const PaymentStepBack(),
                          );
                    },
                    onContinue: isValid
                        ? () {
                            context.read<PaymentScheduleBloc>().add(
                                  const PaymentScheduleSubmitted(),
                                );
                          }
                        : null,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
