import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../presentation/assets/asset_index.dart';
import '../bloc/payment_schedule_bloc.dart';
import '../bloc/payment_schedule_event.dart';
import '../bloc/payment_schedule_state.dart';
import '../widgets/common/ps_advance_item_card.dart';
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
        final currSym = state.currency.value == 'UZS' ? "so'm" : '\$';
        final fmt = NumberFormat('#,###');

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
                        "3-bosqich · Teng bo'lib to'lash",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.colors.black,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // ── Boshlang'ich to'lov toggle ──────────────────────
                      PSAdvanceToggleCard(
                        isEnabled: state.isAdvanceEnabled,
                        onToggled: (value) {
                          context.read<PaymentScheduleBloc>().add(PaymentAdvanceToggled(value));
                        },
                      ),

                      // ── Boshlang'ich to'lov item card ───────────────────
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: state.isAdvanceEnabled
                            ? Column(
                                children: [
                                  SizedBox(height: 10.h),
                                  PSAdvanceItemCard(
                                    amount: state.advanceAmount,
                                    dueDate: DateFormat('yyyy-MM-dd').format(state.startDate),
                                    currSym: currSym,
                                    onAmountChanged: (amount) {
                                      context.read<PaymentScheduleBloc>().add(PaymentAdvanceAmountChanged(amount));
                                    },
                                    // Equal da avans sanasi = birinchi to'lov sanasi bilan bir xil,
                                    // shuning uchun sana tanlash startDate ni o'zgartiradi
                                    onDateTap: () => _showDatePicker(context, state),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),

                      SizedBox(height: 16.h),

                      // ── Birinchi qism sanasi + qismlar soni ────────────
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: PSSectionCard(
                                label: state.isAdvanceEnabled
                                    ? "Birinchi qism sanasi"
                                    : "Birinchi to'lov sanasi",
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
                                        Icon(Icons.calendar_today_rounded, size: 15.r, color: AppTheme.colors.primary),
                                        SizedBox(width: 10.w),
                                        Expanded(
                                          child: Text(
                                            DateFormat('dd.MM.yyyy').format(state.startDate),
                                            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppTheme.colors.black),
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
                                      icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.colors.primary, size: 22.r),
                                      items: List.generate(
                                        11,
                                        (i) => DropdownMenuItem(
                                          value: i + 2,
                                          child: Text(
                                            '${i + 2} ta',
                                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppTheme.colors.black),
                                          ),
                                        ),
                                      ),
                                      onChanged: (v) {
                                        if (v != null) {
                                          context.read<PaymentScheduleBloc>().add(PaymentInstallmentCountChanged(v));
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
                      SizedBox(height: 20.h),

                      // ── Hisob-kitob info ────────────────────────────────
                      if (state.calculatedInstallments.isNotEmpty) ...[
                        PSInfoBox(
                          type: InfoBoxType.info,
                          title: 'Taqsimot hisob-kitobi',
                          description: _calcDescription(state, fmt, currSym),
                        ),
                        SizedBox(height: 20.h),

                        // ── Jadval ─────────────────────────────────────────
                        Row(
                          children: [
                            Text(
                              "To'lov jadvali",
                              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: AppTheme.colors.black),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: AppTheme.colors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                '${state.calculatedInstallments.length} ta',
                                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppTheme.colors.primary),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        ...state.calculatedInstallments.map(
                          (item) => PSInstallmentCard(item: item, currency: state.currency, isEditable: false),
                        ),
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
                onBack: () => context.read<PaymentScheduleBloc>().add(const PaymentStepBack()),
                onContinue: () => context.read<PaymentScheduleBloc>().add(const PaymentScheduleSubmitted()),
              ),
            ],
          ),
        );
      },
    );
  }

  String _calcDescription(PaymentScheduleState state, NumberFormat fmt, String currSym) {
    if (state.calculatedInstallments.isEmpty) return '';
    final regular = state.calculatedInstallments.where((i) => !i.isAdvance).toList();
    if (regular.isEmpty) return '';

    final total = state.totalAmount;
    final advance = state.isAdvanceEnabled ? state.advanceAmount : 0.0;
    final remaining = total - advance;
    final count = regular.length;
    final per = regular.first.amount;

    final buf = StringBuffer();
    buf.write("Jami: ${fmt.format(total).replaceAll(',', ' ')} $currSym");
    if (state.isAdvanceEnabled && advance > 0) {
      buf.write("\nBoshlang'ich to'lov: ${fmt.format(advance).replaceAll(',', ' ')} $currSym");
      buf.write("\nQolgan: ${fmt.format(remaining).replaceAll(',', ' ')} $currSym ÷ $count qism");
    } else {
      buf.write("\n${fmt.format(total).replaceAll(',', ' ')} ÷ $count qism");
    }
    buf.write(" = ${fmt.format(per).replaceAll(',', ' ')} $currSym/qism");
    return buf.toString();
  }

  Future<void> _showDatePicker(BuildContext context, PaymentScheduleState state) async {
    final date = await showDatePicker(
      context: context,
      initialDate: state.startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      builder: (ctx, child) => Theme(
        data: AppTheme.data.copyWith(
          colorScheme: ColorScheme.light(primary: AppTheme.colors.primary),
        ),
        child: child!,
      ),
    );
    if (date != null && context.mounted) {
      context.read<PaymentScheduleBloc>().add(PaymentStartDateChanged(date));
    }
  }
}
