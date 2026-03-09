import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:hisobchi/infrastructure/services/shared_service.dart';
import 'package:hisobchi/presentation/routes/coordinator.dart';
import 'package:hisobchi/presentation/routes/index_routes.dart';
import 'package:hisobchi/application/subscription/subscription_status_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../domain/common/data/user_data.dart';
import 'dio_exception.dart';

class DioInterceptor extends Interceptor {
  static const String _secretKey = "YTJTM1A3Il01fU91VVgjR1czI2soSyU3WU8wRDlRaw==";
  static final String _secretMd5 = md5.convert(utf8.encode(_secretKey)).toString();

  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    final checkUnauthorized = !err.requestOptions.headers.containsKey('check_token');
    if (err.response?.statusCode == 401) {
      final pref = await SharedPrefService.initialize();
      UserData.token = '';
      UserData.name = '';
      UserData.phone = '';
      pref.setName('');
      pref.setToken('');
      pref.setPhone('');
      setPasscodeVerified(false);
      parentKey.currentContext?.go(Routes.signIn.path);
    }
    return handler.reject(
      DioExceptionX(
        requestOptions: err.requestOptions,
        response: err.response,
        message: err.message,
        error: err.error,
        statusCode: err.response?.statusCode,
        serverError: err.response?.data ?? {},
        errorType: err.type,
        checkUnauthorized: checkUnauthorized,
      ),
    );
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _updateSubscriptionStatus(response);
    super.onResponse(response, handler);
  }

  void _updateSubscriptionStatus(Response response) {
    final statusHeader = response.headers.value('X-Subscription-Status');
    if (statusHeader != null && parentKey.currentContext != null) {
      // parentKey.currentContext!.read<SubscriptionStatusCubit>().updateStatusFromServer('ACTIVE');
      parentKey.currentContext!.read<SubscriptionStatusCubit>().updateStatusFromServer(statusHeader);
    }
  }

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final uniquePublicKey = _generatePublicKey();
    final uniqueRequestId = _generateRequestId(uniquePublicKey);

    options.headers.addAll({if (UserData.token.isNotEmpty) HttpHeaders.authorizationHeader: 'Bearer ${UserData.token}', "device_type": Platform.isIOS ? "IOS" : "Android"});

    // HAR BIR SO'ROV UCHUN UNIQUE HEADERS
    options.headers.addAll({"x-ehisob-request-id": uniqueRequestId, "x-ehisob-request-key": uniquePublicKey});

    return super.onRequest(options, handler);
  }

  String _generatePublicKey() {
    final uuid = Uuid();

    String id = uuid.v4();

    return md5.convert(utf8.encode(id)).toString();
  }

  /// Public key asosida unique request ID yaratish
  String _generateRequestId(String publicKey) {
    return md5.convert(utf8.encode("$_secretMd5+$publicKey")).toString();
  }
}
