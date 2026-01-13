class PhoneFormatter {
  static String formatPhoneNumber(String phone) {
    if (phone.isEmpty) return '';
    // Faqat raqamlarni olib qolamiz
    phone = phone.replaceAll(RegExp(r'\D'), '');

    if (phone.length >= 9) {
      final last9 = phone.substring(phone.length - 9);
      final operatorCode = last9.substring(0, 2);
      final first = last9.substring(2, 5);
      final second = last9.substring(5, 7);
      final third = last9.substring(7, 9);

      return '+998 ($operatorCode) $first $second $third';
    }

    return phone;
  }
}
