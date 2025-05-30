import 'package:hive/hive.dart';
import '../../domain/message.dart';
import '../../../../services/connectivity_service.dart';
import '../services/chat_api_service.dart';
import '../../../../core/auth/auth_service.dart';
import '../../../../core/database/base_repository.dart';

class ChatRepository extends BaseRepository<Message> {
  final ConnectivityService _connectivityService;
  final ChatApiService _apiService;
  static const String _boxName = 'messages';

  ChatRepository(this._connectivityService, AuthService authService)
    : _apiService = ChatApiService(authService: authService),
      super(_boxName);

  /// Initialize the repository
  @override
  Future<void> init({HiveCipher? encryptionCipher}) async {
    await super.init(encryptionCipher: encryptionCipher);
  }

  /// Get all messages (local first)
  Future<List<Message>> getAllMessages() async {
    final messages = box.values.toList();
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return messages;
  }

  /// Add a new message
  Future<Message> addMessage(Message message) async {
    final isOnline = await _connectivityService.isOnline();
    message.isSynced = isOnline;
    await super.add(message);

    if (isOnline) {
      try {
        await _apiService.sendMessage(message);
        message.isSynced = true;
        message.syncError = null;
        await message.save();
      } catch (e) {
        message.isSynced = false;
        message.syncError = e.toString();
        await message.save();
      }
    }
    return message;
  }

  /// Sync all unsynced messages
  Future<void> syncMessages() async {
    final isOnline = await _connectivityService.isOnline();
    if (!isOnline) return;

    final unsynced = box.values.where((m) => !m.isSynced).toList();
    for (final message in unsynced) {
      try {
        await _apiService.sendMessage(message);
        message.isSynced = true;
        message.syncError = null;
        await message.save();
      } catch (e) {
        message.syncError = e.toString();
        await message.save();
      }
    }
  }

  /// Get unsynced messages
  List<Message> getUnsyncedMessages() {
    return box.values.where((m) => !m.isSynced).toList();
  }

  /// Clear all messages (for testing/demo)
  Future<void> clearAll() async {
    await super.clear();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
