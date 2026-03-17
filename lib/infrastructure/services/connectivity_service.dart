import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'package:dio/dio.dart';

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

  /// Stream to listen for connection status changes (emits current status immediately)
  Stream<bool> get currentStatusStream {
    return Stream.multi((controller) {
      // Emit current status if available
      if (_hasConnection != null) {
        controller.add(_hasConnection!);
      }
      
      // Pipe subsequent changes
      final subscription = _connectionStatusController.stream.listen(
        (status) => controller.add(status),
        onError: (e) => controller.addError(e),
        onDone: () => controller.close(),
      );
      
      controller.onCancel = () => subscription.cancel();
    });
  }

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
    _isInitialized = true;

    // Small delay to ensure app is fully ready
    await Future.delayed(const Duration(milliseconds: 500));

    // Listen to internet status changes
    _internetStatusSubscription = _internetConnection.onStatusChange.listen(
          (InternetStatus status) {
        final isConnected = status == InternetStatus.connected;
        if (kDebugMode) {
          print('🌐 Internet status changed: $status (connected: $isConnected)');
        }
        _updateConnectionStatus(isConnected);
      },
      onError: (error) {
        _updateConnectionStatus(false);
      },
    );

    // Also listen to connectivity changes as a backup
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
          (List<ConnectivityResult> results) async {
        if (results.isEmpty || results.contains(ConnectivityResult.none)) {
          _updateConnectionStatus(false);
        } else {
          // If network is connected, verify actual internet access
          // Use checkConnection which now has retry logic
          final hasInternet = await checkConnection();
          _updateConnectionStatus(hasInternet);
        }
      },
    );
  }

  /// Check current connection status with retry logic
  /// Returns true if device has actual internet access
  Future<bool> checkConnection({int maxRetries = 2}) async {
    int attempt = 0;
    while (attempt < maxRetries) {
      try {
        final List<ConnectivityResult> connectivityResults = await _connectivity.checkConnectivity()
            .timeout(const Duration(seconds: 2));

        // If no network interfaces at all, we can't have internet
        if (connectivityResults.contains(ConnectivityResult.none) || connectivityResults.isEmpty) {
          if (attempt < maxRetries - 1) {
            attempt++;
            await Future.delayed(Duration(milliseconds: 400 * attempt));
            continue;
          }
          return false;
        }

        // Network exists, check actual internet access via library
        final bool hasInternet = await _internetConnection.hasInternetAccess
            .timeout(const Duration(seconds: 3));
        if (hasInternet) return true;
        
        // Fallback: Manual HTTP check
        final bool manualCheck = await _manualHttpCheck();
        if (manualCheck) return true;
        
        if (attempt < maxRetries - 1) {
          attempt++;
          await Future.delayed(Duration(milliseconds: 400 * attempt));
          continue;
        }
        return false;
      } catch (e) {
        if (attempt < maxRetries - 1) {
          attempt++;
          await Future.delayed(Duration(milliseconds: 400 * attempt));
          continue;
        }
        return false;
      }
    }
    return false;
  }

  /// Reliable manual HTTP check against well-known endpoints
  Future<bool> _manualHttpCheck() async {
    final endpoints = [
      'https://www.google.com',
      'https://1.1.1.1', // Cloudflare DNS (IP based is faster and avoids DNS issues)
    ];

    for (final url in endpoints) {
      try {
        // Use a fresh Dio instance with specified timeouts
        final dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
        ));
        
        final response = await dio.get(
          url,
          options: Options(
            headers: {
              'Cache-Control': 'no-cache',
            },
          ),
        );
        if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 400) {
          if (kDebugMode) print('🌐 Manual HTTP check success: $url');
          return true;
        }
      } catch (e) {
        if (kDebugMode) print('🌐 Manual HTTP check fail: $url - $e');
      }
    }
    return false;
  }

  /// Explicitly re-verify connection and broadcast the result
  Future<void> refresh() async {
    final isConnected = await checkConnection(maxRetries: 3);
    _updateConnectionStatus(isConnected, forceBroadcast: true);
  }

  /// Update connection status and notify listeners
  void _updateConnectionStatus(bool isConnected, {bool forceBroadcast = false}) {
    if (!_isInitialized) return;

    if (_hasConnection != isConnected || forceBroadcast) {
      _hasConnection = isConnected;
      if (kDebugMode) {
        print('🌐 Connection updated: ${isConnected ? "✅" : "❌"} (forced: $forceBroadcast)');
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
