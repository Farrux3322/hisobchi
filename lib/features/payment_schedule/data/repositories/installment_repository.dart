import 'package:dio/dio.dart';
import 'package:hisobchi/infrastructure/common/dio_exception.dart';
import 'package:hisobchi/infrastructure/common/network_provider.dart';

import '../models/installment_item_model.dart';
import '../models/installment_plan_model.dart';
import '../models/payment_history_model.dart';

class InstallmentRepository {
  // ─── error helper ────────────────────────────────────────────────────────────
  String _err(DioException e) {
    // DioExceptionX serverError'ni to'g'ridan-to'g'ri Map sifatida saqlaydi
    final data = (e is DioExceptionX) ? e.serverError : e.response?.data;
    if (data is Map) {
      // {"errors": {"paid_at": ["The paid at field is required."]}}
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final firstField = errors.values.first;
        if (firstField is List && firstField.isNotEmpty) {
          return firstField.first.toString();
        }
      }
      // {"message": "..."} yoki {"error": {"message": "..."}}
      return data['message']?.toString() ??
          data['error']?['message']?.toString() ??
          'Xatolik yuz berdi';
    }
    return e.message ?? 'Xatolik yuz berdi';
  }

  // ─── 1. Barcha rejalari ro'yxati (paginated) ────────────────────────────────
  Future<({List<InstallmentPlanModel> items, String? nextUrl})> getInstallments({
    int? partnerId,
    String? status,
    int? currencyTypeId,
    String? scheduleType,
    String? search,
    int perPage = 20,
    int page = 1,
  }) async {
    try {
      final response = await dio.get(
        '/partners/installments',
        queryParameters: {
          if (partnerId != null) 'partner_id': partnerId,
          if (status != null) 'status': status,
          if (currencyTypeId != null) 'currency_type_id': currencyTypeId,
          if (scheduleType != null) 'schedule_type': scheduleType,
          if (search != null && search.isNotEmpty) 'search': search,
          'per_page': perPage,
          'page': page,
        },
      );

      final result = response.data['result'];
      final data = result['data'] as List<dynamic>;
      final nextUrl = result['links']?['next']?.toString();

      return (
        items: data.map((e) => InstallmentPlanModel.fromJson(e as Map<String, dynamic>)).toList(),
        nextUrl: nextUrl,
      );
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }

  // ─── 2. Yangi reja yaratish ──────────────────────────────────────────────────
  Future<InstallmentPlanModel> createInstallment({
    required int partnerId,
    required int currencyTypeId,
    required double totalAmount,
    required String scheduleType, // 'equal' | 'custom'
    required bool hasAdvance,
    double? advanceAmount,
    String? note,
    // equal uchun
    String? startDate,
    int? installmentCount,
    // custom uchun — avans KIRITMAY faqat oddiy qismlar
    List<Map<String, dynamic>>? items,
    // yuklangan fayllar ID'lari
    List<int>? fileIds,
  }) async {
    try {
      final body = <String, dynamic>{
        'partner_id': partnerId,
        'currency_type_id': currencyTypeId,
        'total_amount': totalAmount,
        'schedule_type': scheduleType,
        'has_advance': hasAdvance,
        if (note != null && note.isNotEmpty) 'note': note,
        if (hasAdvance && advanceAmount != null && advanceAmount > 0)
          'advance_amount': advanceAmount,
        if (scheduleType == 'equal') 'start_date': startDate,
        if (scheduleType == 'equal') 'installment_count': installmentCount,
        if (items != null && items.isNotEmpty) 'items': items,
        if (fileIds != null && fileIds.isNotEmpty) 'file_ids': fileIds,
      };

      final response = await dio.post('/partners/installments', data: body);
      return InstallmentPlanModel.fromJson(response.data['result'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }

  // ─── 3. Bitta reja (items bilan) ─────────────────────────────────────────────
  Future<InstallmentPlanModel> getInstallmentDetail(int id) async {
    try {
      final response = await dio.get('/partners/installments/$id');
      return InstallmentPlanModel.fromJson(response.data['result'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }

  // ─── 4. Faqat note ni tahrirlash ─────────────────────────────────────────────
  Future<InstallmentPlanModel> updateNote(int id, String note) async {
    try {
      final response = await dio.put('/partners/installments/$id', data: {'note': note});
      return InstallmentPlanModel.fromJson(response.data['result'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }

  // ─── 5. Rejani bekor qilish ──────────────────────────────────────────────────
  Future<InstallmentPlanModel> cancelInstallment(int id) async {
    try {
      final response = await dio.delete('/partners/installments/$id');
      return InstallmentPlanModel.fromJson(response.data['result'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }

  // ─── 6. Reja qismlari ro'yxati ──────────────────────────────────────────────
  Future<List<InstallmentItemModel>> getInstallmentItems(int id) async {
    try {
      final response = await dio.get('/partners/installments/$id/items');
      final data = response.data['result'] as List<dynamic>;
      return data.map((e) => InstallmentItemModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }

  // ─── 7. To'lov qabul qilish (FIFO) ─────────────────────────────────────────
  Future<InstallmentPlanModel> acceptPayment({
    required int installmentId,
    required double amount,
    String? note,
    DateTime? paidAt,
  }) async {
    try {
      final effectivePaidAt = paidAt ?? DateTime.now();
      final response = await dio.post(
        '/partners/installments/$installmentId/payment',
        data: {
          'amount': amount,
          'paid_at': effectivePaidAt.toUtc().toIso8601String(),
          if (note != null && note.isNotEmpty) 'note': note,
        },
      );
      return InstallmentPlanModel.fromJson(response.data['result'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }

  // ─── 8. Hamkorning barcha rejalari (items bilan, paginationsiz) ──────────────
  Future<List<InstallmentPlanModel>> getPartnerInstallments(int partnerId) async {
    try {
      final response = await dio.get('/partners/partner/$partnerId/installments');
      final data = response.data['result'] as List<dynamic>;
      return data.map((e) => InstallmentPlanModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }

  // ─── 9. To'lovlar tarixi ─────────────────────────────────────────────────────
  Future<List<PaymentHistoryModel>> getPaymentHistory(int installmentId) async {
    try {
      final response = await dio.get('/partners/installments/$installmentId/payment-history');
      final data = response.data['result'] as List<dynamic>;
      return data.map((e) => PaymentHistoryModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }

  // ─── 10. To'lovni bekor qilish ───────────────────────────────────────────────
  Future<PaymentHistoryModel> cancelPayment({
    required int installmentId,
    required int paymentId,
  }) async {
    try {
      final response = await dio.delete('/partners/installments/$installmentId/payments/$paymentId');
      final result = response.data['result'];
      // API massiv yoki object qaytarishi mumkin
      final json = result is List ? result.first as Map<String, dynamic> : result as Map<String, dynamic>;
      return PaymentHistoryModel.fromJson(json);
    } on DioException catch (e) {
      throw Exception(_err(e));
    }
  }
}
