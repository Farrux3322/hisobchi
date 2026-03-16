import 'package:flutter/material.dart';
import '../../domain/common/data/user_data.dart';

extension PermissionX on BuildContext {
  /// Checks if the current user has the specified permission.
  /// 
  /// If [UserData.isWorkerMode] is false (Owner mode), it always returns `true`.
  /// If it's `true`, it checks if [UserData.activePermissions] contains the [key].
  bool hasPermission(String key) {
    if (!UserData.isWorkerMode) return true;
    return UserData.activePermissions.contains(key);
  }
}
