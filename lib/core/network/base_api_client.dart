import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../network/api_service.dart'
    hide
        ApiException,
        NetworkException,
        TimeoutException,
        BadRequestException,
        UnauthorizedException,
        ForbiddenException,
        NotFoundException,
        ServerException,
        UnknownException;
import '../network/api_endpoints.dart';
import '../exceptions/api_exceptions.dart';

abstract class BaseApiClient {
  @protected
  final ApiService apiService;

  BaseApiClient() : apiService = ApiService.instance;

  /// Handle API responses with proper error handling
  Future<T> handleResponse<T>(
    Future<Response> Function() apiCall,
    T Function(dynamic data) onSuccess,
  ) async {
    try {
      final response = await apiCall();
      return onSuccess(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownException('An unexpected error occurred');
    }
  }

  /// Convert API error to appropriate exception
  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException('Connection timed out');
      case DioExceptionType.badResponse:
        return _handleHttpError(
          error.response?.statusCode,
          error.response?.data?['message'],
        );
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return NetworkException('No internet connection');
        }
        return UnknownException('An unexpected error occurred');
      default:
        return UnknownException('An unexpected error occurred');
    }
  }

  /// Convert HTTP status code to appropriate exception
  Exception _handleHttpError(int? statusCode, String? message) {
    switch (statusCode) {
      case 400:
        return BadRequestException(message ?? 'Invalid request');
      case 401:
        return UnauthorizedException(message ?? 'Unauthorized');
      case 403:
        return ForbiddenException(message ?? 'Access denied');
      case 404:
        return NotFoundException(message ?? 'Resource not found');
      case 500:
        return ServerException(message ?? 'Server error');
      default:
        return UnknownException(message ?? 'An unexpected error occurred');
    }
  }

  /// Handle paginated responses
  Future<PaginatedResponse<T>> handlePaginatedResponse<T>(
    Future<Response> Function() apiCall,
    T Function(dynamic item) itemBuilder,
  ) async {
    try {
      final response = await apiCall();
      final data = response.data;

      return PaginatedResponse(
        items:
            (data['items'] as List).map((item) => itemBuilder(item)).toList(),
        total: data['total'],
        page: data['page'],
        limit: data['limit'],
        hasMore: data['hasMore'],
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownException('An unexpected error occurred');
    }
  }
}

/// Model for paginated responses
class PaginatedResponse<T> {
  final List<T> items;
  final int total;
  final int page;
  final int limit;
  final bool hasMore;

  PaginatedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.hasMore,
  });
}
