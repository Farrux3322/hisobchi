import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ehisob/presentation/components/no_internet_dialog.dart';
import 'package:ehisob/presentation/routes/coordinator.dart';

import '../../infrastructure/services/connectivity_service.dart';

/// Features:
/// - Listens to connectivity changes globally
/// - Shows NoInternetDialog when connection is lost
/// - Auto-dismisses when connection restores
/// - Proper cleanup on disposal
class ConnectivityListener extends StatefulWidget {
  final Widget child;

  const ConnectivityListener({super.key, required this.child});

  @override
  State<ConnectivityListener> createState() => _ConnectivityListenerState();
}

class _ConnectivityListenerState extends State<ConnectivityListener> with WidgetsBindingObserver {
  final ConnectivityService _connectivityService = ConnectivityService();
  StreamSubscription<bool>? _connectivitySubscription;
  bool _hasShownDialog = false;
  bool _initialCheckCompleted = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _listenToConnectivity();
    _checkInitialConnection();
  }

  // Tracking grace period after resume to prevent false positives
  DateTime? _lastResumeTime;
  bool get _isWithinGracePeriod {
    if (_lastResumeTime == null) return false;
    return DateTime.now().difference(_lastResumeTime!) < const Duration(seconds: 3);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('🌐 ConnectivityListener: App resumed, triggering refresh and starting grace period.');
      _lastResumeTime = DateTime.now();
      _connectivityService.refresh();
    } else if (state == AppLifecycleState.paused) {
      debugPrint('🌐 ConnectivityListener: App paused, cancelling pending timers.');
      _debounceTimer?.cancel();
      _debounceTimer = null;
    }
  }

  Future<void> _checkInitialConnection() async {
    // Wait for service to initialize if it hasn't already
    int retryCount = 0;
    while (!_connectivityService.isInitialized && retryCount < 10) {
      await Future.delayed(const Duration(milliseconds: 200));
      retryCount++;
    }

    if (!mounted) return;

    if (!_connectivityService.isInitialized) {
      debugPrint('🌐 ConnectivityListener: Service failed to initialize after 2 seconds.');
      return;
    }

    final hasConnection = _connectivityService.hasConnection;
    debugPrint('🌐 ConnectivityListener: Initial state check - hasConnection: $hasConnection');
    _initialCheckCompleted = true;

    if (!hasConnection && !_hasShownDialog) {
      _startConnectionTimer();
    }
  }

  void _listenToConnectivity() {
    _connectivitySubscription =
        _connectivityService.currentStatusStream.listen((hasConnection) {
      debugPrint('🌐 ConnectivityListener: Status broadcast received - hasConnection: $hasConnection');
      if (!mounted) return;

      if (!_connectivityService.isInitialized || !_initialCheckCompleted) {
        debugPrint('🌐 ConnectivityListener: Ignoring event (initializing...)');
        return;
      }

      if (!hasConnection) {
        if (!_hasShownDialog && _debounceTimer == null) {
          debugPrint('🌐 ConnectivityListener: Connection lost, starting 1.5s timer.');
          _startConnectionTimer();
        }
      } else {
        debugPrint('🌐 ConnectivityListener: Connection restored, resetting state.');
        _debounceTimer?.cancel();
        _debounceTimer = null;
        _hasShownDialog = false;
      }
    });
  }

  void _startConnectionTimer() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 1510), () {
      if (!mounted) return;
      
      // If we are within the 3s grace period after resume, don't show the dialog yet.
      // But we will schedule a follow-up check to ensure we don't miss a real disconnection.
      if (_isWithinGracePeriod) {
        debugPrint('🌐 ConnectivityListener: Suppressing dialog trigger - within post-resume grace period. Scheduling follow-up.');
        _debounceTimer = Timer(const Duration(seconds: 2), _startConnectionTimer);
        return;
      }

      if (!_connectivityService.hasConnection && !_hasShownDialog) {
        debugPrint('🌐 ConnectivityListener: Timer expired, showing dialog.');
        _hasShownDialog = true;
        _showNoInternetDialog();
      }
      _debounceTimer = null;
    });
  }

  void _showNoInternetDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final navigatorContext = parentKey.currentContext;
      if (navigatorContext != null) {
        NoInternetDialog.show(navigatorContext);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
