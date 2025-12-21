/// Exchange Rate Model for Currency Rates API
/// Senior-level implementation with proper error handling and type safety
class ExchangeRateModel {
  final bool status;
  final List<CurrencyRate> rates;

  ExchangeRateModel({
    required this.status,
    required this.rates,
  });

  factory ExchangeRateModel.fromJson(Map<String, dynamic> json) {
    return ExchangeRateModel(
      status: json['status'] ?? false,
      rates: json['result'] != null
          ? (json['result'] as List)
              .map((rate) => CurrencyRate.fromJson(rate))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'result': rates.map((rate) => rate.toJson()).toList(),
    };
  }
}

/// Individual Currency Rate Model
class CurrencyRate {
  final String code;
  final String nameRu;
  final String nameUz;
  final String nominal;
  final String rate;
  final String diff;
  final String date;

  CurrencyRate({
    required this.code,
    required this.nameRu,
    required this.nameUz,
    required this.nominal,
    required this.rate,
    required this.diff,
    required this.date,
  });

  factory CurrencyRate.fromJson(Map<String, dynamic> json) {
    return CurrencyRate(
      code: json['Ccy']?.toString() ?? '',
      nameRu: json['CcyNm_RU']?.toString() ?? '',
      nameUz: json['CcyNm_UZ']?.toString() ?? '',
      nominal: json['Nominal']?.toString() ?? '1',
      rate: json['Rate']?.toString() ?? '0',
      diff: json['Diff']?.toString() ?? '0',
      date: json['Date']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Ccy': code,
      'CcyNm_RU': nameRu,
      'CcyNm_UZ': nameUz,
      'Nominal': nominal,
      'Rate': rate,
      'Diff': diff,
      'Date': date,
    };
  }

  /// Get rate as double for calculations
  double get rateValue {
    return double.tryParse(rate.replaceAll(',', '')) ?? 0.0;
  }

  /// Get diff as double for calculations
  double get diffValue {
    return double.tryParse(diff.replaceAll(',', '')) ?? 0.0;
  }

  /// Check if rate is increasing
  bool get isIncreasing => diffValue > 0;

  /// Check if rate is decreasing
  bool get isDecreasing => diffValue < 0;

  /// Get formatted rate with proper spacing
  String get formattedRate {
    final parts = rate.split('.');
    if (parts.length == 2) {
      return '${_formatWithSpaces(parts[0])}.${parts[1]}';
    }
    return _formatWithSpaces(rate);
  }

  /// Get formatted diff with sign
  String get formattedDiff {
    final sign = diffValue >= 0 ? '+' : '';
    return '$sign$diff';
  }

  /// Format number with spaces for thousands
  String _formatWithSpaces(String number) {
    final cleaned = number.replaceAll(' ', '').replaceAll(',', '');
    final reversed = cleaned.split('').reversed.join();
    final withSpaces = reversed.replaceAllMapped(
      RegExp(r'.{1,3}'),
      (match) => '${match.group(0)} ',
    );
    return withSpaces.trim().split('').reversed.join();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrencyRate &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}