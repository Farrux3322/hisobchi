import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:oktoast/oktoast.dart';

class Toast {
  Toast._();

  // Barcha toastlar uchun umumiy davomiylik
  static const _toastDuration = Duration(seconds: 2);

  // Success uchun toast
  static void showSuccessToast({String? message, Duration? duration}) {
    showToastWidget(
      _buildToastWidget(
        message: message ?? 'toast.success'.tr(),
        backgroundColor: CupertinoColors.activeGreen,
        icon: CupertinoIcons.check_mark_circled,
      ),
      duration: duration ?? _toastDuration,
      position: ToastPosition.top,
    );
  }

  // Error uchun toast
  static void showErrorToast({String? message, Duration? duration}) {
    showToastWidget(
      _buildToastWidget(
        message: message ?? 'toast.error'.tr(),
        backgroundColor: CupertinoColors.systemRed,
        icon: CupertinoIcons.clear_circled,
      ),
      duration: duration ?? _toastDuration,
      position: ToastPosition.top,
    );
  }

  // Info uchun toast
  static void showInfoToast({String? message, Duration? duration}) {
    showToastWidget(
      _buildToastWidget(
        message: message ?? 'toast.info'.tr(),
        backgroundColor: CupertinoColors.activeBlue,
        icon: CupertinoIcons.info,
      ),
      duration: duration ?? _toastDuration,
      position: ToastPosition.top,
    );
  }

  // Warning uchun toast
  static void showWarningToast({String? message, Duration? duration}) {
    showToastWidget(
      _buildToastWidget(
        message: message ?? 'toast.warning'.tr(),
        backgroundColor: CupertinoColors.systemYellow,
        icon: CupertinoIcons.exclamationmark_triangle,
      ),
      duration: duration ?? _toastDuration,
      position: ToastPosition.top,
    );
  }

  // Toast uchun umumiy widget
  static Widget _buildToastWidget({
    required String message,
    required Color backgroundColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: CupertinoColors.white),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              message,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: CupertinoColors.white),
            ),
          ),
        ],
      ),
    );
  }
}
