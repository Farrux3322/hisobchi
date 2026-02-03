import 'dart:developer';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:hisobchi/domain/common/api_path.dart';

import 'interceptor.dart';

Dio createDio() {
  final dio = Dio();

  // SSL Pinning - Senior Level Security
  // This prevents HTTP toolkits (Proxyman, Charles, etc.) from intercepting traffic.
  if (dio.httpClientAdapter is IOHttpClientAdapter) {
    (dio.httpClientAdapter as IOHttpClientAdapter).validateCertificate =
        (X509Certificate? cert, String host, int port) {
      if (host == "api.ehisob.uz") {
        if (cert == null) return false;
        // Verify SHA-256 fingerprint
        final fingerprint = sha256.convert(cert.der).toString().toUpperCase();
        const pinnedFingerprint = "81F96C24A26FB9D7E171E8AC1F449DE7EF5F8698AC5A532CA6FFE65141C9D0D1";
        return fingerprint == pinnedFingerprint;
      }
      return true; // Allow other hosts if any
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
      receiveTimeout: const Duration(seconds: 15),
    );
}

final dio = createDio();
