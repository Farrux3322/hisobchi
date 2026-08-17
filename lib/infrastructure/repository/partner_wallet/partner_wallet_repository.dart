import 'package:dio/dio.dart';
import 'package:ehisob/infrastructure/common/network_provider.dart';
import 'package:ehisob/infrastructure/models/partner_wallet_detail_model.dart';

class PartnerWalletRepository {
  String _getErrorMessage(DioException e) {
    if (e.response?.data != null && e.response?.data is Map) {
      return e.response?.data['message'] ?? 'Xatolik yuz berdi';
    }
    return e.message ?? 'Xatolik yuz berdi';
  }

  /// Get partner wallet detail by ID
  /// Endpoint: GET /partners/wallet/{id}
  Future<PartnerWalletDetailResponse> getWalletDetail(int walletId) async {
    try {
      final response = await dio.get('/partners/wallet/$walletId');

      if (response.statusCode == 200) {
        return PartnerWalletDetailResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load wallet detail');
      }
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}