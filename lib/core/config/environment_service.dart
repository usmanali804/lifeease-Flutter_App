import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class EnvironmentService {
  static final EnvironmentService _instance = EnvironmentService._internal();
  static EnvironmentService get instance => _instance;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _apiKeyKey = 'API_KEY';

  EnvironmentService._internal();

  Future<void> init() async {
    await dotenv.load(fileName: '.env');

    // Store API key securely
    final apiKey = dotenv.env['API_KEY'];
    if (apiKey != null) {
      await _secureStorage.write(key: _apiKeyKey, value: apiKey);
    }
  }

  Future<String?> getApiKey() async {
    try {
      return await _secureStorage.read(key: _apiKeyKey);
    } catch (e) {
      debugPrint('Error reading API key: $e');
      return null;
    }
  }

  bool get isDevelopment =>
      dotenv.env['ENVIRONMENT']?.toLowerCase() == 'development';
  bool get isProduction =>
      dotenv.env['ENVIRONMENT']?.toLowerCase() == 'production';
  bool get isStaging => dotenv.env['ENVIRONMENT']?.toLowerCase() == 'staging';
}
