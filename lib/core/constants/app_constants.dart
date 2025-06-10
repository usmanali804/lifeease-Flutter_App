/// This file contains all the constants used throughout the app
class AppConstants {
  // API Constants
  static const String baseUrl = 'http://192.168.1.110:3000/api';
  static const int apiTimeout = 30000; // 30 seconds

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';

  // Feature Flags
  static const bool enableVoiceControl = true;
  static const bool enableDarkMode = true;
  static const bool enableNotifications = true;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
}
