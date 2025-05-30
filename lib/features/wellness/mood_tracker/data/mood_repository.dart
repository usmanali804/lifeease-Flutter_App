import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'mood_entry_model.dart';

class MoodRepository {
  static const String _boxName = 'mood_entries';
  late Box<MoodEntry> _moodBox;
  final Connectivity _connectivity;
  final List<MoodEntry> _entries = [];

  MoodRepository({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  List<MoodEntry> get entries => List.unmodifiable(_entries);

  Future<void> init() async {
    _moodBox = await Hive.openBox<MoodEntry>(_boxName);
    await loadEntries();
    _initConnectivity();
  }

  void _initConnectivity() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        syncEntries();
      }
    });
  }

  Future<void> loadEntries() async {
    _entries.clear();
    _entries.addAll(_moodBox.values.toList());
    _entries.sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> saveMoodEntry(MoodEntry entry) async {
    await _moodBox.add(entry);
    _entries.insert(0, entry);
    _entries.sort((a, b) => b.date.compareTo(a.date));

    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      await syncEntry(entry);
    }
  }

  Future<void> syncEntry(MoodEntry entry) async {
    if (entry.isSynced) return;

    try {
      // Here you would typically make an API call to sync the entry
      // For now, we'll just simulate successful sync
      await Future.delayed(const Duration(milliseconds: 300));
      entry.isSynced = true;
      entry.syncError = null;
      await entry.save();
    } catch (e) {
      entry.syncError = e.toString();
      await entry.save();
      rethrow;
    }
  }

  Future<void> syncEntries() async {
    final unsyncedEntries = _entries.where((e) => !e.isSynced).toList();

    for (final entry in unsyncedEntries) {
      try {
        await syncEntry(entry);
      } catch (e) {
        // Continue with other entries even if one fails
        debugPrint('Failed to sync entry: $e');
      }
    }
  }

  Future<void> retryEntry(MoodEntry entry) async {
    if (entry.isSynced) return;
    await syncEntry(entry);
  }

  Future<MoodEntry?> getTodayMoodEntry() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    try {
      return _entries.firstWhere(
        (entry) => DateTime(
          entry.date.year,
          entry.date.month,
          entry.date.day,
        ).isAtSameMomentAs(today),
        orElse: () => throw StateError('No matching element'),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteMoodEntry(MoodEntry entry) async {
    await entry.delete();
    _entries.removeWhere((e) => e.date.isAtSameMomentAs(entry.date));
  }

  Future<void> close() async {
    await _moodBox.close();
  }
}
