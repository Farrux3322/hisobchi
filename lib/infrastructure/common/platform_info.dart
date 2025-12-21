import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class PlatformInfo {
  static bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;
  static bool get isDebugMode => kDebugMode;
  static bool isConnected = false;
  static String appVersion = '';

  static Future<void> init() async {
    final packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;
  }
}
