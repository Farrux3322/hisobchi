import 'package:dio/dio.dart';
import 'package:hisobchi/infrastructure/common/network_provider.dart';
import 'package:hisobchi/infrastructure/models/partner_details_report_model.dart';
import 'package:hisobchi/infrastructure/models/partner_report_model.dart';
import 'package:hisobchi/infrastructure/models/partner_summary_model.dart';
import 'package:hisobchi/infrastructure/models/sent_sms_model.dart';
import 'package:hisobchi/infrastructure/models/time_report_summary_model.dart';
import 'package:hisobchi/infrastructure/models/partner_operations_detail_model.dart';
import 'package:hisobchi/infrastructure/models/warranty_periods_model.dart';

import '../../models/staff_worker_model.dart';

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
      final response = await dio.get('/reports/partners-v3/summary');

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
        '/reports/partners-v3/summary',
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

  /// Get Time Report Summary (Sana hisoboti: Jami Kirim, Jami Chiqim)
  /// Endpoint: POST /reports/partners-v3/periods
  Future<TimeReportSummaryResponse> getTimeReportSummary({List<String>? date}) async {
    try {
      final Map<String, dynamic> body = {};
      if (date != null && date.isNotEmpty) {
        body['date'] = date;
      }
      else{
        body['date'] = null;
      }

      final response = await dio.get(
        '/reports/partners-v3/periods',
        data: body,
      );

      if (response.statusCode == 200) {
        return TimeReportSummaryResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load time report summary');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  /// Get Time Report Summary for Workers (Xodimlar hisoboti - Jami kirim/chiqim)
  /// Endpoint: GET /reports/partners-v3/workers
  Future<TimeReportSummaryResponse> getWorkersSummary({List<String>? date}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      
      if (date != null && date.isNotEmpty) {
        queryParams['date[]'] = date;
      }
      
      final response = await dio.get('/reports/partners-v3/workers', queryParameters: queryParams);

      if (response.statusCode == 200) {
        return TimeReportSummaryResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load workers summary');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  /// Get Worker lists based on currency
  /// Endpoint: GET /reports/partners-v3/workers-lists
  Future<StaffWorkerResponse> getWorkersList({
    required int currencyTypeId,
    List<String>? date,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'currency_type_id': currencyTypeId,
      };
      
      if (date != null && date.isNotEmpty) {
        queryParams['date[]'] = date;
      }

      final response = await dio.get('/reports/partners-v3/workers-lists', queryParameters: queryParams);

      if (response.statusCode == 200) {
        return StaffWorkerResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load workers list');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  /// Get Time Report Summary for a specific worker
  /// Endpoint: GET /reports/partners-v3/workers-details->summary
  Future<TimeReportSummaryResponse> getWorkerDetailsSummary({
    required int workerId,
    List<String>? date,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'worker_id': workerId,
      };
      
      if (date != null && date.isNotEmpty) {
        queryParams['date[]'] = date;
      }

      final response = await dio.get('/reports/partners-v3/workers-details->summary', queryParameters: queryParams);

      if (response.statusCode == 200) {
        return TimeReportSummaryResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load worker details summary');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  /// Get Worker Details Operations (xodimning operatsiyalar tarixi)
  /// Endpoint: GET /reports/partners-v3/workers-details->operations
  Future<PartnerOperationsDetailResponse> getWorkerDetailsOperations({
    required int workerId,
    required int currencyTypeId,
    List<String>? date,
    String? type,
    int page = 1,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'worker_id': workerId,
        'currency_type_id': currencyTypeId,
        'page': page,
      };

      if (date != null && date.isNotEmpty) {
        queryParams['date[]'] = date;
      }
      
      if (type != null && type.isNotEmpty && type != 'all') {
        queryParams['type'] = type;
      }

      final response = await dio.get('/reports/partners-v3/workers-details->operations', queryParameters: queryParams);

      if (response.statusCode == 200) {
        return PartnerOperationsDetailResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load worker details operations');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  /// Get Warranty Periods Summary (Qarz muddatlari stats)
  /// Endpoint: GET /reports/partners-v3/warranty-periods
  Future<WarrantyPeriodsResponse> getWarrantyPeriods() async {
    try {
      final response = await dio.get('/reports/partners-v3/warranty-periods');

      if (response.statusCode == 200) {
        return WarrantyPeriodsResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load warranty periods');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  /// Get Warranty Period Details (Paginated list of expired, today, 3_days debts)
  /// Endpoint: GET /reports/partners-v3/warranty-periods-details
  Future<PartnerOperationsDetailResponse> getWarrantyPeriodDetails({
    required String type,
    required int currencyTypeId,
    int page = 1,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'type': type,
        'currency_type_id': currencyTypeId,
        'page': page,
      };

      final response = await dio.get('/reports/partners-v3/warranty-periods-details', queryParameters: queryParams);

      if (response.statusCode == 200) {
        return PartnerOperationsDetailResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load warranty period details');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  /// Get Periods Operations for Time Report (Sana hisoboti operatsiyalari)
  /// Endpoint: GET /reports/partners-v3/periods-operations
  Future<PartnerOperationsDetailResponse> getPeriodsOperations({
    List<String>? date,
    required int currencyTypeId,
    String? type,
    int page = 1,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'currency_type_id': currencyTypeId,
        'page': page,
      };

      if (date != null && date.isNotEmpty) {
        queryParams['date[]'] = date;
      }
      
      if (type != null && type.isNotEmpty && type != 'all') {
        queryParams['type'] = type;
      }

      final response = await dio.get(
        '/reports/partners-v3/periods-operations',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return PartnerOperationsDetailResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load periods operations');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  /// Download partner report as Excel file
  /// Endpoint: GET /partners/partners/export/excel
  Future<List<int>> downloadPartnerExcel() async {
    try {
      final response = await dio.get(
        '/partners/partners/export/excel',
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Accept': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data as List<int>;
      } else {
        throw Exception('Failed to download Excel file');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  /// Get sent SMS report for a partner
  /// Endpoint: GET /reports/partners/sended-sms/{partnerId}
  Future<SentSmsResponse> getSentSms({
    required int partnerId,
    int page = 1,
  }) async {
    try {
      final response = await dio.get(
        '/reports/partners/sended-sms/$partnerId',
        queryParameters: {
          'page': page,
        },
      );

      if (response.statusCode == 200) {
        return SentSmsResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load sent SMS report');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  /// Download single partner report as Excel file
  /// Endpoint: GET /partners/partner/{partnerId}/wallets/export/excel
  Future<List<int>> downloadSinglePartnerExcel(int partnerId) async {
    try {
      final response = await dio.get(
        '/partners/partner/$partnerId/wallets/export/excel',
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Accept': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data as List<int>;
      } else {
        throw Exception('Failed to download Excel file');
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