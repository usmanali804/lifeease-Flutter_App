import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../domain/models/task.dart';
import '../../../../core/config/api_config.dart';

class TaskApiService {
  final http.Client _client;
  final String _baseUrl;

  TaskApiService({http.Client? client})
    : _client = client ?? http.Client(),
      _baseUrl = ApiConfig.baseUrl;

  Future<List<Task>> getAllTasks() async {
    final response = await _client.get(Uri.parse('$_baseUrl/tasks'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tasks: ${response.statusCode}');
    }
  }

  Future<Task> createTask(Task task) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/tasks'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(task.toJson()),
    );
    if (response.statusCode == 201) {
      return Task.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create task: ${response.statusCode}');
    }
  }

  Future<Task> updateTask(Task task) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/tasks/${task.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(task.toJson()),
    );
    if (response.statusCode == 200) {
      return Task.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update task: ${response.statusCode}');
    }
  }

  Future<void> deleteTask(String id) async {
    final response = await _client.delete(Uri.parse('$_baseUrl/tasks/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete task: ${response.statusCode}');
    }
  }

  void dispose() {
    _client.close();
  }
}
