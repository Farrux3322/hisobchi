import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import '../../infrastructure/services/connectivity_service.dart';
import '../assets/theme/app_theme.dart';

class ConnectivityBanner extends StatefulWidget {
  const ConnectivityBanner({super.key});

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isVisible = false;
  Timer? _debounceTimer;
  bool _isSupressed = true;

  @override
  void initState() {
    super.initState();
    
    // Initial suppression to avoid noise during heavy startup initialization
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _isSupressed = false);
        _updateVisibility(!_connectivityService.hasConnection);
      }
    });

    _connectivityService.currentStatusStream.listen((hasConnection) {
      if (mounted && !_isSupressed) {
        _updateVisibility(!hasConnection);
      }
    });
  }

  void _updateVisibility(bool show) {
    if (show) {
      // If we want to show, wait a bit to ensure it's not a flicker
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 2000), () {
        if (mounted) {
          setState(() => _isVisible = true);
        }
      });
    } else {
      // If internet is back, hide immediately for best UX
      _debounceTimer?.cancel();
      if (mounted) {
        setState(() => _isVisible = false);
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
      height: _isVisible ? MediaQuery.of(context).padding.top + 45.h : 0,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.colors.red,
        boxShadow: _isVisible
            ? [
                BoxShadow(
                  color: AppTheme.colors.red.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: ClipRect(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              Gap(MediaQuery.of(context).padding.top),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wifi_off_rounded,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                    Gap(10.w),
                    Text(
                      "Internet aloqasi yo'q",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
