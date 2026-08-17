import 'package:flutter/services.dart';
import 'package:ehisob/presentation/components/utils/price_extension.dart';

class RangeInputFormatter extends TextInputFormatter {
  final int min;
  final int max;

  RangeInputFormatter({required this.min, required this.max});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final number = int.tryParse(newValue.text.replaceAll(" ", "")) ?? 0;
    if (number > max) {
      return oldValue;
    }
    final formatted = PriceFormatter.priceFormat(number.toString());
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class MaxValueInputFormatter extends TextInputFormatter {
  final int max;

  MaxValueInputFormatter(this.max);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (newValue.text.isEmpty) return newValue;

    final number = int.tryParse(newValue.text) ?? 0;
    if (number > max) {
      return oldValue;
    }
    return newValue;
  }
}


class DecimalInputFormatter extends TextInputFormatter {
  final double maxValue;
  final int decimalDigits;

  DecimalInputFormatter({
    required this.maxValue,
    this.decimalDigits = 2,
  });

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Vergulni nuqtaga almashtirish (internal storage uchun)
    String text = newValue.text.replaceAll(',', '.');

    // Faqat raqamlar va bitta decimal separator
    if (!RegExp(r'^\d*\.?\d*$').hasMatch(text)) {
      return oldValue;
    }

    // Bir nechta nuqta bo'lmasligi uchun
    if ('.'.allMatches(text).length > 1) {
      return oldValue;
    }

    // Decimal qismni cheklash
    if (text.contains('.')) {
      List<String> parts = text.split('.');
      if (parts[1].length > decimalDigits) {
        return oldValue;
      }
    }

    // Qiymatni tekshirish
    final number = double.tryParse(text);
    if (number == null) {
      return oldValue;
    }

    if (number > maxValue) {
      return oldValue;
    }

    // Display uchun vergulni qaytarish (agar kerak bo'lsa)
    // Agar foydalanuvchi vergul ishlatgan bo'lsa, uni saqlab qolish
    String displayText = newValue.text;

    return TextEditingValue(
      text: displayText,
      selection: newValue.selection,
    );
  }
}