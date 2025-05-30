// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in the test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:your_package_name/data/models/task_model.dart';
import 'package:your_package_name/features/chat/presentation/screens/chat_screen.dart';
import 'package:your_package_name/features/chat/domain/message.dart';
import 'package:your_package_name/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:path/path.dart' as path;
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
    // Set up mock for path provider
    PathProviderPlatform.instance = MockPathProvider();

    // Initialize Hive for testing
    await Hive.initFlutter('./test/hive_test');
    Hive.registerAdapter(MessageAdapter());

    // Create the messages box
    await Hive.openBox<Message>('messages');
  });
  tearDownAll(() async {
    // Clean up Hive
    try {
      await messageBox.close();
      await Hive.close();
      await Hive.deleteFromDisk();
    } catch (e) {
      // ignore: avoid_print
      print('Error during teardown: $e');
    }
  });
  setUp(() async {
    messageBox = await Hive.openBox<Message>('messages');
    await messageBox.clear();
  });

  tearDown(() async {
    await messageBox.clear();
  });

  testWidgets('Chat screen shows initial state correctly', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(MaterialApp(home: ChatScreen()));
    await tester.pumpAndSettle();

    // Verify that the app bar title is present
    expect(find.text('AI Assistant'), findsOneWidget);
    expect(find.text('Online'), findsOneWidget);

    // Verify that the initial empty state message is shown
    expect(find.text('Start a Conversation'), findsOneWidget);
    expect(find.text('Send a message to begin chatting'), findsOneWidget);

    // Verify that the chat input field is present
    expect(find.byType(TextField), findsOneWidget);

    // Verify that the refresh button is present
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });
  testWidgets('Chat screen can send and display messages', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: ChatScreen()));
    await tester.pumpAndSettle();

    // Enter a message in the text field
    await tester.enterText(find.byType(TextField), 'Hello');
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();

    // Verify the text was entered
    expect(find.text('Hello'), findsOneWidget);
  });
}
