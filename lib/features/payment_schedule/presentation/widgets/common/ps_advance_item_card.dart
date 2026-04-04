import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../presentation/assets/asset_index.dart';

/// Boshlang'ich to'lov (avans) item kard.
///
/// Ikkala jadval turida (equal va custom) bir xil ko'rinish va xulq:
/// - Summa maydoni bosilganda dialog ochiladi
/// - Sana maydoni bosilganda datePicker ochiladi
/// - [accentColor] oranj (0xFFF97316) bo'ladi
class PSAdvanceItemCard extends StatelessWidget {
  final double amount;
  final String dueDate; // 'yyyy-MM-dd' yoki bo'sh
  final String currSym;
  final String? note;
  final ValueChanged<double> onAmountChanged;
  final ValueChanged<String>? onNoteChanged;
  final VoidCallback onDateTap;

  const PSAdvanceItemCard({
    super.key,
    required this.amount,
    required this.dueDate,
    required this.currSym,
    this.note,
    required this.onAmountChanged,
    this.onNoteChanged,
    required this.onDateTap,
  });

  static const _orange = Color(0xFFF97316);

  @override
  Widget build(BuildContext context) {
    final dateText = dueDate.isNotEmpty
        ? DateFormat('dd.MM.yyyy').format(DateTime.tryParse(dueDate) ?? DateTime.now())
        : 'Tanlang';

    final amountText = amount > 0
        ? NumberFormat('#,###', 'en_US').format(amount).replaceAll(',', ' ')
        : '0';

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _orange.withValues(alpha: 0.45), width: 1.5.w),
        boxShadow: [
          BoxShadow(
            color: _orange.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: _orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  'AVANS',
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w800,
                    color: _orange,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                "Boshlang'ich to'lov",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // ── Summa + Sana ────────────────────────────────────────────────
          Row(
            children: [
              // Summa — tap → dialog
              Expanded(
                child: _FieldTap(
                  label: 'Summa',
                  accentColor: _orange,
                  onTap: () => _showAmountDialog(context),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          amountText,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: amount > 0 ? AppTheme.colors.black : AppTheme.colors.gray,
                          ),
                        ),
                      ),
                      Icon(Icons.edit_rounded, size: 13.r, color: _orange),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              // Sana — tap → datePicker
              Expanded(
                child: _FieldTap(
                  label: "To'lov sanasi",
                  accentColor: _orange,
                  onTap: onDateTap,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          dateText,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.colors.black,
                          ),
                        ),
                      ),
                      Icon(Icons.calendar_today_rounded, size: 13.r, color: _orange),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Izoh ────────────────────────────────────────────────────────
          if (onNoteChanged != null) ...[
            SizedBox(height: 10.h),
            _NoteRow(
              note: note,
              accentColor: _orange,
              onTap: () => _showNoteDialog(context),
            ),
          ],
        ],
      ),
    );
  }

  void _showAmountDialog(BuildContext context) {
    final ctrl = TextEditingController(
      text: amount > 0
          ? NumberFormat('#,###', 'en_US').format(amount.toInt()).replaceAll(',', ' ')
          : '',
    );

    showDialog(
      context: context,
      builder: (_) => _AmountDialog(
        title: "Boshlang'ich to'lov summasi",
        controller: ctrl,
        currSym: currSym,
        accentColor: _orange,
        onConfirm: (value) => onAmountChanged(value),
      ),
    );
  }

  void _showNoteDialog(BuildContext context) {
    final ctrl = TextEditingController(text: note ?? '');
    showDialog(
      context: context,
      builder: (_) => _NoteDialog(
        controller: ctrl,
        accentColor: _orange,
        onConfirm: (value) => onNoteChanged?.call(value),
      ),
    );
  }
}

// ─── Reusable field tap container ─────────────────────────────────────────────

class _FieldTap extends StatelessWidget {
  final String label;
  final Color accentColor;
  final VoidCallback onTap;
  final Widget child;

