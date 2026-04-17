import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../presentation/assets/asset_index.dart';
import '../../../../presentation/components/defocus.dart';
import '../../data/models/enums.dart';
import '../../data/models/installment_item_model.dart';
import '../bloc/payment_schedule_bloc.dart';
import '../bloc/payment_schedule_event.dart';
import '../bloc/payment_schedule_state.dart';
import '../widgets/common/ps_advance_item_card.dart';
import '../widgets/common/ps_bottom_buttons.dart';
import '../widgets/common/ps_info_box.dart';
import '../widgets/common/ps_step_indicator.dart';

class Step3FreeSchedulePage extends StatelessWidget {
  const Step3FreeSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentScheduleBloc, PaymentScheduleState>(
      builder: (context, state) {
        final totalFree = state.freeInstallments.fold<double>(0.0, (s, i) => s + i.amount);
        final isValid = state.freeInstallments.length >= 2 && (totalFree - state.totalAmount).abs() < 0.01;
        final remaining = state.totalAmount - totalFree;
        final isOverflow = totalFree > state.totalAmount + 0.01;
        final fmt = NumberFormat('#,###', 'en_US');
        final currSym = state.currency == PaymentCurrency.uzs ? "so'm" : '\$';

        final hasAdvance = state.freeInstallments.any((i) => i.isAdvance);
        final advanceItem = hasAdvance ? state.freeInstallments.first : null;
        final regularItems = state.freeInstallments.where((i) => !i.isAdvance).toList();

        return DeFocus(
          child: Scaffold(
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

                        // ── Header ──────────────────────────────────────────
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
                            if (isValid) _ValidBadge(),
                          ],
                        ),
                        SizedBox(height: 16.h),

                        // ── Boshlang'ich to'lov toggle ──────────────────────
                        PSAdvanceToggleCard(
                          isEnabled: hasAdvance,
                          onToggled: (value) {
                            context.read<PaymentScheduleBloc>().add(PaymentAdvanceToggled(value));
                          },
                        ),

                        // ── Avans item card ─────────────────────────────────
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: hasAdvance && advanceItem != null
                              ? Column(
                                  children: [
                                    SizedBox(height: 10.h),
                                    PSAdvanceItemCard(
                                      amount: advanceItem.amount,
                                      dueDate: advanceItem.dueDate,
                                      currSym: currSym,
                                      note: advanceItem.note,
                                      onAmountChanged: (amount) {
                                        context.read<PaymentScheduleBloc>().add(
                                              PaymentFreeInstallmentUpdated(advanceItem.copyWith(amount: amount)),
                                            );
                                      },
                                      onNoteChanged: (note) {
                                        context.read<PaymentScheduleBloc>().add(
                                              PaymentFreeInstallmentUpdated(
                                                advanceItem.copyWith(note: note.isEmpty ? null : note),
                                              ),
                                            );
                                      },
                                      onDateTap: () => _showDatePickerForItem(context, advanceItem),
                                    ),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),

                        SizedBox(height: 10.h),

                        // ── Info box ────────────────────────────────────────
                        PSInfoBox(
                          type: isValid
                              ? InfoBoxType.success
                              : isOverflow
                                  ? InfoBoxType.error
                                  : InfoBoxType.warning,
                          title: isValid
                              ? "To'liq taqsimlandi"
                              : isOverflow
                                  ? 'Summa oshib ketdi'
                                  : 'Taqsimot qoldi',
                          description: isValid
                              ? "Jami ${fmt.format(totalFree).replaceAll(',', ' ')} $currSym muvaffaqiyatli rejalashtirildi."
                              : isOverflow
                                  ? "${fmt.format(remaining.abs()).replaceAll(',', ' ')} $currSym ga kamaytiring."
                                  : "Qolgan: ${fmt.format(remaining.abs()).replaceAll(',', ' ')} $currSym. Barcha summani taqsimlang.",
                        ),
                        SizedBox(height: 12.h),

                        // ── Oddiy qismlar ───────────────────────────────────
                        ...regularItems.map(
                          (item) => _RegularItemCard(
                            item: item,
                            currSym: currSym,
                            canDelete: regularItems.length > 1,
                            onAmountChanged: (amount) {
                              context.read<PaymentScheduleBloc>().add(
                                    PaymentFreeInstallmentUpdated(item.copyWith(amount: amount)),
                                  );
                            },
                            onDateChanged: (date) {
                              context.read<PaymentScheduleBloc>().add(
                                    PaymentFreeInstallmentUpdated(
                                      item.copyWith(dueDate: DateFormat('yyyy-MM-dd').format(date)),
                                    ),
                                  );
                            },
                            onNoteChanged: (note) {
                              context.read<PaymentScheduleBloc>().add(
                                    PaymentFreeInstallmentUpdated(
                                      item.copyWith(note: note.isEmpty ? null : note),
                                    ),
                                  );
                            },
                            onDelete: () => _confirmDelete(context, item),
                          ),
                        ),

                        // ── Yangi qism qo'shish ─────────────────────────────
                        SizedBox(height: 8.h),
                        GestureDetector(
                          onTap: () => context.read<PaymentScheduleBloc>().add(const PaymentFreeInstallmentAdded()),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            decoration: BoxDecoration(
                              color: AppTheme.colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(color: AppTheme.colors.primary, width: 1.5.w),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.colors.primary.withValues(alpha: 0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_circle_outline_rounded, color: AppTheme.colors.primary, size: 22.r),
                                SizedBox(width: 10.w),
                                Text(
                                  "Yangi qism qo'shish",
                                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppTheme.colors.primary),
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
                  continueLabel: 'Saqlash',
                  continueColor: isValid ? AppTheme.colors.green : AppTheme.colors.disable,
                  isLoading: state.status == PaymentScheduleStatus.loading,
                  onBack: () => context.read<PaymentScheduleBloc>().add(const PaymentStepBack()),
                  onContinue: isValid
                      ? () => context.read<PaymentScheduleBloc>().add(const PaymentScheduleSubmitted())
                      : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showDatePickerForItem(BuildContext context, InstallmentItemModel item) async {
    final parsed = item.dueDate.isNotEmpty ? DateTime.tryParse(item.dueDate) : null;
    final initial = (parsed != null && !parsed.isBefore(DateTime.now()))
        ? parsed
        : DateTime.now().add(const Duration(days: 1));

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      builder: (ctx, child) => Theme(
        data: AppTheme.data.copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFFF97316)),
        ),
        child: child!,
      ),
    );
    if (date != null && context.mounted) {
      context.read<PaymentScheduleBloc>().add(
            PaymentFreeInstallmentUpdated(
              item.copyWith(dueDate: DateFormat('yyyy-MM-dd').format(date)),
            ),
          );
    }
  }

  void _confirmDelete(BuildContext context, InstallmentItemModel item) {
    final bloc = context.read<PaymentScheduleBloc>();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text("O'chirish", style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold)),
        content: Text("${item.label} ni o'chirmoqchimisiz?", style: TextStyle(fontSize: 14.sp)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Bekor qilish', style: TextStyle(color: AppTheme.colors.gray)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              bloc.add(PaymentFreeInstallmentRemoved(item.id));
            },
            child: Text(
              "O'chirish",
              style: TextStyle(color: AppTheme.colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Regular item card (faqat oddiy qismlar uchun) ────────────────────────────

class _RegularItemCard extends StatelessWidget {
  final InstallmentItemModel item;
  final String currSym;
  final bool canDelete;
  final ValueChanged<double> onAmountChanged;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<String> onNoteChanged;
  final VoidCallback onDelete;

  const _RegularItemCard({
    required this.item,
    required this.currSym,
    required this.canDelete,
    required this.onAmountChanged,
    required this.onDateChanged,
    required this.onNoteChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateText = item.dueDate.isNotEmpty
        ? DateFormat('dd.MM.yyyy').format(DateTime.tryParse(item.dueDate) ?? DateTime.now())
        : 'Tanlang';

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.colors.divider),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppTheme.colors.black),
                ),
              ),
              if (canDelete)
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: BoxDecoration(
                      color: AppTheme.colors.red.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close_rounded, size: 16.r, color: AppTheme.colors.red),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),

          // ── Summa + Sana ─────────────────────────────────────────────────
          Row(
            children: [
              // Summa — tap → dialog
              Expanded(
                child: _FieldTap(
                  label: 'Summa',
                  onTap: () => _showAmountDialog(context),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.amount > 0
                              ? NumberFormat('#,###', 'en_US').format(item.amount).replaceAll(',', ' ')
                              : '0',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: item.amount > 0 ? AppTheme.colors.black : AppTheme.colors.gray,
                          ),
                        ),
                      ),
                      Icon(Icons.edit_rounded, size: 13.r, color: AppTheme.colors.primary),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              // Sana — tap → datePicker
              Expanded(
                child: _FieldTap(
                  label: "To'lov sanasi",
                  onTap: () => _pickDate(context),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          dateText,
                          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppTheme.colors.black),
                        ),
                      ),
                      Icon(Icons.calendar_today_rounded, size: 13.r, color: AppTheme.colors.primary),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // ── Izoh ────────────────────────────────────────────────────────
          _NoteRow(
            note: item.note,
            onTap: () => _showNoteDialog(context),
          ),
        ],
      ),
    );
  }

  void _showNoteDialog(BuildContext context) {
    final ctrl = TextEditingController(text: item.note ?? '');
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text('${item.label} izohi', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.multiline,
          maxLines: 3,
          maxLength: 200,
          cursorColor: AppTheme.colors.primary,
          autofocus: true,
          style: TextStyle(fontSize: 14.sp, color: AppTheme.colors.black),
          decoration: InputDecoration(
            counter: SizedBox(),
            hintText: 'Izoh kiriting...',
            hintStyle: TextStyle(color: AppTheme.colors.gray),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppTheme.colors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppTheme.colors.primary, width: 2),
            ),
            contentPadding: EdgeInsets.all(12.r),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Bekor', style: TextStyle(color: AppTheme.colors.gray, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () {
              final value = ctrl.text.trim();
              Navigator.pop(dialogCtx);
              onNoteChanged(value);
            },
            child: Text(
              'Saqlash',
              style: TextStyle(color: AppTheme.colors.primary, fontWeight: FontWeight.w800, fontSize: 15.sp),
            ),
          ),
        ],
      ),
    );
  }

  void _showAmountDialog(BuildContext context) {
    final ctrl = TextEditingController(
      text: item.amount > 0
          ? NumberFormat('#,###', 'en_US').format(item.amount.toInt()).replaceAll(',', ' ')
          : '',
    );

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          "${item.label} summasi",
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800),
        ),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          cursorColor: AppTheme.colors.primary,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _ThousandsSeparatorFormatter(),
          ],
          autofocus: true,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppTheme.colors.black),
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: TextStyle(color: AppTheme.colors.divider),
            suffixText: currSym,
            suffixStyle: TextStyle(fontSize: 14.sp, color: AppTheme.colors.gray, fontWeight: FontWeight.w600),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.colors.divider),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.colors.primary, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Bekor', style: TextStyle(color: AppTheme.colors.gray, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(ctrl.text.replaceAll(' ', '')) ?? 0;
              Navigator.pop(dialogCtx);
              onAmountChanged(amount);
            },
            child: Text(
              'Saqlash',
              style: TextStyle(color: AppTheme.colors.primary, fontWeight: FontWeight.w800, fontSize: 15.sp),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final parsed = item.dueDate.isNotEmpty ? DateTime.tryParse(item.dueDate) : null;
    final initial = (parsed != null && !parsed.isBefore(DateTime.now()))
        ? parsed
        : DateTime.now().add(const Duration(days: 1));

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      builder: (ctx, child) => Theme(
        data: AppTheme.data.copyWith(
          colorScheme: ColorScheme.light(primary: AppTheme.colors.primary),
        ),
        child: child!,
      ),
    );
    if (date != null) onDateChanged(date);
  }
}

