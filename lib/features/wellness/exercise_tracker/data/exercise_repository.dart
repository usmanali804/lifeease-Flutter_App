import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'exercise_entry_model.dart';

class ExerciseRepository {
  static const String _storageKey = 'exercise_entries';
  final SharedPreferences _prefs;

  ExerciseRepository(this._prefs);

  Future<void> saveExerciseEntry(ExerciseEntry entry) async {
    final entries = await getExerciseEntries();
    entries.add(entry);
    await _saveEntries(entries);
  }

  Future<List<ExerciseEntry>> getExerciseEntries() async {
    final String? entriesJson = _prefs.getString(_storageKey);
    if (entriesJson == null) return [];

    final List<dynamic> decoded = jsonDecode(entriesJson);
    return decoded
        .map((entry) => ExerciseEntry.fromJson(entry as Map<String, dynamic>))
        .toList();
  }

  Future<List<ExerciseEntry>> getTodayExerciseEntries() async {
    final entries = await getExerciseEntries();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return entries.where((entry) {
      final entryDate = DateTime(
        entry.date.year,
        entry.date.month,
        entry.date.day,
      );
      return entryDate.isAtSameMomentAs(today);
    }).toList();
  }

  Future<Duration> getTodayTotalDuration() async {
    final todayEntries = await getTodayExerciseEntries();
    return todayEntries.fold<Duration>(
      Duration.zero,
      (total, entry) => total + entry.duration,
    );
  }

  Future<double> getTodayTotalCalories() async {
    final todayEntries = await getTodayExerciseEntries();
    return todayEntries.fold<double>(
      0.0,
      (total, entry) => total + (entry.caloriesBurned ?? 0.0),
    );
  }

  Future<double> getTodayTotalDistance() async {
    final todayEntries = await getTodayExerciseEntries();
    return todayEntries.fold<double>(
      0.0,
      (total, entry) => total + (entry.distance ?? 0.0),
    );
  }

  Future<void> deleteExerciseEntry(ExerciseEntry entry) async {
    final entries = await getExerciseEntries();
    entries.removeWhere((e) => e.date.isAtSameMomentAs(entry.date));
    await _saveEntries(entries);
  }

  Future<void> _saveEntries(List<ExerciseEntry> entries) async {
    final entriesJson = jsonEncode(entries.map((e) => e.toJson()).toList());
    await _prefs.setString(_storageKey, entriesJson);
  }

  // Get exercise entries for a specific date range
  Future<List<ExerciseEntry>> getExerciseEntriesInRange(
    DateTime start,
    DateTime end,
  ) async {
    final entries = await getExerciseEntries();
    return entries.where((entry) {
      return entry.date.isAfter(start.subtract(const Duration(days: 1))) &&
          entry.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Get exercise statistics for a specific date range
  Future<Map<String, dynamic>> getExerciseStatsInRange(
    DateTime start,
    DateTime end,
  ) async {
    final entries = await getExerciseEntriesInRange(start, end);
    
    final totalDuration = entries.fold<Duration>(
      Duration.zero,
      (total, entry) => total + entry.duration,
    );
    
    final totalCalories = entries.fold<double>(
      0.0,
      (total, entry) => total + (entry.caloriesBurned ?? 0.0),
    );
    
    final totalDistance = entries.fold<double>(
      0.0,
      (total, entry) => total + (entry.distance ?? 0.0),
    );

    // Count exercises by type
    final exerciseTypeCount = <String, int>{};
    for (final entry in entries) {
      exerciseTypeCount[entry.type] = (exerciseTypeCount[entry.type] ?? 0) + 1;
    }

    return {
      'totalDuration': totalDuration,
      'totalCalories': totalCalories,
      'totalDistance': totalDistance,
      'exerciseTypeCount': exerciseTypeCount,
      'entryCount': entries.length,
    };
  }
} 