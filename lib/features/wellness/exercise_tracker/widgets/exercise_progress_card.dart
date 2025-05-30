import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exercise_provider.dart';

class ExerciseProgressCard extends StatelessWidget {
  const ExerciseProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExerciseProvider>(
      builder: (context, provider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s Exercise',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: _StatItem(
                        icon: Icons.timer,
                        label: 'Duration',
                        value: provider.formattedTotalDuration,
                      ),
                    ),
                    Expanded(
                      child: _StatItem(
                        icon: Icons.local_fire_department,
                        label: 'Calories',
                        value: provider.formattedTotalCalories,
                      ),
                    ),
                    if (provider.todayTotalDistance > 0)
                      Expanded(
                        child: _StatItem(
                          icon: Icons.route,
                          label: 'Distance',
                          value: provider.formattedTotalDistance,
                        ),
                      ),
                  ],
                ),
                if (provider.todayEntries.isNotEmpty) ...[
                  const SizedBox(height: 16.0),
                  const Divider(),
                  const SizedBox(height: 8.0),
                  Text(
                    'Exercise Types',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8.0),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children:
                        provider.todayEntries
                            .map(
                              (entry) => _ExerciseTypeChip(
                                type: entry.type,
                                icon:
                                    ExerciseProvider.exerciseTypes[entry
                                            .type]!['icon']
                                        as String,
                              ),
                            )
                            .toSet()
                            .toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4.0),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _ExerciseTypeChip extends StatelessWidget {
  final String type;
  final String icon;

  const _ExerciseTypeChip({required this.type, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Text(icon),
      label: Text(type.capitalize()),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
