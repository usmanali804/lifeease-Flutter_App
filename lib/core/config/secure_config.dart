import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureConfig {
  static final SecureConfig _instance = SecureConfig._internal();
  static SecureConfig get instance => _instance;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  SecureConfig._internal();

  Future<void> setApiKey(String apiKey) async {
    await _secureStorage.write(key: 'api_key', value: apiKey);
  }

  Future<String?> getApiKey() async {
    return await _secureStorage.read(key: 'api_key');
  }

  Future<void> setEncryptionKey(String key) async {
    await _secureStorage.write(key: 'encryption_key', value: key);
  }

  Future<String?> getEncryptionKey() async {
    return await _secureStorage.read(key: 'encryption_key');
  }

  Future<void> clearSecureStorage() async {
    await _secureStorage.deleteAll();
  }
}
