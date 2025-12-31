import 'package:dio/dio.dart';
import 'package:hisobchi/infrastructure/common/network_provider.dart';
import 'package:hisobchi/infrastructure/models/client_report_model.dart';

class ClientReportRepository {
  String _getErrorMessage(DioException e) {
    if (e.response?.data != null && e.response?.data is Map) {
      return e.response?.data['message'] ?? 'Xatolik yuz berdi';
    }
    return e.message ?? 'Xatolik yuz berdi';
  }

  // Get section one report
  Future<ClientReportSectionOneResponse> getSectionOneReport() async {
    try {
      final response = await dio.get('/reports/partners/section-one');

      if (response.statusCode == 200) {
        return ClientReportSectionOneResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load client report');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  // Get section two report with date range
  Future<ClientReportSectionTwoResponse> getSectionTwoReport({
    required int partnerId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startDateStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      final endDateStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';

      final response = await dio.get(
        '/reports/partners/section-two/$partnerId',
        queryParameters: {
          'date[0]': startDateStr,
          'date[1]': endDateStr,
        },
      );

      if (response.statusCode == 200) {
        return ClientReportSectionTwoResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load partner detail report');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  // Get section three report with date range and type
  Future<ClientReportSectionThreeResponse> getSectionThreeReport({
    required int partnerId,
    required DateTime startDate,
    required DateTime endDate,
    required String type, // 'debt' or 'credit'
  }) async {
    try {
      final startDateStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      final endDateStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';

      final response = await dio.get(
        '/reports/partners/section-three/$partnerId',
        queryParameters: {
          'date[0]': startDateStr,
          'date[1]': endDateStr,
          'type': type,
        },
      );

      if (response.statusCode == 200) {
        return ClientReportSectionThreeResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load partner transactions');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}