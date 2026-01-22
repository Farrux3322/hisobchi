import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hisobchi/domain/common/data/user_data.dart';

import '../../common/network_provider.dart';

class AuthRepository {
  Future<Map<String, dynamic>> init({required String phone}) async {
    final response = await dio.post('/auth/verify-number', data: {'phone': phone});
    return response.data;
  }

  Future<Map<String, dynamic>> login({required String phone, required String password}) async {
    var a = await getDeviceInfo();
    final response = await dio.post(
      '/auth/login',
      data: {
        'phone': phone,
        'password': password,
        // 'device_name': a['device_name'],
        'device_token': 'qweqeewqewqeqweqwewq3424242424242eqweqweqqweqwewqwe12313123',
        // 'device_token': a['device_token'],
        'device_model': a['device_model'],
        'device_type': a['device_type'],
        'platform': a['platform'],
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> otp({required String phone}) async {
    final response = await dio.post('/auth/otp', data: {'phone': phone});
    return response.data;
  }

  Future<Map<String, dynamic>> otpResetPassword({required String phone, required String password, required String otp}) async {
    final response = await dio.post('/auth/reset-password', data: {'password': password, 'otp_code': otp, 'phone': phone});
    return response.data;
  }

  Future<Map<String, dynamic>> register({required String phone, required String password, required String otp, required String name}) async {
    var a = await getDeviceInfo();
    final response = await dio.post(
      '/auth/register',
      data: {
        'password': password,
        'otp_code': otp,
        'name': name,
        'phone': phone,
        // 'device_name': a['device_name'],
        // 'device_token': '24qwewe2wqeqaqwe3wq213414242weqwewqeqwewqewqesadasdada',
        'device_token': a['device_token'],
        'device_model': a['device_model'],
        'device_type': a['device_type'],
        'platform': a['platform'],
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getMe() async {
    final response = await dio.get('/auth/me');
    return response.data;
  }

  Future<Map<String, dynamic>> logOut() async {
    final response = await dio.get('/auth/logout');
    return response.data['data'];
  }

  Future<Map<String, dynamic>> getDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    String? deviceToken;

    // 🔐 Push ruxsat so‘rash
    try {
      NotificationSettings settings = await messaging.requestPermission();

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // 🔑 Firebase token olish (xatoliklarni oldini olish uchun try-catch va timeout bilan)
        deviceToken = await messaging.getToken().timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                debugPrint('Firebase token olish vaqti tugadi (AuthRepository)');
                return null;
              },
            );

        if (kDebugMode) {
          print('Device Token: $deviceToken');
        }
      } else {
        if (kDebugMode) {
          print('Push notificationga ruxsat berilmadi');
        }
      }
    } catch (e) {
      debugPrint('AuthRepository: Firebase token olishda xatolik: $e');
      // Xatolik bo'lsa ham login davom etishi kerak
    }

    try {
      if (Platform.isAndroid) {
        final android = await deviceInfoPlugin.androidInfo;

        return {
          "device_name": android.device, // masalan: sdk_gphone64
          "device_token": deviceToken,
          "device_type": "android",
          "device_model": android.model, // Pixel 6
          "platform": "android ${android.version.release}", // android 14
        };
      }

      if (Platform.isIOS) {
        final ios = await deviceInfoPlugin.iosInfo;

        return {
          "device_name": ios.name, // Farrux iPhone
          "device_token": deviceToken,
          "device_type": "ios",
          "device_model": ios.utsname.machine, // iPhone15,2
          "platform": "iOS ${ios.systemVersion}", // iOS 17.2
        };
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Device info olishda xato: $e');
      }
    }

    return {};
  }
}
