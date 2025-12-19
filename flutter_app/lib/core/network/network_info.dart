/// =============================================================================
/// Network Information
/// =============================================================================
///
/// Provides network connectivity status information.
/// Used by the sync service to determine when to sync.
/// =============================================================================
library;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for network info singleton.
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfo(Connectivity());
});

/// Stream provider for connectivity changes.
final connectivityStreamProvider = StreamProvider<bool>((ref) {
  final networkInfo = ref.watch(networkInfoProvider);
  return networkInfo.onConnectivityChanged;
});

/// Provides information about network connectivity.
class NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfo(this._connectivity);

  /// Check if the device is currently connected to the internet.
  ///
  /// Returns true if connected via WiFi, mobile data, or ethernet.
  /// Returns false if offline.
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return _isConnected(results);
  }

  /// Stream of connectivity status changes.
  ///
  /// Emits true when connected, false when disconnected.
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged
        .map((results) => _isConnected(results));
  }

  /// Get the current connection type as a string.
  Future<String> get connectionType async {
    final results = await _connectivity.checkConnectivity();
    return _connectionTypeString(results);
  }

  /// Check if connected based on connectivity result.
  bool _isConnected(List<ConnectivityResult> result) {
    // Check if any connection type is available
    return result.any((r) =>
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.ethernet);
  }

  /// Convert connectivity result to human-readable string.
  String _connectionTypeString(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.wifi)) return 'WiFi';
    if (results.contains(ConnectivityResult.mobile)) return 'Mobile';
    if (results.contains(ConnectivityResult.ethernet)) return 'Ethernet';
    if (results.contains(ConnectivityResult.vpn)) return 'VPN';
    return 'None';
  }
}
