import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/message.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/auth/auth_service.dart';

class ChatApiService {
  final http.Client _client;
  final String _baseUrl;
  final AuthService _authService;

  ChatApiService({http.Client? client, required AuthService authService})
    : _client = client ?? http.Client(),
      _baseUrl = ApiConfig.baseUrl,
      _authService = authService;

  /// Get the authentication headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final headers = {'Content-Type': 'application/json'};

    final token = await _authService.getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// Send a message to the remote server
  Future<void> sendMessage(Message message) async {
    final headers = await _getAuthHeaders();

    final response = await _client.post(
      Uri.parse('$_baseUrl/messages'),
      headers: headers,
      body: jsonEncode({
        'text': message.text,
        'sender': message.sender,
        'timestamp': message.timestamp.toIso8601String(),
        'isSynced': message.isSynced,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to send message: ${response.body}');
    }
  }

  /// Get messages from the remote server
  Future<List<Message>> getMessages() async {
    final headers = await _getAuthHeaders();

    final response = await _client.get(
      Uri.parse('$_baseUrl/messages'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get messages: ${response.body}');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Message.fromJson(json)).toList();
  }

  void dispose() {
    _client.close();
  }
}
