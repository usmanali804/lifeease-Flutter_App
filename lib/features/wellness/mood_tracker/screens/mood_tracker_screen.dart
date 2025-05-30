import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/mood_provider.dart';
import '../widgets/mood_selector.dart';
import '../data/mood_entry_model.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  final _noteController = TextEditingController();
  String? _selectedMood;

  @override
  void initState() {
    super.initState();
    // Initialize the provider when the screen is first created
    Future.microtask(() {
      if (mounted) {
        Provider.of<MoodProvider>(context, listen: false).initialize();
      }
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveMood() async {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a mood')));
      return;
    }

    try {
      await Provider.of<MoodProvider>(
        context,
        listen: false,
      ).saveMoodEntry(_selectedMood!, note: _noteController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mood saved successfully')),
        );
        _noteController.clear();
        setState(() => _selectedMood = null);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving mood: $e')));
      }
    }
  }

  void _retryEntry(MoodEntry entry) {
    Provider.of<MoodProvider>(context, listen: false).retryEntry(entry);
  }

  Future<void> _refreshMoodHistory() async {
    try {
      await Provider.of<MoodProvider>(context, listen: false).initialize();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to refresh: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracker'),
        actions: [
          Consumer<MoodProvider>(
            builder: (context, provider, child) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: Row(
                    children: [
                      Icon(
                        provider.isOnline ? Icons.cloud_done : Icons.cloud_off,
                        size: 16,
                        color: provider.isOnline ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        provider.isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          fontSize: 14,
                          color: provider.isOnline ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<MoodProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.clearError(),
                    child: const Text('Dismiss'),
                  ),
                ],
              ),
            );
          }

          final todayMood = provider.todayMood;

          return RefreshIndicator(
            onRefresh: _refreshMoodHistory,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (todayMood != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Today's Mood",
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                if (!todayMood.isSynced)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.sync_problem,
                                        size: 16,
                                        color: Colors.orange,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        todayMood.syncError ?? 'Saving...',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.orange,
                                        ),
                                      ),
                                      if (todayMood.syncError != null) ...[
                                        const SizedBox(width: 4),
                                        GestureDetector(
                                          onTap: () => _retryEntry(todayMood),
                                          child: const Icon(
                                            Icons.refresh,
                                            size: 16,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                              children: [
                                Text(
                                  MoodSelector.moods[todayMood.mood]!,
                                  style: const TextStyle(fontSize: 32.0),
                                ),
                                const SizedBox(width: 16.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat.jm().format(todayMood.date),
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                      ),
                                      if (todayMood.note?.isNotEmpty ??
                                          false) ...[
                                        const SizedBox(height: 4.0),
                                        Text(todayMood.note!),
                                      ],
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed:
                                      () => provider.deleteMoodEntry(todayMood),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                  ],
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            todayMood == null
                                ? "How are you feeling today?"
                                : "Update your mood",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16.0),
                          MoodSelector(
                            selectedMood: _selectedMood,
                            onMoodSelected:
                                (mood) => setState(() => _selectedMood = mood),
                          ),
                          const SizedBox(height: 16.0),
                          TextField(
                            controller: _noteController,
                            decoration: const InputDecoration(
                              labelText: 'Add a note (optional)',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16.0),
                          ElevatedButton(
                            onPressed: _saveMood,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48.0),
                            ),
                            child: Text(
                              todayMood == null ? 'Save Mood' : 'Update Mood',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (provider.moodHistory.isNotEmpty) ...[
                    const SizedBox(height: 24.0),
                    Text(
                      'Mood History',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8.0),
                    ...provider.moodHistory
                        .where(
                          (entry) =>
                              !entry.date.isAtSameMomentAs(
                                DateTime(
                                  DateTime.now().year,
                                  DateTime.now().month,
                                  DateTime.now().day,
                                ),
                              ),
                        )
                        .map(
                          (entry) => Card(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            child: ListTile(
                              leading: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    MoodSelector.moods[entry.mood]!,
                                    style: const TextStyle(fontSize: 24.0),
                                  ),
                                  if (!entry.isSynced) ...[
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.sync_problem,
                                      size: 16,
                                      color: Colors.orange,
                                    ),
                                  ],
                                ],
                              ),
                              title: Text(
                                DateFormat.yMMMd().format(entry.date),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (entry.note?.isNotEmpty ?? false)
                                    Text(entry.note!),
                                  if (!entry.isSynced)
                                    Text(
                                      entry.syncError ?? 'Saving...',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (!entry.isSynced &&
                                      entry.syncError != null)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.refresh,
                                        size: 20,
                                        color: Colors.orange,
                                      ),
                                      onPressed: () => _retryEntry(entry),
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed:
                                        () => provider.deleteMoodEntry(entry),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
