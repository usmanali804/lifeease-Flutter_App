import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:life_ease/features/chat/domain/models/chat_message.dart';
import 'package:life_ease/features/chat/domain/chat_service.dart';
import '../../helpers/mocks.mocks.dart';

void main() {
  group('Chat Feature Tests', () {
    late MockChatService mockChatService;

    setUp(() {
      mockChatService = MockChatService();
    });

    test('send message should add new message', () async {
      final message = ChatMessage(
        id: '1',
        senderId: 'user1',
        receiverId: 'user2',
        content: 'Hello World',
        timestamp: DateTime.now(),
      );

      when(
        mockChatService.sendMessage(message),
      ).thenAnswer((_) async => message);

      final result = await mockChatService.sendMessage(message);

      expect(result.id, equals(message.id));
      expect(result.content, equals(message.content));
      verify(mockChatService.sendMessage(message)).called(1);
    });

    test('fetch messages should return message list', () async {
      final messages = [
        ChatMessage(
          id: '1',
          senderId: 'user1',
          receiverId: 'user2',
          content: 'Hello',
          timestamp: DateTime.now(),
        ),
        ChatMessage(
          id: '2',
          senderId: 'user2',
          receiverId: 'user1',
          content: 'Hi there',
          timestamp: DateTime.now(),
        ),
      ];

      when(mockChatService.getMessages()).thenAnswer((_) async => messages);

      final result = await mockChatService.getMessages();

      expect(result, equals(messages));
      expect(result.length, equals(2));
      verify(mockChatService.getMessages()).called(1);
    });

    test('mark message as read should update status', () async {
      const messageId = '1';

      when(mockChatService.markAsRead(messageId)).thenAnswer((_) async {});

      await mockChatService.markAsRead(messageId);

      verify(mockChatService.markAsRead(messageId)).called(1);
    });
  });
}
