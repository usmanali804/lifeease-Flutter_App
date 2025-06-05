/// Service locator using GetIt for dependency injection
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/auth_service.dart';
import '../network/api_cache.dart';
import '../network/network_connectivity.dart';
import '../utils/database_encryption.dart';
import '../../features/task/data/repositories/task_repository.dart';
import '../../features/chat/data/repositories/chat_repository.dart';
import '../../services/connectivity_service.dart';
import '../../features/task/data/services/task_api_service.dart';

final GetIt serviceLocator = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Core Services
  final prefs = await SharedPreferences.getInstance();
  serviceLocator.registerSingleton<SharedPreferences>(prefs);
  serviceLocator.registerSingleton<ConnectivityService>(ConnectivityService());
  serviceLocator.registerSingleton<NetworkConnectivity>(
    NetworkConnectivity.instance,
  );
  serviceLocator.registerSingleton<ApiCache>(ApiCache.instance);
  serviceLocator.registerSingleton<DatabaseEncryption>(
    DatabaseEncryption.instance,
  );

  // Auth Service
  serviceLocator.registerSingleton<AuthService>(AuthService(prefs));

  // Task Service
  serviceLocator.registerSingleton<TaskApiService>(TaskApiService());

  // Repositories
  serviceLocator.registerSingleton<TaskRepository>(
    TaskRepository(serviceLocator<ConnectivityService>(), serviceLocator<TaskApiService>()),
  );
  serviceLocator.registerSingleton<ChatRepository>(
    ChatRepository(
      serviceLocator<ConnectivityService>(),
      serviceLocator<AuthService>(),
    ),
  );
}
