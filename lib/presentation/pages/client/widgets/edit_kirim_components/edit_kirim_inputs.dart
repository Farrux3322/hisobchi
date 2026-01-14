import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hisobchi/application/currency/currency_bloc.dart';
import 'package:hisobchi/presentation/assets/theme/app_theme.dart';
import 'package:hisobchi/presentation/components/utils/decimal_input_formatter.dart';
import 'package:intl/intl.dart';

class EditKirimInputs extends StatelessWidget {
  final bool isEditing;
  final bool isKirim;
  final TextEditingController amountController;
  final TextEditingController descriptionController;
  final int selectedCurrencyId;
  final Function(int?) onCurrencyChanged;
  final DateTime? selectedDate;
  final VoidCallback onSelectDate;

  const EditKirimInputs({
    super.key,
    required this.isEditing,
    required this.isKirim,
    required this.amountController,
    required this.descriptionController,
    required this.selectedCurrencyId,
    required this.onCurrencyChanged,
    this.selectedDate,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Amount and Currency Label
        RichText(
          text: const TextSpan(
            text: 'Miqdor ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
            children: [
              TextSpan(
                text: '*',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Amount input and Currency dropdown in row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: TextFormField(
                controller: amountController,
                enabled: isEditing,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [DecimalTextInputFormatter()],
                decoration: InputDecoration(
                  hintText: 'Miqdorni kiriting',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.colors.primary, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Iltimos, miqdorni kiriting';
                  }
                  final cleanValue = value.replaceAll(' ', '');
                  final parsedValue = double.tryParse(cleanValue);
                  if (parsedValue == null) {
                    return 'Faqat son kiritish mumkin';
                  }
                  if (parsedValue <= 0) {
                    return 'Miqdor 0 dan katta bo\'lishi kerak';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: BlocBuilder<CurrencyBloc, CurrencyState>(
                builder: (context, currencyState) {
                  final currencies = currencyState.currencyModel?.result ?? [];
                  
                  return DropdownButtonFormField<int>(
                    value: selectedCurrencyId,
                    isExpanded: true,
                    focusColor: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12.r),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.colors.primary),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                    dropdownColor: Colors.white,
                    items: currencies.isNotEmpty 
                      ? currencies.map((currency) => DropdownMenuItem<int>(value: currency.id, child: Text(currency.name ?? ''))).toList()
                      : const [
                          DropdownMenuItem(value: 1, child: Text('UZS')),
                          DropdownMenuItem(value: 2, child: Text('USD')),
                        ],
                    onChanged: isEditing ? onCurrencyChanged : null,
                  );
                },
              ),
            ),
          ],
        ),

        if (!isKirim) ...[
          const SizedBox(height: 20),
          const Text(
            'Qaytarish sanasi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: isEditing ? onSelectDate : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined, color: AppTheme.colors.primary, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    selectedDate == null ? 'Sanani tanlang' : DateFormat('dd MMM yyyy').format(selectedDate!),
                    style: TextStyle(
                      fontSize: 14,
                      color: selectedDate == null ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                      fontWeight: selectedDate == null ? FontWeight.w400 : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 20),
        const Text(
          'Izoh',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: descriptionController,
          enabled: isEditing,
          maxLines: null,
          decoration: InputDecoration(
            hintText: 'Izoh qoldiring (ixtiyoriy)',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.colors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
