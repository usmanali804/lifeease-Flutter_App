import 'package:hive/hive.dart';
import 'base_repository.dart';
import '../../features/task/data/repositories/task_repository.dart';
import '../../features/chat/data/repositories/chat_repository.dart';
import '../../features/wellness/mood_tracker/data/mood_repository.dart';
import '../../features/wellness/water_tracker/data/water_repository.dart';

class RepositoryFactory {
  static final RepositoryFactory _instance = RepositoryFactory._internal();
  static RepositoryFactory get instance => _instance;

  final Map<Type, BaseRepository> _repositories = {};
  HiveCipher? _encryptionCipher;

  RepositoryFactory._internal();

  void setEncryptionCipher(HiveCipher cipher) {
    _encryptionCipher = cipher;
  }

  Future<T> getRepository<T extends BaseRepository>(
    T Function() createRepository,
  ) async {
    if (_repositories.containsKey(T)) {
      return _repositories[T] as T;
    }

    final repository = createRepository();
    await repository.init(encryptionCipher: _encryptionCipher);
    _repositories[T] = repository;
    return repository;
  }

  Future<void> closeAll() async {
    for (final repository in _repositories.values) {
      if (repository.isOpen) {
        await repository.close();
      }
    }
    _repositories.clear();
  }
}