  const _FieldTap({
    required this.label,
    required this.accentColor,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: AppTheme.colors.gray,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppTheme.colors.divider.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: accentColor.withValues(alpha: 0.25)),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ─── Amount dialog (shared) ────────────────────────────────────────────────────

class _AmountDialog extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final String currSym;
  final Color accentColor;
  final ValueChanged<double> onConfirm;

  const _AmountDialog({
    required this.title,
    required this.controller,
    required this.currSym,
    required this.accentColor,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      title: Text(
        title,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800),
      ),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        cursorColor: accentColor,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          _ThousandsSeparatorFormatter(),
        ],
        autofocus: true,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: AppTheme.colors.black,
        ),
        decoration: InputDecoration(
          hintText: '0',
          hintStyle: TextStyle(color: AppTheme.colors.divider),
          suffixText: currSym,
          suffixStyle: TextStyle(
            fontSize: 14.sp,
            color: AppTheme.colors.gray,
            fontWeight: FontWeight.w600,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppTheme.colors.divider),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: accentColor, width: 2),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Bekor',
            style: TextStyle(color: AppTheme.colors.gray, fontWeight: FontWeight.w600),
          ),
        ),
        TextButton(
          onPressed: () {
            final amount = double.tryParse(controller.text.replaceAll(' ', '')) ?? 0;
            onConfirm(amount);
            Navigator.pop(context);
          },
          child: Text(
            'Saqlash',
            style: TextStyle(
              color: accentColor,
              fontWeight: FontWeight.w800,
              fontSize: 15.sp,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Note row ─────────────────────────────────────────────────────────────────

class _NoteRow extends StatelessWidget {
  final String? note;
  final Color accentColor;
  final VoidCallback onTap;

  const _NoteRow({required this.note, required this.accentColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasNote = note != null && note!.isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: hasNote
              ? accentColor.withValues(alpha: 0.05)
              : AppTheme.colors.divider.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: hasNote ? accentColor.withValues(alpha: 0.25) : AppTheme.colors.divider.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          children: [
            Icon(
              hasNote ? Icons.sticky_note_2_rounded : Icons.add_comment_outlined,
              size: 15.r,
              color: hasNote ? accentColor : AppTheme.colors.gray,
            ),
            SizedBox(width: 8.w),
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

// ─── Note dialog ──────────────────────────────────────────────────────────────

class _NoteDialog extends StatelessWidget {
  final TextEditingController controller;
  final Color accentColor;
  final ValueChanged<String> onConfirm;

  const _NoteDialog({
    required this.controller,
    required this.accentColor,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      title: Text('Izoh', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800)),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.multiline,
        maxLines: 3,
        maxLength: 200,
        cursorColor: accentColor,
        autofocus: true,
        style: TextStyle(fontSize: 14.sp, color: AppTheme.colors.black),
        decoration: InputDecoration(
          hintText: 'Izoh kiriting...',
          hintStyle: TextStyle(color: AppTheme.colors.gray),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppTheme.colors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: accentColor, width: 2),
          ),
          contentPadding: EdgeInsets.all(12.r),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Bekor', style: TextStyle(color: AppTheme.colors.gray, fontWeight: FontWeight.w600)),
        ),
        TextButton(
          onPressed: () {
            final value = controller.text.trim();
            onConfirm(value);
            Navigator.pop(context);
          },
          child: Text(
            'Saqlash',
            style: TextStyle(color: accentColor, fontWeight: FontWeight.w800, fontSize: 15.sp),
          ),
        ),
      ],
    );
  }
}

// ─── Toggle Card (shared, used in both pages) ──────────────────────────────────

/// Boshlang'ich to'lov toggle kard.
/// Ikkala jadval turida ishlatiladi — bir xil ko'rinish.
class PSAdvanceToggleCard extends StatelessWidget {
  final bool isEnabled;
  final ValueChanged<bool> onToggled;

  const PSAdvanceToggleCard({
    super.key,
    required this.isEnabled,
    required this.onToggled,
  });

  static const _orange = Color(0xFFF97316);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggled(!isEnabled),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppTheme.colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: isEnabled ? _orange : AppTheme.colors.divider,
            width: isEnabled ? 1.5.w : 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: (isEnabled ? _orange : Colors.black)
                  .withValues(alpha: isEnabled ? 0.08 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 42.r,
              height: 42.r,
              decoration: BoxDecoration(
                color: (isEnabled ? _orange : AppTheme.colors.divider)
                    .withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isEnabled
                    ? Icons.payments_rounded
                    : Icons.money_off_csred_rounded,
                color: isEnabled ? _orange : AppTheme.colors.gray,
                size: 22.r,
              ),
            ),
            SizedBox(width: 14.w),
            // Matn
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: isEnabled ? _orange : AppTheme.colors.black,
                    ),
                    child: const Text("Boshlang'ich to'lov"),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    isEnabled
                        ? "Dastlabki to'lov miqdorini kiriting"
                        : "Faollashtirish uchun bosing",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppTheme.colors.gray,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            // Switch
            _ToggleSwitch(isEnabled: isEnabled, activeColor: _orange),
          ],
        ),
      ),
    );
  }
}

// ─── Toggle Switch ─────────────────────────────────────────────────────────────

class _ToggleSwitch extends StatelessWidget {
  final bool isEnabled;
  final Color activeColor;

  const _ToggleSwitch({required this.isEnabled, required this.activeColor});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 48.r,
      height: 28.r,
      decoration: BoxDecoration(
        color: isEnabled ? activeColor : AppTheme.colors.divider,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        alignment: isEnabled ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 22.r,
          height: 22.r,
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Formatter ─────────────────────────────────────────────────────────────────

class _ThousandsSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final number =
        int.tryParse(newValue.text.replaceAll(RegExp(r'[^0-9]'), ''));
    if (number == null) return oldValue;
    final formatted =
        NumberFormat('#,###', 'en_US').format(number).replaceAll(',', ' ');
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
