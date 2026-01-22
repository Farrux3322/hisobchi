import 'package:dio/dio.dart';
import 'package:hisobchi/infrastructure/common/network_provider.dart';
import 'package:hisobchi/infrastructure/models/partner_details_report_model.dart';
import 'package:hisobchi/infrastructure/models/partner_report_model.dart';
import 'package:hisobchi/infrastructure/models/partner_summary_model.dart';

class PartnerReportRepository {
  /// Get partner details report (UZS and USD statistics)
  /// Endpoint: GET /reports/partners-v2/partner-details/{partnerId}
  Future<PartnerDetailsReportResponse> getPartnerDetailsReport(int partnerId) async {
    try {
      final response = await dio.get('/reports/partners-v2/partner-details/$partnerId');

      if (response.statusCode == 200) {
        return PartnerDetailsReportResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load partner details report');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  /// Get partner summary list (Debtors or Creditors)
  /// Endpoint: GET /reports/partners-v2/summary-details-section-two
  Future<PartnerSummaryResponse> getPartnerSummaryList({
    required String type,
    required int currencyTypeId,
    int page = 1,
  }) async {
    try {
      final response = await dio.get(
        '/reports/partners-v2/summary-details-section-two',
        queryParameters: {
          'type': type,
          'currency_type_id': currencyTypeId,
          'page': page,
        },
      );

      if (response.statusCode == 200) {
        return PartnerSummaryResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load partner summary list');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  /// Get partner main report (UZS and USD statistics)
  /// Endpoint: GET /reports/partners/main
  Future<PartnerReportMainResponse> getPartnerMainReport() async {
    try {
      final response = await dio.get('/reports/partners-v2/summary');

      if (response.statusCode == 200) {
        return PartnerReportMainResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load partner main report');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  /// Refresh partner main report (for pull-to-refresh)
  Future<PartnerReportMainResponse> refreshPartnerMainReport() async {
    try {
      final response = await dio.get(
        '/reports/partners-v2/summary',
        options: Options(
          headers: {
            'Cache-Control': 'no-cache',
          },
        ),
      );

      if (response.statusCode == 200) {
        return PartnerReportMainResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to refresh partner main report');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  String _getErrorMessage(DioException e) {
    if (e.response?.data != null && e.response?.data is Map) {
      return e.response?.data['message'] ?? 'Xatolik yuz berdi';
    }
    return e.message ?? 'Xatolik yuz berdi';
  }
}