import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class NetworkConnectivity {
  static final NetworkConnectivity _instance = NetworkConnectivity._internal();
  static NetworkConnectivity get instance => _instance;

  final _connectivity = Connectivity();
  final _controller = StreamController<ConnectivityResult>.broadcast();
  StreamSubscription<ConnectivityResult>? _subscription;

  NetworkConnectivity._internal() {
    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  Stream<ConnectivityResult> get onConnectivityChanged => _controller.stream;

  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<ConnectivityResult> checkConnectivity() {
    return _connectivity.checkConnectivity();
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    debugPrint('Network connectivity changed: $result');
    _controller.add(result);
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }

  bool isConnectionViable(ConnectivityResult result) {
    return result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet;
  }

  Future<bool> hasStableConnection() async {
    if (!await isConnected) return false;

    try {
      final result = await checkConnectivity();
      return isConnectionViable(result);
    } catch (e) {
      debugPrint('Error checking connection stability: $e');
      return false;
    }
  }
}
