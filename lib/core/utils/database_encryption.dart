import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../config/secure_config.dart';

class DatabaseEncryption {
  static final DatabaseEncryption _instance = DatabaseEncryption._internal();
  static DatabaseEncryption get instance => _instance;

  DatabaseEncryption._internal();

  Future<HiveCipher?> getEncryptionCipher() async {
    final encryptionKey = await SecureConfig.instance.getEncryptionKey();
    if (encryptionKey != null) {
      final key = sha256.convert(utf8.encode(encryptionKey)).bytes;
      return HiveAesCipher(key.sublist(0, 32));
    }
    return null;
  }

  Future<Box<T>> openEncryptedBox<T>(String boxName) async {
    final cipher = await getEncryptionCipher();
    return await Hive.openBox<T>(boxName, encryptionCipher: cipher);
  }

  Future<void> generateNewEncryptionKey() async {
    final key = base64.encode(
      List<int>.generate(
        32,
        (i) => DateTime.now().microsecondsSinceEpoch % 256,
      ),
    );
    await SecureConfig.instance.setEncryptionKey(key);
  }
}
