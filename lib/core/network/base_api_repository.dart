import 'package:dio/dio.dart';
import '../network/api_service.dart';
import '../models/base_model.dart';

abstract class BaseApiRepository<T extends BaseModel> {
  final ApiService _apiService;
  final String endpoint;

  BaseApiRepository(this.endpoint) : _apiService = ApiService.instance;

  Future<List<T>> getAll([Map<String, dynamic>? queryParams]) async {
    try {
      final response = await _apiService.get(
        endpoint,
        queryParameters: queryParams,
      );
      return (response.data as List).map((item) => fromJson(item)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<T> getById(String id) async {
    try {
      final response = await _apiService.get('$endpoint/$id');
      return fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<T> create(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post(endpoint, data: data);
      return fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<T> update(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('$endpoint/$id', data: data);
      return fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      await _apiService.delete('$endpoint/$id');
    } catch (e) {
      rethrow;
    }
  }

  /// Convert JSON to model object - to be implemented by subclasses
  T fromJson(Map<String, dynamic> json);
}
