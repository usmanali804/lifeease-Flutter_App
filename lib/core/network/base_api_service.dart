import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/environment_service.dart';
import '../config/api_config.dart';
import 'throttled_http_client.dart';
import 'rate_limiter.dart';
import 'api_cache.dart';

class BaseApiService {
  final ThrottledHttpClient _client;
  final RateLimiter _rateLimiter;
  final String _baseUrl;

  static final _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  BaseApiService()
    : _client = ThrottledHttpClient(),
      _rateLimiter = RateLimiter(),
      _baseUrl = ApiConfig.baseUrl;
  Future<Map<String, String>> _getHeaders() async {
    final headers = Map<String, String>.from(_defaultHeaders);
    final apiKey = await EnvironmentService.instance.getApiKey();
    if (apiKey != null) {
      headers['X-API-Key'] = apiKey;
    }
    return headers;
  }

  Future<T> _handleRequest<T>({
    required String endpoint,
    required Future<http.Response> Function() requestFunction,
    required T Function(Map<String, dynamic>) responseParser,
    Map<String, dynamic>? queryParams,
    Duration? cacheDuration,
  }) async {
    final cacheKey = '${endpoint}_${jsonEncode(queryParams)}';

    // Check rate limiting
    if (!_rateLimiter.shouldAllowRequest(endpoint)) {
      throw Exception('Rate limit exceeded for $endpoint');
    }

    // Try to get cached response
    final cachedData = await ApiCache.instance.getCachedResponse(cacheKey);
    if (cachedData != null) {
      return responseParser(cachedData);
    }

    try {
      final response = await requestFunction();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);

        // Cache the response if cacheDuration is provided
        if (cacheDuration != null) {
          await ApiCache.instance.cacheResponse(
            cacheKey,
            data,
            duration: cacheDuration,
          );
        }

        return responseParser(data);
      } else {
        throw _handleErrorResponse(response);
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<T> get<T>({
    required String endpoint,
    required T Function(Map<String, dynamic>) responseParser,
    Map<String, dynamic>? queryParams,
    Duration? cacheDuration,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/$endpoint',
    ).replace(queryParameters: queryParams);
    final headers = await _getHeaders();

    return _handleRequest(
      endpoint: endpoint,
      requestFunction: () => _client.get(uri, headers: headers),
      responseParser: responseParser,
      queryParams: queryParams,
      cacheDuration: cacheDuration,
    );
  }

  Future<T> post<T>({
    required String endpoint,
    required T Function(Map<String, dynamic>) responseParser,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParams,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/$endpoint',
    ).replace(queryParameters: queryParams);
    final headers = await _getHeaders();

    return _handleRequest(
      endpoint: endpoint,
      requestFunction:
          () => _client.post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          ),
      responseParser: responseParser,
    );
  }

  Future<T> put<T>({
    required String endpoint,
    required T Function(Map<String, dynamic>) responseParser,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParams,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/$endpoint',
    ).replace(queryParameters: queryParams);
    final headers = await _getHeaders();

    return _handleRequest(
      endpoint: endpoint,
      requestFunction:
          () => _client.put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          ),
      responseParser: responseParser,
    );
  }

  Future<void> delete({
    required String endpoint,
    Map<String, dynamic>? queryParams,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/$endpoint',
    ).replace(queryParameters: queryParams);
    final headers = await _getHeaders();

    if (!_rateLimiter.shouldAllowRequest(endpoint)) {
      throw Exception('Rate limit exceeded for $endpoint');
    }

    final response = await _client.delete(uri, headers: headers);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _handleErrorResponse(response);
    }
  }

  Exception _handleErrorResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      return Exception(body['message'] ?? 'Unknown error occurred');
    } catch (e) {
      return Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  Exception _handleError(dynamic error) {
    if (error is Exception) {
      return error;
    }
    return Exception('An unexpected error occurred: $error');
  }

  void dispose() {
    _client.close();
  }
}
