import 'package:dio/dio.dart';
import 'package:hisobchi/infrastructure/common/network_provider.dart';
import 'package:hisobchi/infrastructure/dto/models/due_dates/due_dates_model.dart';

class DueDatesRepository {
  String _errorMessage(DioException e) {
    if (e.response?.data != null && e.response?.data is Map) {
      return e.response?.data['message'] ?? 'Xatolik yuz berdi';
    }
    return e.message ?? 'Xatolik yuz berdi';
  }

  // ─── Qarz (credit) ──────────────────────────────────────────────────────────

  Future<QarzDueDatesResponse> getQarzDueDates({
    required String type,
    int page = 1,
  }) async {
    try {
      final response = await dio.get(
        '/reports/dashboard/due-dates',
        queryParameters: {'type': type, 'page': page},
      );
      return QarzDueDatesResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }

  // ─── Installment ─────────────────────────────────────────────────────────────

  Future<InstallmentDueDatesResponse> getInstallmentDueDates({
    required String type,
    int page = 1,
  }) async {
    try {
      final response = await dio.get(
        '/reports/dashboard/installments/due-dates',
        queryParameters: {'type': type, 'page': page},
      );
      return InstallmentDueDatesResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_errorMessage(e));
    }
  }
}
