import 'package:dio/dio.dart';
import 'package:hisobchi/infrastructure/common/network_provider.dart';
import 'package:hisobchi/infrastructure/models/partner_operations_detail_model.dart';

class PartnerOperationsRepository {
  String _getErrorMessage(DioException e) {
    if (e.response?.data != null && e.response?.data is Map) {
      return e.response?.data['message'] ?? 'Xatolik yuz berdi';
    }
    return e.message ?? 'Xatolik yuz berdi';
  }

  /// Get partner operations detail with pagination
  /// Endpoint: GET /reports/partners-v2/summary-details-section-one
  /// Parameters:
  ///   - type: 'oparation', 'xaqdor', 'qarzdor', 'qarz_expired', 'qarz_3_days', 'qarz_7_days'
  ///   - currencyTypeId: 1 (UZS) or 2 (USD)
  ///   - page: pagination page number
  Future<PartnerOperationsDetailResponse> getOperationsDetail({
    required String type,
    required int currencyTypeId,
    int page = 1,
  }) async {
    try {
      final response = await dio.get(
        '/reports/partners-v2/summary-details-section-one',
        queryParameters: {
          'type': type,
          'currency_type_id': currencyTypeId,
          'page': page,
        },
      );

      if (response.statusCode == 200) {
        return PartnerOperationsDetailResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load operations detail');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  /// Refresh operations detail (for pull-to-refresh)
  Future<PartnerOperationsDetailResponse> refreshOperationsDetail({
    required String type,
    required int currencyTypeId,
  }) async {
    try {
      final response = await dio.get(
        '/reports/partners-v2/summary-details-section-one',
        queryParameters: {
          'type': type,
          'currency_type_id': currencyTypeId,
          'page': 1,
        },
        options: Options(
          headers: {
            'Cache-Control': 'no-cache',
          },
        ),
      );

      if (response.statusCode == 200) {
        return PartnerOperationsDetailResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to refresh operations detail');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  /// Load more operations (for pagination)
  Future<PartnerOperationsDetailResponse> loadMoreOperations({
    required String type,
    required int currencyTypeId,
    required int page,
  }) async {
    return getOperationsDetail(
      type: type,
      currencyTypeId: currencyTypeId,
      page: page,
    );
  }
}