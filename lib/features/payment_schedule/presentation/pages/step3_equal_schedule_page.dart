import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/payment_schedule_bloc.dart';
import '../bloc/payment_schedule_event.dart';
import '../bloc/payment_schedule_state.dart';
import '../widgets/common/ps_advance_toggle.dart';
import '../widgets/common/ps_bottom_buttons.dart';
import '../widgets/common/ps_info_box.dart';
import '../widgets/common/ps_installment_card.dart';
import '../widgets/common/ps_section_card.dart';
import '../widgets/common/ps_step_indicator.dart';

class Step3EqualSchedulePage extends StatelessWidget {
  const Step3EqualSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentScheduleBloc, PaymentScheduleState>(
      builder: (context, state) {
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
                      const Text(
                        '3-bosqich · Teng bo\'lib to\'lash',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF202020),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Advance toggle
                      PSAdvanceToggle(
                        isEnabled: state.isAdvanceEnabled,
                        onToggled: (value) {
                          context.read<PaymentScheduleBloc>().add(
                                PaymentAdvanceToggled(value),
                              );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Advance amount input (shown when enabled)
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: state.isAdvanceEnabled
                            ? Column(
                                children: [
                                  PSSectionCard(
                                    label: 'Avans miqdori',
                                    highlighted: true,
                                    highlightColor: const Color(0xFFFF9500),
                                    child: TextField(
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        _ThousandsSeparatorInputFormatter(),
                                      ],
                                      decoration: InputDecoration(
                                        hintText: '500 000',
                                        hintStyle: const TextStyle(
                                          color: Color(0xFF64748B),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFFF9500),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFFF9500),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFFF9500),
                                            width: 2,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.all(16),
                                      ),
                                      onChanged: (value) {
                                        final amount = double.tryParse(
                                              value.replaceAll(' ', ''),
                                            ) ??
                                            0;
                                        context.read<PaymentScheduleBloc>().add(
                                              PaymentAdvanceAmountChanged(amount),
                                            );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),

                      // Date and installment count grid
                      Row(
                        children: [
                          Expanded(
                            child: PSSectionCard(
                              label: 'Boshlanish sanasi',
                              child: GestureDetector(
                                onTap: () => _showDatePicker(context, state),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        size: 20,
                                        color: Color(0xFF006FE5),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          DateFormat('dd.MM.yyyy')
                                              .format(state.startDate),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF202020),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: PSSectionCard(
                              label: state.isAdvanceEnabled
                                  ? 'Qolgan qismlar soni'
                                  : 'Qismlar soni',
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButton<int>(
                                  value: state.installmentCount,
                                  isExpanded: true,
                                  underline: const SizedBox.shrink(),
                                  icon: const Icon(
                                    Icons.arrow_drop_down,
                                    color: Color(0xFF006FE5),
                                  ),
                                  items: List.generate(
                                    11,
                                    (index) => DropdownMenuItem(
                                      value: index + 2,
                                      child: Text(
                                        '${index + 2}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF202020),
                                        ),
                                      ),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    if (value != null) {
                                      context.read<PaymentScheduleBloc>().add(
                                            PaymentInstallmentCountChanged(value),
                                          );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Info box with calculation
                      if (state.calculatedInstallments.isNotEmpty) ...[
                        PSInfoBox(
                          type: InfoBoxType.info,
                          title: 'Tizim hisobladi',
                          description: _buildCalculationDescription(state),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Calculated installments
                      if (state.calculatedInstallments.isNotEmpty) ...[
                        const Text(
                          'To\'lov jadvali',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF202020),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...state.calculatedInstallments.map(
                          (item) => PSInstallmentCard(
                            item: item,
                            isEditable: false,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              BlocBuilder<PaymentScheduleBloc, PaymentScheduleState>(
                builder: (context, state) {
                  return PSBottomButtons(
                    showBack: true,
                    continueLabel: 'Saqlash va SMS',
                    continueColor: const Color(0xFF00D856),
                    isLoading: state.status == PaymentScheduleStatus.loading,
                    onBack: () {
                      context.read<PaymentScheduleBloc>().add(
                            const PaymentStepBack(),
                          );
                    },
                    onContinue: () {
                      context.read<PaymentScheduleBloc>().add(
                            const PaymentScheduleSubmitted(),
                          );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _buildCalculationDescription(PaymentScheduleState state) {
    final formatter = NumberFormat('#,###');
    final dateFormat = DateFormat('dd.MM');

    if (state.calculatedInstallments.isEmpty) {
      return '';
    }

    final regularInstallments =
        state.calculatedInstallments.where((item) => !item.isAdvance).toList();

    if (regularInstallments.isEmpty) {
      return '';
    }

    final totalAmount = state.totalAmount;
    final advanceAmount = state.isAdvanceEnabled ? state.advanceAmount : 0;
    final remaining = totalAmount - advanceAmount;
    final count = regularInstallments.length;
    final perInstallment = regularInstallments.first.amount;

    final dates = regularInstallments
        .map((item) => dateFormat.format(item.dueDate))
        .join(' · ');

    return '${formatter.format(remaining)} ÷ $count = ${formatter.format(perInstallment)} so\'m\n$dates';
  }

  void _showDatePicker(BuildContext context, PaymentScheduleState state) async {
    final date = await showDatePicker(
      context: context,
      initialDate: state.startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      locale: const Locale('uz', 'UZ'),
    );

    if (date != null && context.mounted) {
      context.read<PaymentScheduleBloc>().add(
            PaymentStartDateChanged(date),
          );
    }
  }
}

class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,###', 'en_US');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final number = int.tryParse(newValue.text.replaceAll(RegExp(r'[^0-9]'), ''));
    if (number == null) {
      return oldValue;
    }

    final formatted = _formatter.format(number).replaceAll(',', ' ');
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
