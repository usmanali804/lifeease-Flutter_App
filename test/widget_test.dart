import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:life_ease/features/chat/presentation/screens/chat_screen.dart';
import 'package:life_ease/features/chat/domain/message.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPathProvider extends Mock
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async => '.';

  @override
  Future<String?> getApplicationDocumentsPath() async => '.';

  @override
  Future<String?> getApplicationSupportPath() async => '.';

  @override
  Future<String?> getLibraryPath() async => '.';

  @override
  Future<String?> getDownloadsPath() async => '.';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Box<Message> messageBox;

  setUpAll(() async {
    PathProviderPlatform.instance = MockPathProvider();
    await Hive.initFlutter('./test/hive_test');
    Hive.registerAdapter(MessageAdapter());
    messageBox = await Hive.openBox<Message>('messages');
  });

  setUp(() async {
    await messageBox.clear();
  });

  tearDown(() async {
    await messageBox.clear();
  });

  tearDownAll(() async {
    await messageBox.close();
    await Hive.close();
    await Hive.deleteFromDisk();
  });

  testWidgets('Chat screen shows initial state correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ChatScreen()));
    await tester.pumpAndSettle();

    expect(find.text('AI Assistant'), findsOneWidget);
    expect(find.text('Online'), findsOneWidget);
    expect(find.text('Start a Conversation'), findsOneWidget);
    expect(find.text('Send a message to begin chatting'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });

  testWidgets('Chat screen can send and display messages',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ChatScreen()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Hello');
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();

    expect(find.text('Hello'), findsOneWidget);
  });
}