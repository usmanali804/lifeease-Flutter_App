import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../../core/config/api_config.dart';
import '../../../../../core/auth/auth_service.dart';
import '../../models/water_entry.dart';

class WaterApiService {
  final http.Client _client;
  final String _baseUrl;
  final AuthService _authService;

  WaterApiService({http.Client? client, required AuthService authService})
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

  /// Sync a water entry with the backend
  Future<WaterEntry> syncEntry(WaterEntry entry) async {
    final headers = await _getAuthHeaders();

    final response = await _client.post(
      Uri.parse('$_baseUrl/water-entries'),
      headers: headers,
      body: jsonEncode(entry.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to sync water entry: ${response.body}');
    }

    final data = jsonDecode(response.body);
    return WaterEntry.fromJson(data);
  }

  /// Get all water entries from the backend
  Future<List<WaterEntry>> getAllEntries() async {
    final headers = await _getAuthHeaders();

    final response = await _client.get(
      Uri.parse('$_baseUrl/water-entries'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get water entries: ${response.body}');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => WaterEntry.fromJson(json)).toList();
  }

  /// Update a water entry on the backend
  Future<WaterEntry> updateEntry(WaterEntry entry) async {
    final headers = await _getAuthHeaders();

    final response = await _client.put(
      Uri.parse('$_baseUrl/water-entries/${entry.id}'),
      headers: headers,
      body: jsonEncode(entry.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update water entry: ${response.body}');
    }

    final data = jsonDecode(response.body);
    return WaterEntry.fromJson(data);
  }

  /// Delete a water entry from the backend
  Future<void> deleteEntry(String id) async {
    final headers = await _getAuthHeaders();

    final response = await _client.delete(
      Uri.parse('$_baseUrl/water-entries/$id'),
      headers: headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete water entry: ${response.body}');
    }
  }

  void dispose() {
    _client.close();
  }
}
