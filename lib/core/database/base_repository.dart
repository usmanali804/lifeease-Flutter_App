import 'package:hive/hive.dart';

abstract class BaseRepository<T> {
  final String boxName;
  late Box<T> _box;

  BaseRepository(this.boxName);

  Future<void> init({HiveCipher? encryptionCipher}) async {
    if (!Hive.isBoxOpen(boxName)) {
      _box = await Hive.openBox<T>(boxName, encryptionCipher: encryptionCipher);
    } else {
      _box = Hive.box<T>(boxName);
    }
  }

  Box<T> get box => _box;

  Future<void> add(T item) => _box.add(item);

  Future<void> put(dynamic key, T item) => _box.put(key, item);

  T? get(dynamic key) => _box.get(key);

  List<T> getAll() => _box.values.toList();

  Future<void> delete(dynamic key) => _box.delete(key);

  Future<void> clear() => _box.clear();

  Future<void> close() => _box.close();

  bool get isOpen => _box.isOpen;

  void dispose() {
    if (_box.isOpen) {
      _box.close();
    }
  }
}
