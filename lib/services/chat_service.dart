import '../data/models/message_model.dart';

abstract class ChatService {
  Future<List<Message>> getMessages();
  Future<Message> sendMessage(String text);
  Future<bool> markMessageAsRead(String messageId);
  Future<List<Message>> getUnreadMessages();
}
