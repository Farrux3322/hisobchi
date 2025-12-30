import 'package:hisobchi/infrastructure/common/network_provider.dart';

class PartnerRepository {
  Future<Map<String, dynamic>> get({
    DateTime? startDate,
    DateTime? endDate,
    String? search,
    String? sort,
    String? statusFilter,
  }) async {
    final Map<String, dynamic> params = {};

    if (startDate != null) {
      params['date[0]'] = startDate.toIso8601String().split('T')[0];
    }
    if (endDate != null) {
      params['date[1]'] = endDate.toIso8601String().split('T')[0];
    }
    if (search != null && search.isNotEmpty) {
      params['search'] = search;
    }
    if (sort != null && sort.isNotEmpty) {
      params['sort'] = sort;
    }
    if (statusFilter != null && statusFilter.isNotEmpty) {
      params['status_filter'] = statusFilter;
    }

    final response = await dio.get(
      '/partners/partners/account',
      queryParameters: params.isNotEmpty ? params : null,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> create({required Object data}) async {
    final response = await dio.post('/partners/partner', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> update({required Object data, required int id}) async {
    final response = await dio.put('/partners/partner/$id', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> delete({required int id}) async {
    final response = await dio.delete('/partners/partner/$id');
    return response.data;
  }

  Future<Map<String, dynamic>> restore({required int id}) async {
    final response = await dio.post('/partners/partner/$id/restore');
    return response.data;
  }
  Future<Map<String, dynamic>> forceDelete({required int id}) async {
    final response = await dio.delete('/partners/partner/$id/force-delete');
    return response.data;
  }
  Future<Map<String, dynamic>> incomeStatement({required int id}) async {
    final response = await dio.get('/partners/partner/$id/account');
    return response.data;
  }
  Future<Map<String, dynamic>> incomeHistory({required int id}) async {
    final response = await dio.get('/partners/wallets',data: {
      'partner_id':id
    });
    return response.data;
  }

  Future<Map<String, dynamic>> createKirim({required Object data}) async {
    final response = await dio.post('/partners/wallet', data: data);
    return response.data;
  }
  Future<Map<String, dynamic>> updateKirim({required Object data,required int id}) async {
    final response = await dio.put('/partners/wallet/$id', data: data);
    return response.data;
  }
  Future<Map<String, dynamic>> cancelIncome({required int walletId,required String description }) async {
    final response = await dio.put('/partners/wallet/$walletId/cancel', data: {
      'cancel_reason':description
    });
    return response.data;
  }

  Future<Map<String, dynamic>> deleteIncome({required int walletId}) async {
    final response = await dio.delete('/partners/wallet/$walletId');
    return response.data;
  }
  Future<Map<String, dynamic>> forceDeleteIncome({required int walletId}) async {
    final response = await dio.delete('/partners/wallet/$walletId/force-delete');
    return response.data;
  }
  Future<Map<String, dynamic>> restoreIncome({required int walletId}) async {
    final response = await dio.post('/partners/wallet/$walletId/restore');
    return response.data;
  }
}
