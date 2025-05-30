import 'environment.dart';

class ApiConfig {
  /// Get the base URL for API calls based on the current environment
  static String get baseUrl => EnvironmentConfig.apiBaseUrl;
}
