import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Senior-level Connectivity Service
///
/// Features:
/// - Real-time connectivity monitoring
/// - Actual internet reachability check (not just network connection)
/// - Stream-based architecture for reactive updates
/// - Singleton pattern for global access
/// - Proper error handling and disposal
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();

  factory ConnectivityService() => _instance;

  ConnectivityService._internal() {
    // Configure InternetConnection with custom settings
    _internetConnection = InternetConnection.createInstance();
  }

  final Connectivity _connectivity = Connectivity();
  late final InternetConnection _internetConnection;

  StreamSubscription<InternetStatus>? _internetStatusSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();

  /// Stream to listen for connection status changes
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  bool? _hasConnection;
  bool _isInitialized = false;

  bool get hasConnection => _hasConnection ?? true;
  bool get isInitialized => _isInitialized;

  /// Initialize the connectivity service
  /// Should be called once during app initialization
  Future<void> initialize() async {
    // Check initial connection status
    _hasConnection = await checkConnection();

    if (kDebugMode) {
      print('🌐 ConnectivityService initialized - hasConnection: $_hasConnection');
    }

    // Mark as initialized BEFORE setting up listeners
    // This prevents stream events during initialization from triggering dialogs
    _isInitialized = true;

    // Small delay to ensure app is fully ready
    await Future.delayed(const Duration(milliseconds: 500));

    // Listen to internet status changes (more reliable than just network status)
    _internetStatusSubscription = _internetConnection.onStatusChange.listen(
          (InternetStatus status) {
        final isConnected = status == InternetStatus.connected;
        if (kDebugMode) {
          print('🌐 Internet status changed: $status (connected: $isConnected)');
        }
        _updateConnectionStatus(isConnected);
      },
      onError: (error) {
        if (kDebugMode) {
          print('🌐 Internet status error: $error');
        }
        _updateConnectionStatus(false);
      },
    );

    // Also listen to connectivity changes as a backup
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
          (List<ConnectivityResult> results) async {
        if (kDebugMode) {
          debugPrint('🌐 ConnectivityService: Interface changed: $results');
        }
        
        // Handle empty results or none as disconnected
        if (results.isEmpty || results.contains(ConnectivityResult.none)) {
          if (kDebugMode) {
            debugPrint('🌐 ConnectivityService: No network interfaces detected.');
          }
          _updateConnectionStatus(false);
        } else {
          // If network is connected, verify actual internet access
          final hasInternet = await checkConnection();
          _updateConnectionStatus(hasInternet);
        }
      },
      onError: (error) {
        if (kDebugMode) {
          debugPrint('🌐 ConnectivityService: Connectivity error: $error');
        }
        _updateConnectionStatus(false);
      },
    );
  }

  /// Check current connection status
  /// Returns true if device has actual internet access
  Future<bool> checkConnection() async {
    try {
      // First check network connectivity
      final List<ConnectivityResult> connectivityResults = await _connectivity.checkConnectivity();

      if (kDebugMode) {
        print('🌐 Checking connection - Network: $connectivityResults');
      }

      // If no network, return false immediately
      if (connectivityResults.contains(ConnectivityResult.none)) {
        if (kDebugMode) {
          print('🌐 No network connection');
        }
        return false;
      }

      // Network exists, now check actual internet access
      final bool hasInternet = await _internetConnection.hasInternetAccess;
      if (kDebugMode) {
        print('🌐 Network available, Internet access: $hasInternet');
      }
      return hasInternet;
    } catch (e) {
      if (kDebugMode) {
        print('🌐 Error checking connection: $e');
      }
      // On error, assume no connection
      return false;
    }
  }

  /// Explicitly re-verify connection and broadcast the result
  /// Useful for lifecycle events (resumed) or manual retries
  Future<void> refresh() async {
    if (kDebugMode) {
      print('🌐 ConnectivityService: Refreshing connection status...');
    }
    final isConnected = await checkConnection();
    _updateConnectionStatus(isConnected, forceBroadcast: true);
  }

  /// Update connection status and notify listeners
  void _updateConnectionStatus(bool isConnected, {bool forceBroadcast = false}) {
    // Only update and notify if service is initialized
    if (!_isInitialized) {
      if (kDebugMode) {
        print('🌐 Skipping status update - service not initialized yet');
      }
      return;
    }

    if (_hasConnection != isConnected || forceBroadcast) {
      _hasConnection = isConnected;
      if (kDebugMode) {
        print('🌐 Connection status updated: ${isConnected ? "✅ CONNECTED" : "❌ DISCONNECTED"} (forced: $forceBroadcast)');
      }
      _connectionStatusController.add(isConnected);
    }
  }

  /// Dispose resources
  /// Should be called when service is no longer needed
  Future<void> dispose() async {
    await _internetStatusSubscription?.cancel();
    await _connectivitySubscription?.cancel();
    await _connectionStatusController.close();
  }
}
