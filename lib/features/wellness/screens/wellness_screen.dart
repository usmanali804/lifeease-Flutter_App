import 'package:flutter/material.dart';
import '../mood_tracker/screens/mood_tracker_screen.dart';
import '../water_tracker/screens/water_tracker_screen.dart';
import '../exercise_tracker/screens/exercise_tracker_screen.dart';
import '../sleep_tracker/screens/sleep_tracker_screen.dart';

class WellnessScreen extends StatelessWidget {
  const WellnessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wellness')),
      body: GridView.count(
        padding: const EdgeInsets.all(16.0),
        crossAxisCount: 2,
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
        children: [
          _WellnessFeatureCard(
            title: 'Mood Tracker',
            icon: Icons.sentiment_satisfied_alt,
            color: Colors.blue,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MoodTrackerScreen(),
                  ),
                ),
          ),
          _WellnessFeatureCard(
            title: 'Water Tracker',
            icon: Icons.water_drop,
            color: Colors.lightBlue,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WaterTrackerScreen(),
                  ),
                ),
          ),
          _WellnessFeatureCard(
            title: 'Exercise',
            icon: Icons.fitness_center,
            color: Colors.green,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ExerciseTrackerScreen(),
                  ),
                ),
          ),
          _WellnessFeatureCard(
            title: 'Sleep',
            icon: Icons.bedtime,
            color: Colors.purple,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SleepTrackerScreen(),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

class _WellnessFeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _WellnessFeatureCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withAlpha((color.a * 0.7).round()), color],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48.0, color: Colors.white),
              const SizedBox(height: 16.0),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
