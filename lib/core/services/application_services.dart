import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/auth_service.dart';
import '../network/network_connectivity.dart';
import '../network/api_cache.dart';
import '../database/repository_factory.dart';
import '../utils/database_encryption.dart';

class ApplicationServices {
  static final ApplicationServices _instance = ApplicationServices._internal();
  static ApplicationServices get instance => _instance;

  late final AuthService authService;
  late final NetworkConnectivity networkConnectivity;
  late final ApiCache apiCache;
  late final RepositoryFactory repositoryFactory;
  late final DatabaseEncryption databaseEncryption;
  late final SharedPreferences sharedPreferences;

  bool _isInitialized = false;

  ApplicationServices._internal();

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize SharedPreferences
      sharedPreferences = await SharedPreferences.getInstance();

      // Initialize core services
      apiCache = ApiCache.instance;
      await apiCache.init();

      networkConnectivity = NetworkConnectivity.instance;
      databaseEncryption = DatabaseEncryption.instance;
      await databaseEncryption.generateNewEncryptionKey();

      repositoryFactory = RepositoryFactory.instance;
      final encryptionCipher = await databaseEncryption.getEncryptionCipher();
      if (encryptionCipher != null) {
        repositoryFactory.setEncryptionCipher(encryptionCipher);
      }

      // Initialize auth service
      authService = AuthService(sharedPreferences);

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing application services: $e');
      rethrow;
    }
  }

  void dispose() {
    networkConnectivity.dispose();
    repositoryFactory.closeAll();
  }

  bool get isInitialized => _isInitialized;
}
