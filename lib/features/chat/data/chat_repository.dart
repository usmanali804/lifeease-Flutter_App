import 'package:hive/hive.dart';
import '../domain/message.dart';

class ChatRepository {
  static const String _boxName = 'messages';
  late Box<Message> _messageBox;
  final List<Message> _messages = [];

  List<Message> get messages => List.unmodifiable(_messages);

  Future<void> init() async {
    _messageBox = await Hive.openBox<Message>(_boxName);
    await loadMessages();
  }

  Future<void> loadMessages() async {
    _messages.clear();
    _messages.addAll(_messageBox.values.toList());
    _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  Future<void> addMessage(Message message) async {
    await _messageBox.add(message);
    _messages.add(message);
    _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  Future<void> syncMessages() async {
    final unsyncedMessages = _messages.where((m) => !m.isSynced).toList();

    for (final message in unsyncedMessages) {
      try {
        // Here you would typically make an API call to sync the message
        // For now, we'll just simulate successful sync
        await Future.delayed(const Duration(milliseconds: 300));
        message.isSynced = true;
        message.syncError = null;
        await message.save();
      } catch (e) {
        message.syncError = e.toString();
        await message.save();
        rethrow;
      }
    }
  }

  Future<void> retryMessage(Message message) async {
    if (message.isSynced) return;

    try {
      // Here you would typically make an API call to sync the message
      // For now, we'll just simulate successful sync
      await Future.delayed(const Duration(milliseconds: 300));
      message.isSynced = true;
      message.syncError = null;
      await message.save();
    } catch (e) {
      message.syncError = e.toString();
      await message.save();
      rethrow;
    }
  }

  Future<void> clearMessages() async {
    await _messageBox.clear();
    _messages.clear();
  }

  Future<void> close() async {
    await _messageBox.close();
  }
}
