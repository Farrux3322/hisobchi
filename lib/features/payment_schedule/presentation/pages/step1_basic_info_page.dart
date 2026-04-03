import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../presentation/assets/asset_index.dart';
import '../../data/models/enums.dart';
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
          backgroundColor: AppTheme.colors.background,
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const PSStepIndicator(currentStep: 0),
                       SizedBox(height: 6.h),
                      Text(
                        '1-bosqich • Asosiy ma\'lumotlar',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.colors.black,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Partner selection chip-style
                      PSSectionCard(
                        highlighted: state.selectedPartner != null,
                        onTap: state.isPartnerLocked ? null : () => _showPartnerBottomSheet(context, state),
                        child: Row(
                          children: [
                            Container(
                              width: 44.r,
                              height: 44.r,
                              decoration: BoxDecoration(
                                color: (state.selectedPartner != null ? AppTheme.colors.primary : AppTheme.colors.divider).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Center(
                                child: state.selectedPartner != null
                                    ? Text(
                                        state.selectedPartner!.name[0].toUpperCase(),
                                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: AppTheme.colors.primaryText),
                                      )
                                    : Icon(Icons.person_search_rounded, color: AppTheme.colors.iconColor, size: 22.r),
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Mijoz',
                                    style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: AppTheme.colors.gray, letterSpacing: 0.5),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    state.selectedPartner?.name ?? 'Mijoz tanlash',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w700,
                                      color: state.selectedPartner != null ? AppTheme.colors.black : AppTheme.colors.gray,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            if (state.isPartnerLocked)
                              Icon(Icons.lock_rounded, size: 18.r, color: AppTheme.colors.gray)
                            else
                              Icon(
                                Icons.unfold_more_rounded,
                                size: 20.r,
                                color: state.selectedPartner != null ? AppTheme.colors.primary : AppTheme.colors.divider,
                              ),
                          ],
                        ),
                      ),
                      if (state.validationErrors.containsKey('partner'))
                        Padding(
                          padding: EdgeInsets.only(left: 4.w, top: 6.h),
                          child: Text(
                            state.validationErrors['partner']!,
                            style: TextStyle(fontSize: 12.sp, color: AppTheme.colors.red, fontWeight: FontWeight.w600),
                          ),
                        ),
                      SizedBox(height: 12.h),

                      // Financial Bento Card (Amount + Currency)
                      PSSectionCard(
                        padding: EdgeInsets.zero,
                        highlighted: true,
                        highlightColor: AppTheme.colors.primary.withValues(alpha: 0.1),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(16.r, 16.r, 16.r, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Miqdor va valyuta',
                                    style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: AppTheme.colors.gray, letterSpacing: 0.5),
                                  ),
                                  SizedBox(height: 4.h),
                                  Row(
                                    children: [
                                      Icon(Icons.account_balance_wallet_rounded, size: 20.r, color: AppTheme.colors.primary),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: TextField(
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.digitsOnly,
                                            _ThousandsSeparatorInputFormatter(),
                                          ],
                                          cursorColor: AppTheme.colors.primary,
                                          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: AppTheme.colors.black),
                                          decoration: InputDecoration(
                                            hintText: '0',
                                            hintStyle: TextStyle(color: AppTheme.colors.divider),
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
                                            context.read<PaymentScheduleBloc>().add(PaymentTotalAmountChanged(amount));
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Divider(height: 32.h, thickness: 1.h, color: AppTheme.colors.divider.withValues(alpha: 0.5)),
                            Padding(
                              padding: EdgeInsets.fromLTRB(16.r, 0, 16.r, 16.r),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Valyuta turi',
                                        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: AppTheme.colors.gray, letterSpacing: 0.5),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        state.currency == PaymentCurrency.uzs ? 'O\'zbek so\'mi' : 'AQSH Dollari',
                                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppTheme.colors.black),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  PSCurrencySelector(
                                    selectedCurrency: state.currency,
                                    onChanged: (currency) {
                                      context.read<PaymentScheduleBloc>().add(PaymentCurrencyChanged(currency));
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (state.validationErrors.containsKey('amount'))
                        Padding(
                          padding: EdgeInsets.only(left: 4.w, top: 6.h),
                          child: Text(
                            state.validationErrors['amount']!,
                            style: TextStyle(fontSize: 12.sp, color: AppTheme.colors.red, fontWeight: FontWeight.w600),
                          ),
                        ),
                      SizedBox(height: 12.h),

                      // Note field
                      PSSectionCard(
                        label: 'Izoh (ixtiyoriy)',
                        child: TextField(
                          maxLines: 3,
                          cursorColor: AppTheme.colors.primary,
                          style: TextStyle(fontSize: 15.sp, color: AppTheme.colors.black, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            hintText: 'Tafsilotlarni yozishingiz mumkun...',
                            hintStyle: TextStyle(color: AppTheme.colors.gray, fontSize: 13.sp),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (value) {
                            context.read<PaymentScheduleBloc>().add(PaymentNoteChanged(value));
                          },
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
              PSBottomButtons(
                showBack: false,
                onContinue: () {
                  context.read<PaymentScheduleBloc>().add(const PaymentStepChanged(1));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPartnerBottomSheet(BuildContext context, PaymentScheduleState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => Container(
        height: 0.85.sh,
        decoration: BoxDecoration(
          color: AppTheme.colors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: Column(
          children: [
            SizedBox(height: 12.h),
            Container(
              width: 48.w,
              height: 5.h,
              decoration: BoxDecoration(color: AppTheme.colors.divider, borderRadius: BorderRadius.circular(10.r)),
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                'Hamkorni tanlang',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: AppTheme.colors.black),
              ),
            ),
            SizedBox(height: 16.h),
            Divider(height: 1.h, thickness: 1.h, color: AppTheme.colors.divider),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.all(20.r),
                itemCount: PaymentPartnerModel.mockList.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (_, index) {
                  final partner = PaymentPartnerModel.mockList[index];
                  final isSelected = state.selectedPartner?.id == partner.id;

                  return GestureDetector(
                    onTap: () {
                      context.read<PaymentScheduleBloc>().add(PaymentPartnerSelected(partner));
                      Navigator.pop(bottomSheetContext);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: AppTheme.colors.white,
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(
                          color: isSelected ? AppTheme.colors.primary : AppTheme.colors.divider,
                          width: isSelected ? 2.w : 1.w,
                        ),
                        boxShadow: isSelected
                            ? [BoxShadow(color: AppTheme.colors.primary.withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 5))]
                            : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52.r,
                            height: 52.r,
                            decoration: BoxDecoration(
                              color: (isSelected ? AppTheme.colors.primaryText : AppTheme.colors.divider).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Center(
                              child: Text(
                                partner.name[0].toUpperCase(),
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected ? AppTheme.colors.primaryText : AppTheme.colors.gray,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  partner.name,
                                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppTheme.colors.black),
                                ),
                                if (partner.phone != null) ...[
                                  SizedBox(height: 2.h),
                                  Text(
                                    partner.phone!,
                                    style: TextStyle(fontSize: 13.sp, color: AppTheme.colors.gray, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (isSelected) Icon(Icons.check_circle_rounded, color: AppTheme.colors.primary, size: 24.r),
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
