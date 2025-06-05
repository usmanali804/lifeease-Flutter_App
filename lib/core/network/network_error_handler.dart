import 'package:flutter/material.dart';
import '../network/api_service.dart';
import '../utils/token_manager.dart';

class NetworkErrorHandler {
  static void handleError(BuildContext context, dynamic error) {
    String message = 'An unexpected error occurred';

    if (error is NetworkException) {
      message =
          'No internet connection. Please check your connection and try again.';
    } else if (error is TimeoutException) {
      message = 'Request timed out. Please try again.';
    } else if (error is UnauthorizedException) {
      message = 'Session expired. Please login again.';
      // Handle logout or token refresh
      _handleUnauthorized(context);
    } else if (error is BadRequestException) {
      message = error.message;
    } else if (error is ServerException) {
      message = 'Server error. Please try again later.';
    } else if (error is ForbiddenException) {
      message = 'You don\'t have permission to perform this action.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.error,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static void _handleUnauthorized(BuildContext context) async {
    // Clear token and navigate to login
    await TokenManager.clearToken();
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
}
