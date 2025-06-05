/// API endpoint configuration
class ApiEndpoints {
  static const String baseUrl = '/api';

  // Auth endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String refreshToken = '$baseUrl/auth/refresh';
  static const String logout = '$baseUrl/auth/logout';

  // User endpoints
  static const String userProfile = '$baseUrl/user/profile';
  static const String updateProfile = '$baseUrl/user/profile';
  static const String changePassword = '$baseUrl/user/password';

  // Task endpoints
  static const String tasks = '$baseUrl/tasks';
  static const String taskById = '$baseUrl/tasks/'; // Append task ID
  static const String taskCategories = '$baseUrl/tasks/categories';

  // Chat endpoints
  static const String messages = '$baseUrl/chat/messages';
  static const String conversations = '$baseUrl/chat/conversations';

  // Wellness endpoints
  static const String waterEntries = '$baseUrl/wellness/water';
  static const String moodEntries = '$baseUrl/wellness/mood';
  static const String sleepEntries = '$baseUrl/wellness/sleep';
  static const String exerciseEntries = '$baseUrl/wellness/exercise';

  // OCR endpoints
  static const String ocrScan = '$baseUrl/ocr/scan';
  static const String ocrHistory = '$baseUrl/ocr/history';

  // Settings endpoints
  static const String settings = '$baseUrl/settings';
  static const String notifications = '$baseUrl/settings/notifications';
  static const String language = '$baseUrl/settings/language';
}
