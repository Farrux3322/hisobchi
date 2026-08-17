import 'package:dio/dio.dart';
import 'package:ehisob/infrastructure/common/network_provider.dart';
import 'package:ehisob/infrastructure/dto/models/installment_report/installment_report_models.dart';

class InstallmentReportRepository {
  /// GET /reports/installments/summary
  Future<List<InstallmentSummaryModel>> getSummary() async {
    try {
      final response = await dio.get('/reports/installments/summary');
      if (response.statusCode == 200) {
        final list = response.data['result'] as List? ?? [];
        return list.map((e) => InstallmentSummaryModel.fromJson(e)).toList();
      }
      throw Exception('Failed to load summary');
    } on DioException catch (e) {
      throw Exception(_err(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  /// GET /reports/installments/recovery
  Future<List<InstallmentRecoveryModel>> getRecovery() async {
    try {
      final response = await dio.get('/reports/installments/recovery');
      if (response.statusCode == 200) {
        final list = response.data['result'] as List? ?? [];
        return list.map((e) => InstallmentRecoveryModel.fromJson(e)).toList();
      }
      throw Exception('Failed to load recovery');
    } on DioException catch (e) {
      throw Exception(_err(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  /// GET /reports/installments/forecast
  Future<List<InstallmentForecastModel>> getForecast({
    required String dateFrom,
    required String dateTo,
    int? currencyTypeId,
  }) async {
    try {
      final params = <String, dynamic>{
        'date_from': dateFrom,
        'date_to': dateTo,
      };
      if (currencyTypeId != null) params['currency_type_id'] = currencyTypeId;

      final response = await dio.get('/reports/installments/forecast', queryParameters: params);
      if (response.statusCode == 200) {
        final list = response.data['result'] as List? ?? [];
        return list.map((e) => InstallmentForecastModel.fromJson(e)).toList();
      }
      throw Exception('Failed to load forecast');
    } on DioException catch (e) {
      throw Exception(_err(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  /// GET /reports/installments/risky-partners
  Future<List<InstallmentRiskyPartnerModel>> getRiskyPartners({
    int? currencyTypeId,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (currencyTypeId != null) params['currency_type_id'] = currencyTypeId;

      final response = await dio.get('/reports/installments/risky-partners', queryParameters: params);
      if (response.statusCode == 200) {
        final list = response.data['result'] as List? ?? [];
        return list.map((e) => InstallmentRiskyPartnerModel.fromJson(e)).toList();
      }
      throw Exception('Failed to load risky partners');
    } on DioException catch (e) {
      throw Exception(_err(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  /// GET /reports/installments/monthly
  Future<List<InstallmentMonthlyModel>> getMonthly({
    int? year,
    int? currencyTypeId,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (year != null) params['year'] = year;
      if (currencyTypeId != null) params['currency_type_id'] = currencyTypeId;

      final response = await dio.get('/reports/installments/monthly', queryParameters: params);
      if (response.statusCode == 200) {
        final list = response.data['result'] as List? ?? [];
        return list.map((e) => InstallmentMonthlyModel.fromJson(e)).toList();
      }
      throw Exception('Failed to load monthly');
    } on DioException catch (e) {
      throw Exception(_err(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  /// GET /reports/installments/partners
  Future<InstallmentPartnersResponse> getPartners({
    int? currencyTypeId,
    String sort = 'remaining',
    int page = 1,
  }) async {
    try {
      final params = <String, dynamic>{'sort': sort, 'page': page};
      if (currencyTypeId != null) params['currency_type_id'] = currencyTypeId;

      final response = await dio.get('/reports/installments/partners', queryParameters: params);
      if (response.statusCode == 200) {
        return InstallmentPartnersResponse.fromJson(response.data);
      }
      throw Exception('Failed to load partners');
    } on DioException catch (e) {
      throw Exception(_err(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  /// GET /reports/installments/items
  Future<InstallmentItemsResponse> getItems({
    required String status,
    int currencyTypeId = 1,
    int page = 1,
  }) async {
    try {
      final params = <String, dynamic>{
        'status': status,
        'currency_type_id': currencyTypeId,
        'page': page,
      };
      final response = await dio.get('/reports/installments/items', queryParameters: params);
      if (response.statusCode == 200) {
        return InstallmentItemsResponse.fromJson(response.data);
      }
      throw Exception('Failed to load items');
    } on DioException catch (e) {
      throw Exception(_err(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  String _err(DioException e) {
    if (e.response?.data != null && e.response?.data is Map) {
      return e.response?.data['message'] ?? 'Xatolik yuz berdi';
    }
    return e.message ?? 'Xatolik yuz berdi';
  }
}
