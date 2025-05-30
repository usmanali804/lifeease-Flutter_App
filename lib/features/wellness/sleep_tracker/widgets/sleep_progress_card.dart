import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sleep_provider.dart';
import '../../utils/string_extensions.dart';

class SleepProgressCard extends StatelessWidget {
  const SleepProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SleepProvider>(
      builder: (context, provider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s Sleep',
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
                        icon: Icons.star,
                        label: 'Quality',
                        value: provider.formattedAverageQuality,
                        suffix: ' / 5',
                      ),
                    ),
                  ],
                ),
                if (provider.todayEntries.isNotEmpty) ...[
                  const SizedBox(height: 16.0),
                  const Divider(),
                  const SizedBox(height: 8.0),
                  Text(
                    'Sleep Tags',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8.0),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children:
                        provider.todayEntries
                            .expand((entry) => entry.tags)
                            .toSet()
                            .map((tag) => _SleepTagChip(tag: tag))
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
  final String? suffix;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: Theme.of(context).textTheme.titleMedium),
            if (suffix != null)
              Text(suffix!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _SleepTagChip extends StatelessWidget {
  final String tag;

  const _SleepTagChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(tag.capitalize()),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }
}
