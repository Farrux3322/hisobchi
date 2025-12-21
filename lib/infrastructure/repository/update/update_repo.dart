import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hisobchi/domain/common/api_path.dart';

class UpdateRepository {
  Future<Map<String, dynamic>> updateApp({
    required String appVersion,
  }) async {
    final dio = Dio();
    String username = 'login';
    String password = 'password';
    String basicAuth = 'Basic ${base64.encode(utf8.encode('$username:$password'))}';

    final response = await dio.post('${baseUrlApp}v1/auth/mobile-check-version', data: {'app_version': appVersion}, options: Options(headers: {'authorization': basicAuth}));
    return response.data;
  }
}
