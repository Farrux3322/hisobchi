import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ehisob/infrastructure/common/network_provider.dart';

class UpdateRepository {
  Future<Map<String, dynamic>> updateApp({required String appVersion}) async {
    if (Platform.isIOS) {
      return {'status': false};
    }

    String username = 'login';
    String password = 'password';
    String basicAuth = 'Basic ${base64.encode(utf8.encode('$username:$password'))}';

    final response = await dio.post(
      'auth/mobile-check-version',
      data: {
        'app_version': appVersion,
        'platform_type': Platform.isAndroid ? 'android' : 'ios',
      },
      options: Options(headers: {'authorization': basicAuth}),
    );
    return response.data;
  }
}
