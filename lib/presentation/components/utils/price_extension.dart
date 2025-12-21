import 'dart:io';

String priceFormatter(String numberText) {
  if (numberText.isEmpty) return "";
  int number = int.parse(numberText.replaceAll(" ", ""));
  final List<String> parts = [];
  final String numberStr = number.toString();

  int i = numberStr.length;
  while (i > 0) {
    final int j = i - 3;
    parts.add(numberStr.substring(j < 0 ? 0 : j, i));
    i = j;
  }

  return parts.reversed.join(' ');
}

extension PriceFormat on num {
  String priceFormat() {
    return priceFormatter("$this");
  }
}

class PriceFormatter {
  // static String priceFormat(String numberText) {
  //   if (numberText.isEmpty) return "";
  //   final parts = numberText.split('.');
  //   final whole = parts[0].replaceAll(" ", "");
  //   final fraction = parts.length > 1 ? parts[1] : null;
  //
  //   int number = int.parse(whole);
  //   final List<String> chunks = [];
  //   final String numberStr = number.toString();
  //
  //   int i = numberStr.length;
  //   while (i > 0) {
  //     final int j = i - 3;
  //     chunks.add(numberStr.substring(j < 0 ? 0 : j, i));
  //     i = j;
  //   }
  //
  //   String formatted = chunks.reversed.join(' ');
  //   if (fraction != null && fraction.isNotEmpty) {
  //     formatted += '.$fraction';
  //   }
  //
  //   return formatted;
  // }
  static String priceFormat(String numberText) {
    // Hamma vergul va bo'sh joylarni olib tashlash
    numberText = numberText.replaceAll(RegExp(r'[,\s]'), '');
    if (numberText.isEmpty) return "";

    final parts = numberText.split('.');
    final whole = parts[0];
    String? fraction = parts.length > 1 ? parts[1] : null;

    int number = int.parse(whole);
    final List<String> chunks = [];
    final String numberStr = number.toString();

    int i = numberStr.length;
    while (i > 0) {
      final int j = i - 3;
      chunks.add(numberStr.substring(j < 0 ? 0 : j, i));
      i = j;
    }

    String formatted = chunks.reversed.join(' ');

    if (fraction != null && fraction.isNotEmpty) {
      // faqat 2 xonagacha olish
      fraction = fraction.length > 2 ? fraction.substring(0, 2) : fraction;

      // agar fraction hammasi 0 bo‘lsa qo‘shilmaydi
      if (int.parse(fraction) != 0) {
        formatted += '.$fraction';
      }
    }

    return formatted;
  }

  static String clearFormat(String formattedText) {
    if (formattedText.isEmpty) return "";
    return formattedText.replaceAll(' ', '');
  }

  static String clearFormatWithZero(String formattedText) {
    if (formattedText.isEmpty) return "0";
    return formattedText.replaceAll(' ', '');
  }
}

bool isFile(File file) {
  return file.existsSync();
}
