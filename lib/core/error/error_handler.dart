import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import '../network/api_exceptions.dart';

class ErrorHandler {
  static String handleError(dynamic error) {
    if (error is ApiException) {
      return error.message;
    } else if (error is NetworkException) {
      return 'Network error occurred. Please check your connection.';
    } else if (error is AuthenticationException) {
      return 'Authentication failed. Please login again.';
    } else if (error is RateLimitException) {
      return 'Too many requests. Please try again in ${error.retryAfter.inMinutes} minutes.';
    } else if (error is ServerException) {
      return 'Server error occurred. Please try again later.';
    } else if (error is ValidationException) {
      if (error.errors != null && error.errors!.isNotEmpty) {
        return error.errors!.values.first.first;
      }
      return error.message;
    }

    // Log unexpected errors in debug mode
    if (kDebugMode) {
      print('Unexpected error: $error');
    }

    return 'An unexpected error occurred. Please try again.';
  }

  static bool shouldRetry(dynamic error) {
    return error is NetworkException ||
        error is ServerException ||
        (error is ApiException &&
            error.statusCode == 503); // Service unavailable
  }

  static Duration getRetryDelay(int retryCount) {
    // Exponential backoff with a maximum of 32 seconds
    final seconds = math.min(math.pow(2, retryCount).toInt(), 32);
    return Duration(seconds: seconds);
  }

  static Future<T> retryOperation<T>({
    required Future<T> Function() operation,
    int maxRetries = 3,
    Duration? initialDelay,
  }) async {
    int retryCount = 0;
    Duration delay = initialDelay ?? const Duration(seconds: 1);

    while (true) {
      try {
        return await operation();
      } catch (e) {
        if (!shouldRetry(e) || retryCount >= maxRetries) {
          rethrow;
        }

        retryCount++;
        await Future.delayed(delay);
        delay *= 2; // Exponential backoff
      }
    }
  }
}
