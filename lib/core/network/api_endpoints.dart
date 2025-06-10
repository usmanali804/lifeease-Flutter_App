/// API endpoint configuration
class ApiEndpoints {
  // ✅ Use this as the base URL for the API
  static const String baseUrl = "http://192.168.1.119:3000/api";

  // Auth endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String refreshToken = '$baseUrl/auth/refresh';
  static const String logout = '$baseUrl/auth/logout';

  // User endpoints
  static const String userProfile = '$baseUrl/users/profile';
  static const String updateProfile = '$baseUrl/users/profile';
  static const String changePassword = '$baseUrl/users/password';

  // Task endpoints
  static const String tasks = '$baseUrl/tasks';
  static const String taskById = '$baseUrl/tasks'; 
  static const String taskCategories = '$baseUrl/tasks/categories';

  // Chat endpoints
  static const String messages = '$baseUrl/messages';
  static const String conversations = '$baseUrl/messages';

  // Wellness endpoints
  static const String waterEntries = '$baseUrl/water-entries';

  // TODO: Implement these in the backend
  /*
  static const String ocrScan = '$baseUrl/ocr/scan';
  static const String ocrHistory = '$baseUrl/ocr/history';
  static const String settings = '$baseUrl/settings';
  static const String notifications = '$baseUrl/settings/notifications';
  static const String language = '$baseUrl/settings/language';
  */
}
