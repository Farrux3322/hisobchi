import 'package:ehisob/infrastructure/common/network_provider.dart';

class IdentificationRepository {
  Future<Map<String, dynamic>> verifyIdentity(String code) async {
    // Note: The specific endpoint for identity verification should be provided by the backend.
    // This is a placeholder for the integration logic.
    final response = await dio.post(
      '/user/verify-identity',
      data: {'code': code},
    );
    return response.data;
  }
}
