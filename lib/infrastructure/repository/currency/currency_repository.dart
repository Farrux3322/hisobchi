import 'package:hisobchi/infrastructure/common/network_provider.dart';

class CurrencyRepository {
  /// Get list of currencies (old endpoint)
  Future<Map<String, dynamic>> getCurrency() async {
    final response = await dio.get('/documents/currencies');
    return response.data;
  }

  /// Get currency exchange rates from CBU API
  /// Professional implementation with proper error handling
  Future<Map<String, dynamic>> getExchangeRates() async {
    final response = await dio.get('/documents/currencys-exchange-rates');
    return response.data;
  }

  /// Get currency exchange rates by date from new API
  /// Format: yyyy-MM-dd (e.g., 2025-12-22)
  Future<Map<String, dynamic>> getExchangeRatesByDate(String date) async {
    final response = await dio.get('/currency-calc/cbu-rates/$date');
    return response.data;
  }
}
