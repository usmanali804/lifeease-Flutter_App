import 'models/chat_message.dart';

abstract class ChatService {
  Future<List<ChatMessage>> getMessages();
  Future<ChatMessage> sendMessage(ChatMessage message);
  Future<void> deleteMessage(String messageId);
  Stream<ChatMessage> onNewMessage();
  Future<void> markAsRead(String messageId);
}
