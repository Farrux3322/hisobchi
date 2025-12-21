import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hisobchi/application/app_manager/app_manager_cubit.dart';
import 'package:hisobchi/infrastructure/services/shared_service.dart';
import 'package:hisobchi/presentation/routes/index_routes.dart';

import '../../domain/common/data/user_data.dart';
import 'dio_exception.dart';

class DioInterceptor extends Interceptor {
  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    final checkUnauthorized = !err.requestOptions.headers.containsKey('check_token');
    if (err.response?.statusCode == 401) {
      UserData.token = "";
      var pref = await SharedPrefService.initialize();
      pref.clear();
      AppManagerCubit.context!.go(Routes.signIn.path);
    }
    // else if (err.response?.statusCode == 310) {
    //   EasyLoading.showError(err.response!.data['error']['message'].toString(), duration: const Duration(seconds: 2));
    //   // Future.delayed(const Duration(seconds: 3), () {
    //   //   locationBloc.value = true;
    //   // });
    // }
    //
    // // else {
    // //   EasyLoading.showError(err.toString(), duration: const Duration(seconds: 5));
    // // }
    return handler.reject(
      DioExceptionX(requestOptions: err.requestOptions, statusCode: err.response?.statusCode, serverError: err.response?.data ?? {}, errorType: err.type, checkUnauthorized: checkUnauthorized),
    );
  }

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    options.headers.addAll({
      if (UserData.token.isNotEmpty) HttpHeaders.authorizationHeader: 'Bearer ${UserData.token}',
      "device_type": Platform.isIOS ? "IOS" : "Android",
      "device-info": jsonEncode(UserData.deviceInfo),
      // if (latLong != null) 'LatLang': '${latLong.latitude}, ${latLong.longitude}',
    });
    return super.onRequest(options, handler);
  }

  // Future<void> getDeviceInfo() async {
  //   final deviceInfoPlugin = DeviceInfoPlugin();
  //   FirebaseMessaging messaging = FirebaseMessaging.instance;
  //
  //   NotificationSettings settings = await messaging.requestPermission();
  //   String? token;
  //
  //   if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  //     token = Platform.isIOS ? await messaging.getAPNSToken() : await messaging.getToken();
  //
  //     if (kDebugMode) {
  //       print('Device Token: $token');
  //     }
  //   } else {
  //     if (kDebugMode) {
  //       print('Push notificationga ruxsat berilmadi');
  //     }
  //   }
  //
  //   var deviceData = <String, dynamic>{};
  //
  //   Map<String, dynamic> readAndroidBuildData(AndroidDeviceInfo build) {
  //     return <String, dynamic>{'device_system': 'android', 'model': build.model, 'device_id': build.id, 'device_token': token, 'is_physical_device': build.isPhysicalDevice};
  //   }
  //
  //   Map<String, dynamic> readIosDeviceInfo(IosDeviceInfo data) {
  //     return <String, dynamic>{'device_system': data.systemName, 'model': data.model, 'device_id': data.identifierForVendor, 'device_token': token, 'is_physical_device': data.isPhysicalDevice};
  //   }
  //
  //   try {
  //     deviceData = switch (defaultTargetPlatform) {
  //       TargetPlatform.android => readAndroidBuildData(await deviceInfoPlugin.androidInfo),
  //       TargetPlatform.iOS => readIosDeviceInfo(await deviceInfoPlugin.iosInfo),
  //       TargetPlatform.fuchsia => throw UnimplementedError(),
  //       TargetPlatform.linux => throw UnimplementedError(),
  //       TargetPlatform.macOS => throw UnimplementedError(),
  //       TargetPlatform.windows => throw UnimplementedError(),
  //     };
  //   } on PlatformException {
  //     deviceData = <String, dynamic>{'Error:': 'Failed to get platform version.'};
  //   }
  //
  //   UserData.deviceInfo = deviceData;
  // }
}
