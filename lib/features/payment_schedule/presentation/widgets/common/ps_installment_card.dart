import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../presentation/assets/asset_index.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/installment_item_model.dart';

class PSInstallmentCard extends StatelessWidget {
  final InstallmentItemModel item;
  final bool isEditable;
  final PaymentCurrency currency;
  final ValueChanged<String>? onLabelEdit;
  final ValueChanged<double>? onAmountEdit;
  final ValueChanged<DateTime>? onDateEdit;
  final VoidCallback? onDelete;

  const PSInstallmentCard({
    super.key,
    required this.item,
    this.isEditable = false,
    required this.currency,
    this.onLabelEdit,
    this.onAmountEdit,
    this.onDateEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: item.isAdvance
              ? const Color(0xFFF97316)
              : AppTheme.colors.divider,
          width: item.isAdvance ? 1.5.w : 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (item.isAdvance) ...[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF97316).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    'AVANS',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFF97316),
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
              ],
              Expanded(
                child: GestureDetector(
                  onTap: isEditable && onLabelEdit != null ? () => _showLabelEditDialog(context) : null,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isEditable && onLabelEdit != null) ...[
                        SizedBox(width: 6.w),
                        Icon(
                          Icons.edit_rounded,
                          size: 14.r,
                          color: AppTheme.colors.iconColor,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (isEditable && onDelete != null && !item.isAdvance)
                IconButton(
                  icon: Icon(Icons.remove_circle_outline_rounded, size: 20.r),
                  color: AppTheme.colors.red,
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildField(
                  label: 'Summa',
                  value: _formatAmount(item.amount),
                  isEditable: isEditable,
                  onTap: isEditable && onAmountEdit != null
                      ? () => _showAmountEditDialog(context)
                      : null,
                  showCalendarIcon: false,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildField(
                  label: 'To\'lov sanasi',
                  value: dateFormat.format(item.dueDate),
                  isEditable: isEditable,
                  onTap: isEditable && onDateEdit != null
                      ? () => _showDatePicker(context)
                      : null,
                  showCalendarIcon: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String value,
    required bool isEditable,
    VoidCallback? onTap,
    bool showCalendarIcon = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.colors.gray,
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppTheme.colors.divider.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10.r),
              border: isEditable ? Border.all(color: AppTheme.colors.divider.withValues(alpha: 0.2)) : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.colors.black,
                    ),
                  ),
                ),
                if (isEditable && showCalendarIcon)
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 14.r,
                    color: AppTheme.colors.primary,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    return NumberFormat('#,###', 'en_US').format(amount).replaceAll(',', ' ');
  }

  void _showLabelEditDialog(BuildContext context) {
    final controller = TextEditingController(text: item.label);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text('Nomni tahrirlash', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Nom',
            hintText: 'Masalan: 1-qism',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Bekor qilish', style: TextStyle(color: AppTheme.colors.gray)),
          ),
          TextButton(
            onPressed: () {
              onLabelEdit?.call(controller.text);
              Navigator.pop(context);
            },
            child: Text('Saqlash', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.colors.primary)),
          ),
        ],
      ),
    );
  }

  void _showAmountEditDialog(BuildContext context) {
    final initialAmount = item.amount > 0 ? item.amount.toInt() : null;
    final controller = TextEditingController(
      text: initialAmount != null ? NumberFormat('#,###', 'en_US').format(initialAmount).replaceAll(',', ' ') : '',
    );
    final currencyLabel = currency == PaymentCurrency.uzs ? 'so\'m' : '\$';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text('Summani tahrirlash', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Summa',
            suffixText: currencyLabel,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _ThousandsSeparatorInputFormatter(),
          ],
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Bekor qilish', style: TextStyle(color: AppTheme.colors.gray)),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(controller.text.replaceAll(' ', '')) ?? 0;
              onAmountEdit?.call(amount);
              Navigator.pop(context);
            },
            child: Text('Saqlash', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.colors.primary)),
          ),
        ],
      ),
    );
  }

  void _showDatePicker(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: item.dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      onDateEdit?.call(date);
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
