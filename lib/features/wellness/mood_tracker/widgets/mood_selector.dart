import 'package:flutter/material.dart';

class MoodSelector extends StatelessWidget {
  final String? selectedMood;
  final Function(String) onMoodSelected;
  final double iconSize;
  final double spacing;

  const MoodSelector({
    super.key,
    this.selectedMood,
    required this.onMoodSelected,
    this.iconSize = 40.0,
    this.spacing = 16.0,
  });

  static const Map<String, String> moods = {
    'happy': '😊',
    'neutral': '😐',
    'sad': '😢',
    'angry': '😠',
    'tired': '😴',
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          moods.entries.map((entry) {
            final isSelected = entry.key == selectedMood;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing / 2),
              child: GestureDetector(
                onTap: () => onMoodSelected(entry.key),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(12.0),
                    border:
                        isSelected
                            ? Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2.0,
                            )
                            : null,
                  ),
                  child: Text(
                    entry.value,
                    style: TextStyle(fontSize: iconSize),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}
