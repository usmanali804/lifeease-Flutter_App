import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../mood_tracker/data/mood_repository.dart';
import '../mood_tracker/providers/mood_provider.dart';
import '../water_tracker/data/water_repository.dart';
import '../water_tracker/providers/water_provider.dart';
import '../exercise_tracker/data/exercise_repository.dart';
import '../exercise_tracker/providers/exercise_provider.dart';
import '../sleep_tracker/data/sleep_repository.dart';
import '../sleep_tracker/providers/sleep_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/auth/auth_service.dart';

class WellnessProviders extends StatelessWidget {
  final Widget child;

  const WellnessProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        final prefs = snapshot.data!;
        final authService = AuthService(prefs);

        return MultiProvider(
          providers: [
            // Auth service
            Provider<AuthService>(create: (_) => authService),

            // Mood tracking
            Provider<MoodRepository>(create: (_) => MoodRepository()..init()),
            ChangeNotifierProvider<MoodProvider>(
              create: (context) => MoodProvider(context.read<MoodRepository>()),
            ),

            // Water tracking
            Provider<WaterRepository>(
              create:
                  (context) =>
                      WaterRepository(context.read<AuthService>())..init(),
            ),
            ChangeNotifierProvider<WaterProvider>(
              create:
                  (context) => WaterProvider(context.read<WaterRepository>()),
            ),

            // Exercise tracking
            Provider<ExerciseRepository>(
              create: (_) => ExerciseRepository(prefs),
            ),
            ChangeNotifierProvider<ExerciseProvider>(
              create:
                  (context) =>
                      ExerciseProvider(context.read<ExerciseRepository>()),
            ),

            // Sleep tracking
            Provider<SleepRepository>(create: (_) => SleepRepository(prefs)),
            ChangeNotifierProvider<SleepProvider>(
              create:
                  (context) => SleepProvider(context.read<SleepRepository>()),
            ),
          ],
          child: child,
        );
      },
    );
  }
}
