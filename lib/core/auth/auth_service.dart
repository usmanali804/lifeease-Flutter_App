import 'package:shared_preferences/shared_preferences.dart';
import 'auth_api_service.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';

  final SharedPreferences _prefs;
  final AuthApiService _apiService;
  String? _cachedToken;
  String? _cachedRefreshToken;
  DateTime? _tokenExpiry;

  AuthService(this._prefs) : _apiService = AuthApiService() {
    _loadToken();
  }

  /// Get the current authentication token
  /// Returns null if no token is available or if the token has expired
  Future<String?> getToken() async {
    if (_cachedToken != null && _tokenExpiry != null) {
      // Check if token is expired (with 5 minute buffer)
      if (_tokenExpiry!.isAfter(
        DateTime.now().add(const Duration(minutes: 5)),
      )) {
        return _cachedToken;
      }

      // Token is expired, try to refresh
      try {
        await refreshToken();
        return _cachedToken;
      } catch (e) {
        // If refresh fails, clear the token
        await clearToken();
        return null;
      }
    }
    return null;
  }

  /// Set the authentication token and its expiry
  Future<void> setToken(
    String token,
    String refreshToken,
    DateTime expiry,
  ) async {
    _cachedToken = token;
    _cachedRefreshToken = refreshToken;
    _tokenExpiry = expiry;

    await _prefs.setString(_tokenKey, token);
    await _prefs.setString(_refreshTokenKey, refreshToken);
    await _prefs.setString(_tokenExpiryKey, expiry.toIso8601String());
  }

  /// Clear the authentication token
  Future<void> clearToken() async {
    _cachedToken = null;
    _cachedRefreshToken = null;
    _tokenExpiry = null;

    await _prefs.remove(_tokenKey);
    await _prefs.remove(_refreshTokenKey);
    await _prefs.remove(_tokenExpiryKey);
  }

  /// Load the token from persistent storage
  void _loadToken() {
    _cachedToken = _prefs.getString(_tokenKey);
    _cachedRefreshToken = _prefs.getString(_refreshTokenKey);
    final expiryStr = _prefs.getString(_tokenExpiryKey);
    if (expiryStr != null) {
      _tokenExpiry = DateTime.parse(expiryStr);
    }
  }

  /// Refresh the authentication token using the refresh token
  Future<void> refreshToken() async {
    if (_cachedRefreshToken == null) {
      throw Exception('No refresh token available');
    }

    try {
      final result = await _apiService.refreshToken(_cachedRefreshToken!);

      // Calculate new expiry time (expires_in is in seconds)
      final expiry = DateTime.now().add(
        Duration(seconds: result['expires_in'] as int),
      );

      // Update tokens
      await setToken(
        result['token'] as String,
        result['refresh_token'] as String,
        expiry,
      );
    } catch (e) {
      // If refresh fails, clear tokens and rethrow
      await clearToken();
      rethrow;
    }
  }

  /// Login with email and password
  Future<void> login(String email, String password) async {
    final result = await _apiService.login(email, password);

    // Calculate expiry time (expires_in is in seconds)
    final expiry = DateTime.now().add(
      Duration(seconds: result['expires_in'] as int),
    );

    // Store tokens
    await setToken(
      result['token'] as String,
      result['refresh_token'] as String,
      expiry,
    );
  }

  /// Logout and invalidate the current token
  Future<void> logout() async {
    final token = await getToken();
    if (token != null) {
      try {
        await _apiService.logout(token);
      } finally {
        await clearToken();
      }
    }
  }

  /// Check if the user is currently authenticated
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }

  void dispose() {
    _apiService.dispose();
  }
}
