import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AuthApiService {
  final http.Client _client;
  final String _baseUrl;

  AuthApiService({http.Client? client})
    : _client = client ?? http.Client(),
      _baseUrl = ApiConfig.baseUrl;

  /// Refresh the authentication token using a refresh token
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': refreshToken}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to refresh token: ${response.body}');
    }

    final data = jsonDecode(response.body);
    return {
      'token': data['access_token'] as String,
      'refresh_token': data['refresh_token'] as String,
      'expires_in': data['expires_in'] as int,
    };
  }

  /// Login with email and password
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to login: ${response.body}');
    }

    final data = jsonDecode(response.body);
    return {
      'token': data['access_token'] as String,
      'refresh_token': data['refresh_token'] as String,
      'expires_in': data['expires_in'] as int,
    };
  }

  /// Logout by invalidating the current token
  Future<void> logout(String token) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/auth/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to logout: ${response.body}');
    }
  }

  void dispose() {
    _client.close();
  }
}
