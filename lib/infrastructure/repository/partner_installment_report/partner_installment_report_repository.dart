import 'package:dio/dio.dart';
import 'package:ehisob/infrastructure/common/network_provider.dart';
import 'package:ehisob/infrastructure/dto/models/partner_installment_report/partner_installment_report_models.dart';

class PartnerInstallmentReportRepository {
  /// GET /reports/installments/partner/{partnerId}
  ///
  /// [itemsStatus] — items filtri: null = barchasi, 'overdue', 'pending', 'partial', 'paid'
  /// [year]        — oylik dinamika uchun yil filtri (default: joriy yil)
  /// [currencyTypeId] — valyuta filtri: 1 = UZS, 2 = USD (optional)
  Future<PartnerInstallmentReportModel> getReport({
    required int partnerId,
    String? itemsStatus,
    int? year,
    int? currencyTypeId,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (itemsStatus != null) params['status'] = itemsStatus;
      if (year != null) params['year'] = year;
      if (currencyTypeId != null) params['currency_type_id'] = currencyTypeId;

      final response = await dio.get(
        '/reports/installments/partner/$partnerId',
        queryParameters: params.isEmpty ? null : params,
      );

      if (response.statusCode == 200) {
        final result = response.data['result'] as Map<String, dynamic>;
        return PartnerInstallmentReportModel.fromJson(result);
      }
      throw Exception('Failed to load partner installment report');
    } on DioException catch (e) {
      throw Exception(_err(e));
    } catch (e) {
      rethrow;
    }
  }

  String _err(DioException e) {
    if (e.response?.data != null && e.response?.data is Map) {
      return e.response?.data['message'] ?? 'Xatolik yuz berdi';
    }
    return e.message ?? 'Xatolik yuz berdi';
  }
}
