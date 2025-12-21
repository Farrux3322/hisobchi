import 'package:easy_localization/easy_localization.dart';

class DateFormatter {
  /// Returns a formatted date
  /// ```
  /// Example 05.10.2020.
  /// ```
  static String convertToDMY(dynamic date) {
    if (date is DateTime) {
      return DateFormat('dd.MM.yyyy').format(date);
    } else {
      return DateFormat('dd.MM.yyyy').format(DateTime.parse(date));
    }
  }

  /// Returns a formatted date
  /// ```
  /// Example 2020-12-30.
  /// ```
  static String convertToYMD(dynamic date) {
    if (date is DateTime) {
      return DateFormat('yyyy-MM-dd').format(date);
    } else {
      return DateFormat('yyyy-MM-dd').format(DateTime.parse(date));
    }
  }

  /// Returns a formatted date
  /// ```
  /// Example 05.10.20.
  /// ```
  static String convertToDMYY(dynamic date) {
    if (date is DateTime) {
      return DateFormat('dd.MM.yy').format(date);
    } else {
      return DateFormat('dd.MM.yy').format(DateTime.parse(date));
    }
  }

  /// Returns a formatted date
  /// ```
  /// Example 01:23:18.
  /// ```
  static String convertToHms(dynamic date) {
    if (date is DateTime) {
      return DateFormat.Hms().format(date);
    } else {
      return DateFormat.Hms().format(DateTime.parse(date));
    }
  }

  /// Returns a formatted date
  /// ```
  /// Example 05.10.2020 - 01:23:18.
  /// ```
  static String convertToDateTime(dynamic date) {
    String d, t;
    if (date is DateTime) {
      d = DateFormat('dd.MM.yyyy').format(date);
      t = DateFormat.Hms().format(date);
    } else {
      d = DateFormat('dd/MM/yyyy').format(DateTime.parse(date));
      t = DateFormat.Hms().format(DateTime.parse(date));
    }

    return '$d - $t';
  }

  /// Returns a formatted date
  /// ```
  /// Example Nov 24, 2022
  /// ```
  static String convertToMMMd(dynamic date) {
    try {
      dynamic value = date;

      if (date is DateTime) {
        value = date;
      } else if (date is String) {
        value = DateTime.parse(date).toLocal();
      }

      return DateFormat.yMMMd().format(value);
    } catch (e) {
      return date;
    }
  }

  /// Returns a formatted date
  /// ```
  /// Example Вторник, 15 февраля.
  /// ```
  static String convertToEDM(dynamic date) {
    if (date is DateTime) {
      return DateFormat('EEEE, d MMMM').format(date);
    } else {
      return DateFormat('EEEE, d MMMM').format(DateTime.parse(date));
    }
  }

  static Duration checkDateDiff(String date) {
    try {
      if (date.isEmpty) {
        return Duration.zero;
      }
      final DateTime currentDate = DateTime.now();
      return currentDate.difference(DateTime.parse(date));
    }catch(_) {
      return Duration.zero;
    }
  }
}
