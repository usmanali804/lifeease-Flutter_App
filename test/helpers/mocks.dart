import 'package:mockito/annotations.dart';
import 'package:life_ease/core/auth/auth_service.dart';
import 'package:life_ease/features/task/domain/task_service.dart';
import 'package:life_ease/features/chat/domain/chat_service.dart';
import 'package:life_ease/features/wellness/water_tracker/domain/water_tracking_service.dart';

@GenerateMocks([AuthService, TaskService, ChatService, WaterTrackingService])
void main() {}
