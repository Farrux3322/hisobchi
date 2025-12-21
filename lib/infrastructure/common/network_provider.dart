import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:hisobchi/domain/common/api_path.dart';

import 'interceptor.dart';

Dio createDio() {
  final dio = Dio();
  return dio
    ..interceptors.addAll(
      [
        LogInterceptor(
          responseHeader: false,
          requestBody: true,
          responseBody: true,
          logPrint: (error) => log(error.toString()),
        ),
        DioInterceptor(),
      ],
    )
    ..options = BaseOptions(
      baseUrl: baseUrlApp,
      headers: {
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );
}

final dio = createDio();
