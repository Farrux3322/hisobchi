import 'package:flutter/material.dart';

import '../../infrastructure/services/connectivity_service.dart';
import '../assets/asset_index.dart';

/// Senior-level No Internet Dialog
///
/// Features:
/// - Beautiful, modern UI design
/// - Retry functionality with loading state
/// - Auto-dismiss on connection restore
/// - Prevents multiple dialogs
/// - Proper disposal and memory management
class NoInternetDialog extends StatefulWidget {
  const NoInternetDialog({super.key});

  @override
  State<NoInternetDialog> createState() => _NoInternetDialogState();

  /// Show the dialog (prevents multiple instances)
  static Future<void> show(BuildContext context) async {
    // Prevent showing multiple dialogs
    if (_isShowing) return;
    _isShowing = true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const NoInternetDialog(),
    ).then((_) {
      _isShowing = false;
    });
  }

  static bool _isShowing = false;
}

class _NoInternetDialogState extends State<NoInternetDialog> {
  bool _isRetrying = false;
  final ConnectivityService _connectivityService = ConnectivityService();

  @override
  void initState() {
    super.initState();
    _listenToConnectivity();
  }

  void _listenToConnectivity() {
    // Auto-dismiss when connection is restored
    _connectivityService.connectionStatusStream.listen((hasConnection) {
      if (hasConnection && mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  Future<void> _retry() async {
    setState(() => _isRetrying = true);

    // Check connection
    final hasConnection = await _connectivityService.checkConnection();

    if (!mounted) return;

    if (hasConnection) {
      // Connection restored, close dialog
      Navigator.of(context).pop();
    } else {
      // Still no connection
      setState(() => _isRetrying = false);

      // Show feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Internet aloqasi hali ham yo'q"),
          backgroundColor: AppTheme.colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          margin: EdgeInsets.all(16.w),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent back button dismiss
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        backgroundColor: AppTheme.colors.background,
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppTheme.colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.wifi_off_rounded,
                  size: 48.sp,
                  color: AppTheme.colors.red,
                ),
              ),
              Gap(24.h),

              // Title
              Text(
                "Internet aloqasi yo'q",
                style: AppTheme.data.textTheme.titleLarge?.copyWith(
                  color: AppTheme.colors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Gap(12.h),

              // Description
              Text(
                "Iltimos, internet aloqangizni tekshiring va qayta urinib ko'ring",
                style: AppTheme.data.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.colors.black,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              Gap(32.h),

              // Retry button
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: _isRetrying ? null : _retry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.colors.primary,
                    disabledBackgroundColor:
                        AppTheme.colors.primary.withValues(alpha: 0.5),
                    foregroundColor: AppTheme.colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: _isRetrying
                      ? SizedBox(
                          height: 20.h,
                          width: 20.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.colors.white,
                            ),
                          ),
                        )
                      : Text(
                          "Qayta urinish",
                          style: AppTheme.data.textTheme.titleMedium?.copyWith(
                            color: AppTheme.colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}