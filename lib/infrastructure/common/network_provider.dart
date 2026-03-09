import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hisobchi/domain/common/api_path.dart';

import 'interceptor.dart';
import 'retry_interceptor.dart';

Dio createDio() {
  final dio = Dio();

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
