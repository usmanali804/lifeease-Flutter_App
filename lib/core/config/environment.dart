import 'dart:io' show Platform;

/// Represents the different environments the app can run in
enum Environment { development, staging, production }

/// Configuration class that holds environment-specific settings
class EnvironmentConfig {
  static Environment _environment = Environment.development;
  static String _apiBaseUrl = '';

  /// Initialize the environment configuration
  static void init({Environment? environment}) {
    // Try to get environment from build configuration first
    const envString = String.fromEnvironment('ENVIRONMENT', defaultValue: '');
    if (envString.isNotEmpty) {
      _environment = _parseEnvironment(envString);
    } else {
      // Fall back to environment variable
      final envVar = Platform.environment['LIFEEASE_ENV'];
      if (envVar != null) {
        _environment = _parseEnvironment(envVar);
      } else {
        // Use provided environment or default to development
        _environment = environment ?? Environment.development;
      }
    }
    _apiBaseUrl = _getApiBaseUrl();
  }

  /// Parse environment string to Environment enum
  static Environment _parseEnvironment(String env) {
    switch (env.toLowerCase()) {
      case 'prod':
      case 'production':
        return Environment.production;
      case 'staging':
        return Environment.staging;
      case 'dev':
      case 'development':
      default:
        return Environment.development;
    }
  }

  /// Get the current environment
  static Environment get environment => _environment;

  /// Get the API base URL for the current environment
  static String get apiBaseUrl => _apiBaseUrl;

  /// Get the appropriate API base URL based on the environment
  static String _getApiBaseUrl() {
    switch (_environment) {
      case Environment.development:
        return 'http://localhost:3000/api';
      case Environment.staging:
        return 'https://staging-api.lifeease.app/v1';
      case Environment.production:
        return 'https://api.lifeease.app/v1';
    }
  }
}
