import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiCache {
  static final ApiCache _instance = ApiCache._internal();
  static ApiCache get instance => _instance;

  late SharedPreferences _prefs;
  final Duration _defaultCacheDuration = const Duration(minutes: 5);

  ApiCache._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> cacheResponse(
    String endpoint,
    dynamic data, {
    Map<String, dynamic>? params,
    Duration? duration,
  }) async {
    final key = _generateCacheKey(endpoint, params);
    final expiryTime = DateTime.now().add(duration ?? _defaultCacheDuration);
    final cacheData = {
      'data': data,
      'expiry': expiryTime.millisecondsSinceEpoch,
    };
    await _prefs.setString(key, jsonEncode(cacheData));
  }

  Future<dynamic> getCachedResponse(
    String endpoint, {
    Map<String, dynamic>? params,
  }) async {
    final key = _generateCacheKey(endpoint, params);
    final cachedString = _prefs.getString(key);
    if (cachedString == null) return null;

    final cacheData = jsonDecode(cachedString);
    final expiryTime = DateTime.fromMillisecondsSinceEpoch(cacheData['expiry']);

    if (DateTime.now().isAfter(expiryTime)) {
      await _prefs.remove(key);
      return null;
    }

    return cacheData['data'];
  }

  Future<void> clearCache() async {
    final keys = _prefs.getKeys().where((key) => key.startsWith('api_cache_'));
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }

  String _generateCacheKey(String endpoint, Map<String, dynamic>? params) {
    final key = 'api_cache_$endpoint';
    if (params != null && params.isNotEmpty) {
      return '${key}_${jsonEncode(params)}';
    }
    return key;
  }
}