// ─── Field Tap ────────────────────────────────────────────────────────────────

class _FieldTap extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Widget child;

  const _FieldTap({required this.label, required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10.sp, color: AppTheme.colors.gray, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 6.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppTheme.colors.divider.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppTheme.colors.divider.withValues(alpha: 0.35)),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ─── Note Row ─────────────────────────────────────────────────────────────────

class _NoteRow extends StatelessWidget {
  final String? note;
  final VoidCallback onTap;

  const _NoteRow({required this.note, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasNote = note != null && note!.isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: hasNote
              ? AppTheme.colors.primary.withValues(alpha: 0.05)
              : AppTheme.colors.divider.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: hasNote
                ? AppTheme.colors.primary.withValues(alpha: 0.25)
                : AppTheme.colors.divider.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          children: [
            // Icon(
            //   hasNote ? Icons.sticky_note_2_rounded : Icons.add_comment_outlined,
            //   size: 15.r,
            //   color: hasNote ? AppTheme.colors.primary : AppTheme.colors.gray,
            // ),
            // SizedBox(width: 8.w),
            Expanded(
              child: Text(
                hasNote ? note! : "Izoh qo'shish...",
                style: TextStyle(
                  fontSize: 13.sp,
                  color: hasNote ? AppTheme.colors.black : AppTheme.colors.gray,
                  fontWeight: hasNote ? FontWeight.w600 : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.edit_rounded, size: 12.r, color: AppTheme.colors.gray),
          ],
        ),
      ),
    );
  }
}

// ─── Valid Badge ──────────────────────────────────────────────────────────────

class _ValidBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppTheme.colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, size: 15.r, color: AppTheme.colors.green),
          SizedBox(width: 5.w),
          Text(
            "To'g'ri",
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppTheme.colors.green),
          ),
        ],
      ),
    );
  }
}

// ─── Formatter ────────────────────────────────────────────────────────────────

class _ThousandsSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final number = int.tryParse(newValue.text.replaceAll(RegExp(r'[^0-9]'), ''));
    if (number == null) return oldValue;
    final formatted = NumberFormat('#,###', 'en_US').format(number).replaceAll(',', ' ');
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}
