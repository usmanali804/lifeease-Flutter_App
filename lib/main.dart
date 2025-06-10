import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/network/api_cache.dart';
import 'core/utils/database_encryption.dart';
import 'core/theme/app_theme.dart';
import 'core/config/environment.dart';
import 'core/config/environment_service.dart';
import 'features/settings/providers/theme_provider.dart';
import 'features/settings/providers/notification_settings_provider.dart';
import 'core/auth/auth_service.dart';
import 'core/auth/auth_wrapper.dart';
import 'core/services/home_stats_provider.dart';

import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/signup_screen.dart';
import 'features/auth/data/providers/auth_provider.dart';
import 'features/auth/data/services/user_service.dart';
import 'features/task/presentation/screens/task_list_screen.dart';
import 'features/task/task_scheduler_screen.dart';
import 'features/chat/presentation/screens/chat_screen.dart';
import 'features/wellness/wellness_screen.dart';
import 'features/ocr/presentation/screens/ocr_screen.dart';
import 'features/multilingual_support/language_settings_screen.dart';
import 'features/notifications/notifications_screen.dart';
import 'features/auth/profile_screen.dart';
import 'features/settings/settings_screen.dart';

import 'features/task/data/repositories/task_repository.dart';
import 'features/task/data/services/task_service.dart';
import 'features/task/data/services/task_api_service.dart';
import 'features/task/domain/models/task.dart';
import 'features/wellness/mood_tracker/data/mood_repository.dart';
import 'features/wellness/mood_tracker/providers/mood_provider.dart';
import 'features/wellness/mood_tracker/screens/mood_tracker_screen.dart';
import 'features/wellness/mood_tracker/data/mood_entry_model.dart';
import 'features/chat/data/repositories/chat_repository.dart';
import 'features/chat/domain/message.dart';
import 'features/wellness/water_tracker/models/water_entry.dart';
import 'features/wellness/water_tracker/data/water_repository.dart';
import 'features/multilingual_support/presentation/language_selector.dart';
import 'features/chat/data/services/chat_api_service.dart';
import 'services/connectivity_service.dart';

import 'home_page.dart'; // Import HomePage
import 'core/database/repository_factory.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Fallback values if .env file is not available
    dotenv.env['ENVIRONMENT'] = 'development';
    dotenv.env['API_URL'] = 'http://localhost:3000/api';
  }

  // Initialize environment configuration
  EnvironmentConfig.init();
  await EnvironmentService.instance.init();

  // Initialize API cache
  await ApiCache.instance.init();

  // Initialize Database Encryption
  await DatabaseEncryption.instance.generateNewEncryptionKey();
  // Initialize Hive with encryption
  await Hive.initFlutter();
  final encryptionCipher =
      await DatabaseEncryption.instance.getEncryptionCipher();

  // Set encryption cipher in repository factory if available
  if (encryptionCipher != null) {
    RepositoryFactory.instance.setEncryptionCipher(encryptionCipher);
  }

  // Register Hive adaptersif not already registered
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(TaskAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(MessageAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(MoodEntryAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(WaterEntryAdapter());
  }

  // Initialize core services
  final prefs = await SharedPreferences.getInstance();
  final connectivityService = ConnectivityService();
  final authService = AuthService(prefs);
  final userService = UserService(authService: authService);
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
        Provider<ConnectivityService>.value(value: connectivityService),
        ChangeNotifierProvider(
          create:
              (_) => AuthProvider(
                authService: authService,
                userService: userService,
              ),
        ),
        ChangeNotifierProvider(create: (_) => HomeStatsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
        ChangeNotifierProvider(
          create: (_) => NotificationSettingsProvider(prefs),
        ),
      ],
      child: EasyLocalization(
        supportedLocales: const [
          Locale('en'),
          Locale('ur'),
          Locale('hi'),
          Locale('ar'),
        ],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeEase',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomePage(),
        '/task': (context) => const TaskSchedulerScreen(),
        '/chat': (context) => const ChatScreen(),
        '/wellness': (context) => const WellnessScreen(),
        '/ocr': (context) => const OCRScreen(),
        '/languages': (context) => const LanguageSettingsScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const TaskListScreen(),
      const ChatScreen(),
      const OCRScreen(),
      const MoodTrackerScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LifeEase'),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: LanguageSelector(),
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.task), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.chat), label: 'Chat'),
          NavigationDestination(
            icon: Icon(Icons.document_scanner),
            label: 'OCR',
          ),
          NavigationDestination(icon: Icon(Icons.mood), label: 'Mood'),
        ],
      ),
    );
  }
}
