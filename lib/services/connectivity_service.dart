import 'package:connectivity_plus/connectivity_plus.dart';

/// A service that handles connectivity state and provides methods to check
/// and monitor internet connectivity status.
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  /// Checks if the device is currently online.
  /// Returns true if there is an active internet connection, false otherwise.
  Future<bool> isOnline() async {
    var result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// Returns a stream of connectivity changes.
  /// Can be used to monitor connectivity state changes in real-time.
  Stream<ConnectivityResult> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  /// Gets the current connectivity result.
  /// Useful for getting the specific type of connection (wifi, mobile, none, etc.)
  Future<ConnectivityResult> getCurrentConnectivity() async {
    return await _connectivity.checkConnectivity();
  }
} 