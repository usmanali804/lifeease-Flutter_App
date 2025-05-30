import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../../../../core/auth/auth_service.dart';
import '../models/user_model.dart';

class UserService {
  final http.Client _client;
  final String _baseUrl;
  final AuthService _authService;

  UserService({http.Client? client, required AuthService authService})
    : _client = client ?? http.Client(),
      _baseUrl = ApiConfig.baseUrl,
      _authService = authService;

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> register(String name, String email, String password) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  Future<User> getCurrentUser() async {
    final headers = await _getAuthHeaders();

    final response = await _client.get(
      Uri.parse('$_baseUrl/user/profile'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get user profile: ${response.body}');
    }

    return User.fromJson(jsonDecode(response.body));
  }

  Future<User> updateProfile({
    required String userId,
    String? name,
    String? email,
    String? profileImage,
  }) async {
    final headers = await _getAuthHeaders();

    final response = await _client.put(
      Uri.parse('$_baseUrl/user/profile'),
      headers: headers,
      body: jsonEncode({
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (profileImage != null) 'profileImage': profileImage,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update profile: ${response.body}');
    }

    return User.fromJson(jsonDecode(response.body));
  }

  void dispose() {
    _client.close();
  }
}
