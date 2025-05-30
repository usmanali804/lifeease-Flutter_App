import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/exercise_provider.dart';
import '../widgets/exercise_progress_card.dart';

class ExerciseTrackerScreen extends StatefulWidget {
  const ExerciseTrackerScreen({super.key});

  @override
  State<ExerciseTrackerScreen> createState() => _ExerciseTrackerScreenState();
}

class _ExerciseTrackerScreenState extends State<ExerciseTrackerScreen> {
  final _noteController = TextEditingController();
  final _distanceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedExerciseType;
  Duration _selectedDuration = const Duration(minutes: 30);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        Provider.of<ExerciseProvider>(context, listen: false).initialize();
      }
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  Future<void> _addExerciseEntry() async {
    if (!_formKey.currentState!.validate() || _selectedExerciseType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    final note = _noteController.text.trim();
    double? distance;
    if (_distanceController.text.isNotEmpty) {
      distance = double.tryParse(_distanceController.text);
    }

    try {
      await Provider.of<ExerciseProvider>(
        context,
        listen: false,
      ).addExerciseEntry(
        type: _selectedExerciseType!,
        duration: _selectedDuration,
        distance: distance,
        note: note.isNotEmpty ? note : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Exercise recorded')));
        _noteController.clear();
        _distanceController.clear();
        setState(() {
          _selectedExerciseType = null;
          _selectedDuration = const Duration(minutes: 30);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error recording exercise: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercise Tracker')),
      body: Consumer<ExerciseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const ExerciseProgressCard(),
                const SizedBox(height: 24.0),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Exercise',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16.0),
                          DropdownButtonFormField<String>(
                            value: _selectedExerciseType,
                            decoration: const InputDecoration(
                              labelText: 'Exercise Type',
                              border: OutlineInputBorder(),
                            ),
                            items:
                                ExerciseProvider.exerciseTypes.entries
                                    .map(
                                      (entry) => DropdownMenuItem(
                                        value: entry.key,
                                        child: Row(
                                          children: [
                                            Text(entry.value['icon'] as String),
                                            const SizedBox(width: 8.0),
                                            Text(entry.key.capitalize()),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              setState(() => _selectedExerciseType = value);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select an exercise type';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16.0),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Duration: ${_selectedDuration.inHours}h ${_selectedDuration.inMinutes.remainder(60)}m',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.timer),
                                onPressed: () async {
                                  final TimeOfDay? time = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay(
                                      hour: _selectedDuration.inHours,
                                      minute: _selectedDuration.inMinutes
                                          .remainder(60),
                                    ),
                                  );
                                  if (time != null) {
                                    setState(() {
                                      _selectedDuration = Duration(
                                        hours: time.hour,
                                        minutes: time.minute,
                                      );
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                          if (_selectedExerciseType != null &&
                              ExerciseProvider
                                      .exerciseTypes[_selectedExerciseType]!['supportsDistance']
                                  as bool) ...[
                            const SizedBox(height: 16.0),
                            TextFormField(
                              controller: _distanceController,
                              decoration: const InputDecoration(
                                labelText: 'Distance (km)',
                                border: OutlineInputBorder(),
                                suffixText: 'km',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  final distance = double.tryParse(value);
                                  if (distance == null || distance <= 0) {
                                    return 'Please enter a valid distance';
                                  }
                                }
                                return null;
                              },
                            ),
                          ],
                          const SizedBox(height: 16.0),
                          TextFormField(
                            controller: _noteController,
                            decoration: const InputDecoration(
                              labelText: 'Note (optional)',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 16.0),
                          ElevatedButton(
                            onPressed: _addExerciseEntry,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48.0),
                            ),
                            child: const Text('Add Entry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (provider.todayEntries.isNotEmpty) ...[
                  const SizedBox(height: 24.0),
                  Text(
                    'Today\'s Entries',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8.0),
                  ...provider.todayEntries.map(
                    (entry) => Card(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: ListTile(
                        leading: Text(
                          ExerciseProvider.exerciseTypes[entry.type]!['icon']
                              as String,
                          style: const TextStyle(fontSize: 24.0),
                        ),
                        title: Text(entry.type.capitalize()),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${entry.formattedDuration}${entry.formattedDistance.isNotEmpty ? ' • ${entry.formattedDistance}' : ''}${entry.formattedCalories.isNotEmpty ? ' • ${entry.formattedCalories}' : ''}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              DateFormat.jm().format(entry.date),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (entry.note?.isNotEmpty ?? false)
                              Text(entry.note!),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => provider.deleteExerciseEntry(entry),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
