import 'package:flutter/foundation.dart';
import '../data/sleep_entry_model.dart';
import '../data/sleep_repository.dart';

class SleepProvider extends ChangeNotifier {
  final SleepRepository _repository;
  List<SleepEntry> _todayEntries = [];
  Duration _todayTotalDuration = Duration.zero;
  double _todayAverageQuality = 0.0;
  bool _isLoading = false;

  SleepProvider(this._repository);

  List<SleepEntry> get todayEntries => _todayEntries;
  Duration get todayTotalDuration => _todayTotalDuration;
  double get todayAverageQuality => _todayAverageQuality;
  bool get isLoading => _isLoading;

  // Available sleep tags
  static const List<String> availableTags = [
    'deep sleep',
    'restless',
    'nightmare',
    'snoring',
    'woke up early',
    'slept in',
    'interrupted',
    'peaceful',
  ];

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _todayEntries = await _repository.getTodaySleepEntries();
      _todayTotalDuration = await _repository.getTodayTotalSleepDuration();
      _todayAverageQuality = await _repository.getTodayAverageSleepQuality();
    } catch (e) {
      debugPrint('Error initializing sleep provider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSleepEntry({
    required DateTime startTime,
    required DateTime endTime,
    required int quality,
    String? note,
    List<String> tags = const [],
  }) async {
    if (quality < 1 || quality > 5) {
      throw ArgumentError('Sleep quality must be between 1 and 5');
    }

    final entry = SleepEntry(
      startTime: startTime,
      endTime: endTime,
      quality: quality,
      note: note,
      tags: tags,
    );

    try {
      await _repository.saveSleepEntry(entry);
      _todayEntries.add(entry);
      _todayTotalDuration += entry.duration;

      // Recalculate average quality
      final totalQuality = _todayEntries.fold<int>(
        0,
        (total, entry) => total + entry.quality,
      );
      _todayAverageQuality = totalQuality / _todayEntries.length;

      notifyListeners();
    } catch (e) {
      debugPrint('Error adding sleep entry: $e');
      rethrow;
    }
  }

  Future<void> deleteSleepEntry(SleepEntry entry) async {
    try {
      await _repository.deleteSleepEntry(entry);
      _todayEntries.removeWhere(
        (e) => e.endTime.isAtSameMomentAs(entry.endTime),
      );
      _todayTotalDuration -= entry.duration;

      // Recalculate average quality
      if (_todayEntries.isEmpty) {
        _todayAverageQuality = 0.0;
      } else {
        final totalQuality = _todayEntries.fold<int>(
          0,
          (total, entry) => total + entry.quality,
        );
        _todayAverageQuality = totalQuality / _todayEntries.length;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting sleep entry: $e');
      rethrow;
    }
  }

  // Get sleep statistics for a date range
  Future<Map<String, dynamic>> getSleepStatsInRange(
    DateTime start,
    DateTime end,
  ) async {
    return _repository.getSleepStatsInRange(start, end);
  }

  // Helper method to get formatted total duration
  String get formattedTotalDuration {
    final hours = _todayTotalDuration.inHours;
    final minutes = _todayTotalDuration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  // Helper method to get formatted average quality
  String get formattedAverageQuality {
    if (_todayAverageQuality == 0) return 'No entries';
    return _todayAverageQuality.toStringAsFixed(1);
  }
}
