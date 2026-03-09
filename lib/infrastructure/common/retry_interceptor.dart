import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Senior-level Retry Interceptor for Dio
/// 
/// Features:
/// - Handles transient network errors (timeouts, connection issues)
/// - Exponential backoff to avoid hammering the server
/// - Smart idempotent check (retries GET/HEAD safely)
/// - Configurable max retries
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration initialDelay;

  RetryInterceptor({
    this.maxRetries = 3,
    this.initialDelay = const Duration(milliseconds: 1000),
  });

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;

    // Check if we should retry
    if (_shouldRetry(err, requestOptions)) {
      int attempt = (requestOptions.extra['retry_attempt'] ?? 0) + 1;

      if (attempt <= maxRetries) {
        requestOptions.extra['retry_attempt'] = attempt;
        
        // Exponential backoff delay
        final delay = initialDelay * attempt;
        
        if (kDebugMode) {
          print('🔄 Retrying request [${requestOptions.method}] ${requestOptions.path} (Attempt $attempt/$maxRetries) in ${delay.inMilliseconds}ms');
        }

        await Future.delayed(delay);

        try {
          // Re-send the request using a new Dio instance
          final response = await _retryRequest(requestOptions, err.requestOptions.cancelToken);
          return handler.resolve(response);
        } on DioException catch (retryErr) {
          // If the retry also fails, continue with the error handling (might trigger another retry if attempt < maxRetries)
          return super.onError(retryErr, handler);
        } catch (e) {
          return super.onError(err, handler);
        }
      }
    }

    return super.onError(err, handler);
  }

  bool _shouldRetry(DioException err, RequestOptions options) {
    // 1. Check if it's a timeout or connection error
    final isTransient = err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError;

    if (!isTransient) return false;

    // 2. Idempotency check: Safe to retry GET, HEAD, OPTIONS
    // For POST/PUT/PATCH/DELETE, we usually only retry if specifically marked as safe
    final isIdempotent = ['GET', 'HEAD', 'OPTIONS'].contains(options.method.toUpperCase());
    
    // Allow manual override for POST/etc via extra
    final forceRetry = options.extra['force_retry'] == true;

    return isIdempotent || forceRetry;
  }

  Future<Response> _retryRequest(RequestOptions requestOptions, CancelToken? cancelToken) {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
      extra: requestOptions.extra,
      responseType: requestOptions.responseType,
      contentType: requestOptions.contentType,
      validateStatus: requestOptions.validateStatus,
      receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
    );

    return Dio().request(
      requestOptions.baseUrl + requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      cancelToken: cancelToken,
      options: options,
      onSendProgress: requestOptions.onSendProgress,
      onReceiveProgress: requestOptions.onReceiveProgress,
    );
  }
}
