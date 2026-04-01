import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../presentation/assets/asset_index.dart';
import '../../data/models/enums.dart';
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
                      Text(
                        '3-bosqich · Teng bo\'lib to\'lash',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.colors.black,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Advance toggle
                      PSAdvanceToggle(
                        isEnabled: state.isAdvanceEnabled,
                        onToggled: (value) {
                          context.read<PaymentScheduleBloc>().add(PaymentAdvanceToggled(value));
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Advance amount input (shown when enabled)
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: state.isAdvanceEnabled
                            ? Column(
                                children: [
                                  PSSectionCard(
                                    label: 'Avans miqdori',
                                    highlighted: true,
                                    highlightColor: const Color(0xFFF97316),
                                    child: TextField(
                                      keyboardType: TextInputType.number,
                                      cursorColor: const Color(0xFFF97316),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        _ThousandsSeparatorInputFormatter(),
                                      ],
                                      style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700, color: AppTheme.colors.black),
                                      decoration: InputDecoration(
                                        hintText: '500 000',
                                        suffixText: state.currency == PaymentCurrency.uzs ? 'so\'m' : '\$',
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                        filled: true,
                                        fillColor: Colors.white,

                                      ),
                                      onChanged: (value) {
                                        final amount = double.tryParse(value.replaceAll(' ', '')) ?? 0;
                                        context.read<PaymentScheduleBloc>().add(PaymentAdvanceAmountChanged(amount));
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 24.h),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),

                      // Date and installment count grid
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: PSSectionCard(
                                label: 'Birinchi to\'lov sanasi',
                                child: GestureDetector(
                                  onTap: () => _showDatePicker(context, state),
                                  child: Container(
                                    height: 48.h,
                                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                                    decoration: BoxDecoration(
                                      color: AppTheme.colors.divider.withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.calendar_today_rounded, size: 20.r, color: AppTheme.colors.primary),
                                        SizedBox(width: 12.w),
                                        Expanded(
                                          child: Text(
                                            DateFormat('dd.MM.yyyy').format(state.startDate),
                                            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppTheme.colors.black),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: PSSectionCard(
                                label: state.isAdvanceEnabled ? 'Qolgan qismlar' : 'Qismlar soni',
                                child: Container(
                                  height: 48.h,
                                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                                  decoration: BoxDecoration(
                                    color: AppTheme.colors.divider.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<int>(
                                      value: state.installmentCount,
                                      isExpanded: true,
                                      icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.colors.primary, size: 24.r),
                                      items: List.generate(
                                        11,
                                        (index) => DropdownMenuItem(
                                          value: index + 2,
                                          child: Text(
                                            '${index + 2}',
                                            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppTheme.colors.black),
                                          ),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        if (value != null) {
                                          context.read<PaymentScheduleBloc>().add(PaymentInstallmentCountChanged(value));
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // Info box with calculation
                      if (state.calculatedInstallments.isNotEmpty) ...[
                        PSInfoBox(
                          type: InfoBoxType.info,
                          title: 'Taqsimot hisob-kitobi',
                          description: _buildCalculationDescription(state),
                        ),
                        SizedBox(height: 24.h),
                      ],

                      // Calculated installments
                      if (state.calculatedInstallments.isNotEmpty) ...[
                        Row(
                          children: [
                            Text(
                              'To\'lov jadvali',
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: AppTheme.colors.black, letterSpacing: -0.2),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(color: AppTheme.colors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6.r)),
                              child: Text(
                                '${state.calculatedInstallments.length} ta',
                                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppTheme.colors.primary),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        ...state.calculatedInstallments.map((item) => PSInstallmentCard(item: item, currency: state.currency, isEditable: false)),
                      ],
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
              PSBottomButtons(
                showBack: true,
                continueLabel: 'Saqlash va SMS',
                continueColor: AppTheme.colors.green,
                isLoading: state.status == PaymentScheduleStatus.loading,
                onBack: () {
                  context.read<PaymentScheduleBloc>().add(const PaymentStepBack());
                },
                onContinue: () {
                  context.read<PaymentScheduleBloc>().add(const PaymentScheduleSubmitted());
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
    if (state.calculatedInstallments.isEmpty) return '';

    final regularInstallments = state.calculatedInstallments.where((item) => !item.isAdvance).toList();
    if (regularInstallments.isEmpty) return '';

    final totalAmount = state.totalAmount;
    final advanceAmount = state.isAdvanceEnabled ? state.advanceAmount : 0;
    final remaining = totalAmount - advanceAmount;
    final count = regularInstallments.length;
    final perInstallment = regularInstallments.first.amount;

    return 'Jami to\'lov: ${formatter.format(totalAmount)} so\'m\n'
        'Qismlarga bo\'lingan miqdor: ${formatter.format(remaining)} ÷ $count qism = ${formatter.format(perInstallment)} so\'mdan';
  }

  void _showDatePicker(BuildContext context, PaymentScheduleState state) async {
    final date = await showDatePicker(
      context: context,
      initialDate: state.startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: AppTheme.data.copyWith(colorScheme: ColorScheme.light(primary: AppTheme.colors.primary)),
          child: child!,
        );
      },
    );

    if (date != null && context.mounted) {
      context.read<PaymentScheduleBloc>().add(PaymentStartDateChanged(date));
    }
  }
}

class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,###', 'en_US');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final number = int.tryParse(newValue.text.replaceAll(RegExp(r'[^0-9]'), ''));
    if (number == null) return oldValue;
    final formatted = _formatter.format(number).replaceAll(',', ' ');
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
