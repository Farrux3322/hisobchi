import 'package:flutter/services.dart';

class DecimalTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Filter characters: allow digits and a single dot
    String baseText = newValue.text.replaceAll(' ', '');
    
    // Prevent multiple dots
    if (baseText.split('.').length > 2) {
      baseText = oldValue.text.replaceAll(' ', '');
    }

    // Check if valid decimal format (no multiple dots, only digits)
    if (!RegExp(r'^\d*\.?\d*$').hasMatch(baseText)) {
      return oldValue;
    }

    final parts = baseText.split('.');
    String integerPart = parts[0];
    String? decimalPart = parts.length > 1 ? parts[1] : null;

    // Add thousands separation
    final buffer = StringBuffer();
    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(integerPart[i]);
    }

    String formattedText = buffer.toString();
    if (decimalPart != null) {
      formattedText += '.$decimalPart';
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
