class PhoneFormatter {
  static String formatPhoneNumber(String phone) {
    if (phone.isEmpty) return '';
    // Faqat raqamlarni olib qolamiz
    phone = phone.replaceAll(RegExp(r'\D'), '');

    if (phone.length < 12) return phone;

    // +9989 (93) 737 33 22 formatga keltiramiz
    final countryCode = '+${phone.substring(0, 3)}';
    final operatorCode = phone.substring(3, 5);
    final first = phone.substring(5, 8);
    final second = phone.substring(8, 10);
    final third = phone.substring(10, 12);

    return '$countryCode ($operatorCode) $first $second $third';
  }
}
