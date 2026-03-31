import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../data/models/payment_partner_model.dart';
import '../bloc/payment_schedule_bloc.dart';
import '../bloc/payment_schedule_event.dart';
import '../bloc/payment_schedule_state.dart';
import '../widgets/common/ps_bottom_buttons.dart';
import '../widgets/common/ps_currency_selector.dart';
import '../widgets/common/ps_section_card.dart';
import '../widgets/common/ps_step_indicator.dart';

class Step1BasicInfoPage extends StatelessWidget {
  const Step1BasicInfoPage({super.key});

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
                      const PSStepIndicator(currentStep: 0),
                      const SizedBox(height: 24),
                      const Text(
                        '1-bosqich · Asosiy ma\'lumotlar',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF202020),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Partner selection
                      PSSectionCard(
                        label: 'Hamkor',
                        highlighted: state.selectedPartner != null,
                        onTap: () => _showPartnerBottomSheet(context, state),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.selectedPartner?.name ?? 'Hamkorni tanlang',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: state.selectedPartner != null
                                          ? const Color(0xFF202020)
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                  if (state.selectedPartner?.phone != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      state.selectedPartner!.phone!,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: state.selectedPartner != null
                                  ? const Color(0xFF006FE5)
                                  : const Color(0xFF64748B),
                            ),
                          ],
                        ),
                      ),
                      if (state.validationErrors.containsKey('partner'))
                        Padding(
                          padding: const EdgeInsets.only(left: 4, top: 4),
                          child: Text(
                            state.validationErrors['partner']!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFDE5050),
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Total amount
                      PSSectionCard(
                        label: 'Jami summa',
                        child: TextField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            _ThousandsSeparatorInputFormatter(),
                          ],
                          decoration: InputDecoration(
                            hintText: '1 000 000',
                            hintStyle: const TextStyle(
                              color: Color(0xFF64748B),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFE1E0EE),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFE1E0EE),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF006FE5),
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          onChanged: (value) {
                            final amount = double.tryParse(
                              value.replaceAll(' ', ''),
                            ) ?? 0;
                            context.read<PaymentScheduleBloc>().add(
                              PaymentTotalAmountChanged(amount),
                            );
                          },
                        ),
                      ),
                      if (state.validationErrors.containsKey('amount'))
                        Padding(
                          padding: const EdgeInsets.only(left: 4, top: 4),
                          child: Text(
                            state.validationErrors['amount']!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFDE5050),
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Currency selector
                      PSSectionCard(
                        label: 'Valyuta',
                        child: PSCurrencySelector(
                          selectedCurrency: state.currency,
                          onChanged: (currency) {
                            context.read<PaymentScheduleBloc>().add(
                              PaymentCurrencyChanged(currency),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Note
                      PSSectionCard(
                        label: 'Izoh (ixtiyoriy)',
                        child: TextField(
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Qurilish materiallari...',
                            hintStyle: const TextStyle(
                              color: Color(0xFF64748B),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFE1E0EE),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFE1E0EE),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF006FE5),
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          onChanged: (value) {
                            context.read<PaymentScheduleBloc>().add(
                              PaymentNoteChanged(value),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              PSBottomButtons(
                showBack: false,
                onContinue: () {
                  context.read<PaymentScheduleBloc>().add(
                    const PaymentStepChanged(1),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPartnerBottomSheet(
    BuildContext context,
    PaymentScheduleState state,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE1E0EE),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Hamkorni tanlang',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF202020),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: PaymentPartnerModel.mockList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, index) {
                  final partner = PaymentPartnerModel.mockList[index];
                  final isSelected = state.selectedPartner?.id == partner.id;

                  return GestureDetector(
                    onTap: () {
                      context.read<PaymentScheduleBloc>().add(
                        PaymentPartnerSelected(partner),
                      );
                      Navigator.pop(bottomSheetContext);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF006FE5).withOpacity(0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF006FE5)
                              : const Color(0xFFE1E0EE),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF006FE5).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                partner.name[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF006FE5),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  partner.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF202020),
                                  ),
                                ),
                                if (partner.phone != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    partner.phone!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFF006FE5),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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
