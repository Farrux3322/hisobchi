import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hisobchi/application/app_manager/app_manager_cubit.dart';
import 'package:hisobchi/infrastructure/services/shared_service.dart';
import 'package:hisobchi/presentation/routes/coordinator.dart';
import 'package:hisobchi/presentation/routes/index_routes.dart';
import 'package:hisobchi/application/subscription/subscription_status_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/common/data/user_data.dart';
import 'dio_exception.dart';

class DioInterceptor extends Interceptor {
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
      AppManagerCubit.context!.go(Routes.signIn.path);
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
    if (statusHeader != null && AppManagerCubit.context != null) {
      // print('-------------------------------');
      // print('Subscription Status: $statusHeader');
      // print('-------------------------------');
      AppManagerCubit.context!.read<SubscriptionStatusCubit>().updateStatusFromServer(statusHeader);
    }
  }

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    options.headers.addAll({
      if (UserData.token.isNotEmpty) HttpHeaders.authorizationHeader: 'Bearer ${UserData.token}',
      "device_type": Platform.isIOS ? "IOS" : "Android",
      // "device-info": jsonEncode(UserData.deviceInfo),
    });
    return super.onRequest(options, handler);
  }
}
