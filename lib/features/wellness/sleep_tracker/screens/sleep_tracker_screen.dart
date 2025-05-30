import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/sleep_provider.dart';
import '../widgets/sleep_progress_card.dart';
import '../../utils/string_extensions.dart';

class SleepTrackerScreen extends StatefulWidget {
  const SleepTrackerScreen({super.key});

  @override
  State<SleepTrackerScreen> createState() => _SleepTrackerScreenState();
}

class _SleepTrackerScreenState extends State<SleepTrackerScreen> {
  final _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime _startTime = DateTime.now().subtract(const Duration(hours: 8));
  DateTime _endTime = DateTime.now();
  int _quality = 3;
  final List<String> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        Provider.of<SleepProvider>(context, listen: false).initialize();
      }
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _addSleepEntry() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    final note = _noteController.text.trim();

    try {
      await Provider.of<SleepProvider>(context, listen: false).addSleepEntry(
        startTime: _startTime,
        endTime: _endTime,
        quality: _quality,
        note: note.isNotEmpty ? note : null,
        tags: _selectedTags,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sleep entry recorded')));
        _noteController.clear();
        setState(() {
          _selectedTags.clear();
          _quality = 3;
          _startTime = DateTime.now().subtract(const Duration(hours: 8));
          _endTime = DateTime.now();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error recording sleep entry: $e')),
        );
      }
    }
  }

  Future<void> _selectDateTime(bool isStartTime) async {
    final DateTime initial = isStartTime ? _startTime : _endTime;
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (!mounted) return;

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initial),
      );

      if (!mounted) return;

      if (time != null) {
        setState(() {
          final newDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          if (isStartTime) {
            _startTime = newDateTime;
            if (_endTime.isBefore(_startTime)) {
              _endTime = _startTime.add(const Duration(hours: 8));
            }
          } else {
            _endTime = newDateTime;
            if (_startTime.isAfter(_endTime)) {
              _startTime = _endTime.subtract(const Duration(hours: 8));
            }
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sleep Tracker')),
      body: Consumer<SleepProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SleepProgressCard(),
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
                            'Add Sleep Entry',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16.0),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Start Time'),
                                    TextButton.icon(
                                      onPressed: () => _selectDateTime(true),
                                      icon: const Icon(Icons.access_time),
                                      label: Text(
                                        DateFormat.jm().format(_startTime),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('End Time'),
                                    TextButton.icon(
                                      onPressed: () => _selectDateTime(false),
                                      icon: const Icon(Icons.access_time),
                                      label: Text(
                                        DateFormat.jm().format(_endTime),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            'Sleep Quality',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              5,
                              (index) => IconButton(
                                icon: Icon(
                                  Icons.star,
                                  color:
                                      index < _quality
                                          ? Colors.amber
                                          : Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() => _quality = index + 1);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            'Sleep Tags',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8.0),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children:
                                SleepProvider.availableTags.map((tag) {
                                  final isSelected = _selectedTags.contains(
                                    tag,
                                  );
                                  return FilterChip(
                                    label: Text(tag.capitalize()),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setState(() {
                                        if (selected) {
                                          _selectedTags.add(tag);
                                        } else {
                                          _selectedTags.remove(tag);
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                          ),
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
                            onPressed: _addSleepEntry,
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
                          entry.qualityEmoji,
                          style: const TextStyle(fontSize: 24.0),
                        ),
                        title: Text(entry.formattedTimeRange),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${entry.formattedDuration} • Quality: ${entry.quality}/5',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            if (entry.tags.isNotEmpty)
                              Wrap(
                                spacing: 4.0,
                                runSpacing: 4.0,
                                children:
                                    entry.tags
                                        .map(
                                          (tag) => Chip(
                                            label: Text(
                                              tag.capitalize(),
                                              style: const TextStyle(
                                                fontSize: 12.0,
                                              ),
                                            ),
                                            padding: EdgeInsets.zero,
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                          ),
                                        )
                                        .toList(),
                              ),
                            if (entry.note?.isNotEmpty ?? false)
                              Text(entry.note!),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => provider.deleteSleepEntry(entry),
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
