import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:ehisob/domain/common/api_path.dart';

import 'interceptor.dart';
import 'retry_interceptor.dart';

String get _userAgentPlatform => Platform.isIOS ? 'iOS' : 'Android';

Dio createDio() {
  final dio = Dio();

  if (dio.httpClientAdapter is IOHttpClientAdapter) {
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final SecurityContext securityContext = SecurityContext(withTrustedRoots: true);
      final client = HttpClient(context: securityContext);
      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Enforce HTTPS security and hostname validation
        const allowedHosts = ['api.ehisob.uz', 'ehisob.uz'];
        if (allowedHosts.contains(host)) {
          return true;
        }
        return false;
      };
      return client;
    };
  }

  return dio
    ..interceptors.addAll(
      [
        if (kDebugMode)
          LogInterceptor(
            responseHeader: false,
            requestBody: true,
            responseBody: true,
            logPrint: (error) => log(error.toString()),
          ),
        RetryInterceptor(),
        DioInterceptor(),
      ],
    )
    ..options = BaseOptions(
      baseUrl: baseUrlApp,
      headers: {
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.userAgentHeader: 'E-Hisob/1.0.0 ($_userAgentPlatform; uz.ehisob.app)',
      },
      connectTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
    );
}

final dio = createDio();

@Deprecated('Use DioInterceptor directly - generates unique keys per request')
class ApiMethods {
  static String key = "";
  static String id = "";
}
