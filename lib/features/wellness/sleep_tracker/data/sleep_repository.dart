import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'sleep_entry_model.dart';

class SleepRepository {
  static const String _storageKey = 'sleep_entries';
  final SharedPreferences _prefs;

  SleepRepository(this._prefs);

  Future<void> saveSleepEntry(SleepEntry entry) async {
    final entries = await getSleepEntries();
    entries.add(entry);
    await _saveEntries(entries);
  }

  Future<List<SleepEntry>> getSleepEntries() async {
    final String? entriesJson = _prefs.getString(_storageKey);
    if (entriesJson == null) return [];

    final List<dynamic> decoded = jsonDecode(entriesJson);
    return decoded
        .map((entry) => SleepEntry.fromJson(entry as Map<String, dynamic>))
        .toList();
  }

  Future<List<SleepEntry>> getTodaySleepEntries() async {
    final entries = await getSleepEntries();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return entries.where((entry) {
      final entryDate = DateTime(
        entry.endTime.year,
        entry.endTime.month,
        entry.endTime.day,
      );
      return entryDate.isAtSameMomentAs(today);
    }).toList();
  }

  Future<Duration> getTodayTotalSleepDuration() async {
    final todayEntries = await getTodaySleepEntries();
    return todayEntries.fold<Duration>(
      Duration.zero,
      (total, entry) => total + entry.duration,
    );
  }

  Future<double> getTodayAverageSleepQuality() async {
    final todayEntries = await getTodaySleepEntries();
    if (todayEntries.isEmpty) return 0.0;

    final totalQuality = todayEntries.fold<int>(
      0,
      (total, entry) => total + entry.quality,
    );
    return totalQuality / todayEntries.length;
  }

  Future<void> deleteSleepEntry(SleepEntry entry) async {
    final entries = await getSleepEntries();
    entries.removeWhere((e) => e.endTime.isAtSameMomentAs(entry.endTime));
    await _saveEntries(entries);
  }

  Future<void> _saveEntries(List<SleepEntry> entries) async {
    final entriesJson = jsonEncode(entries.map((e) => e.toJson()).toList());
    await _prefs.setString(_storageKey, entriesJson);
  }

  // Get sleep entries for a specific date range
  Future<List<SleepEntry>> getSleepEntriesInRange(
    DateTime start,
    DateTime end,
  ) async {
    final entries = await getSleepEntries();
    return entries.where((entry) {
      return entry.endTime.isAfter(start.subtract(const Duration(days: 1))) &&
          entry.endTime.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Get sleep statistics for a specific date range
  Future<Map<String, dynamic>> getSleepStatsInRange(
    DateTime start,
    DateTime end,
  ) async {
    final entries = await getSleepEntriesInRange(start, end);

    final totalDuration = entries.fold<Duration>(
      Duration.zero,
      (total, entry) => total + entry.duration,
    );

    final averageQuality =
        entries.isEmpty
            ? 0.0
            : entries.fold<int>(0, (total, entry) => total + entry.quality) /
                entries.length;

    // Count occurrences of each tag
    final tagCount = <String, int>{};
    for (final entry in entries) {
      for (final tag in entry.tags) {
        tagCount[tag] = (tagCount[tag] ?? 0) + 1;
      }
    }

    return {
      'totalDuration': totalDuration,
      'averageQuality': averageQuality,
      'tagCount': tagCount,
      'entryCount': entries.length,
    };
  }
}
