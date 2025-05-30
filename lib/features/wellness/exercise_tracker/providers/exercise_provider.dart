import 'package:flutter/foundation.dart';
import '../data/exercise_entry_model.dart';
import '../data/exercise_repository.dart';

class ExerciseProvider extends ChangeNotifier {
  final ExerciseRepository _repository;
  List<ExerciseEntry> _todayEntries = [];
  Duration _todayTotalDuration = Duration.zero;
  double _todayTotalCalories = 0.0;
  double _todayTotalDistance = 0.0;
  bool _isLoading = false;

  ExerciseProvider(this._repository);

  List<ExerciseEntry> get todayEntries => _todayEntries;
  Duration get todayTotalDuration => _todayTotalDuration;
  double get todayTotalCalories => _todayTotalCalories;
  double get todayTotalDistance => _todayTotalDistance;
  bool get isLoading => _isLoading;

  // Exercise types with their icons and default calorie burn rates (calories per minute)
  static const Map<String, Map<String, dynamic>> exerciseTypes = {
    'running': {
      'icon': '🏃',
      'caloriesPerMinute': 10.0,
      'supportsDistance': true,
    },
    'walking': {
      'icon': '🚶',
      'caloriesPerMinute': 4.0,
      'supportsDistance': true,
    },
    'cycling': {
      'icon': '🚴',
      'caloriesPerMinute': 7.0,
      'supportsDistance': true,
    },
    'swimming': {
      'icon': '🏊',
      'caloriesPerMinute': 8.0,
      'supportsDistance': true,
    },
    'yoga': {'icon': '🧘', 'caloriesPerMinute': 3.0, 'supportsDistance': false},
    'strength': {
      'icon': '💪',
      'caloriesPerMinute': 5.0,
      'supportsDistance': false,
    },
    'dancing': {
      'icon': '💃',
      'caloriesPerMinute': 6.0,
      'supportsDistance': false,
    },
  };

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _todayEntries = await _repository.getTodayExerciseEntries();
      _todayTotalDuration = await _repository.getTodayTotalDuration();
      _todayTotalCalories = await _repository.getTodayTotalCalories();
      _todayTotalDistance = await _repository.getTodayTotalDistance();
    } catch (e) {
      debugPrint('Error initializing exercise provider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addExerciseEntry({
    required String type,
    required Duration duration,
    double? distance,
    String? note,
  }) async {
    // Calculate calories based on exercise type and duration
    final caloriesBurned =
        exerciseTypes[type]?['caloriesPerMinute'] != null
            ? (exerciseTypes[type]!['caloriesPerMinute'] as double) *
                duration.inMinutes
            : null;

    final entry = ExerciseEntry(
      type: type,
      duration: duration,
      caloriesBurned: caloriesBurned,
      distance: distance,
      date: DateTime.now(),
      note: note,
    );

    try {
      await _repository.saveExerciseEntry(entry);
      _todayEntries.add(entry);
      _todayTotalDuration += duration;
      _todayTotalCalories += caloriesBurned ?? 0.0;
      _todayTotalDistance += distance ?? 0.0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding exercise entry: $e');
      rethrow;
    }
  }

  Future<void> deleteExerciseEntry(ExerciseEntry entry) async {
    try {
      await _repository.deleteExerciseEntry(entry);
      _todayEntries.removeWhere((e) => e.date.isAtSameMomentAs(entry.date));
      _todayTotalDuration -= entry.duration;
      _todayTotalCalories -= entry.caloriesBurned ?? 0.0;
      _todayTotalDistance -= entry.distance ?? 0.0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting exercise entry: $e');
      rethrow;
    }
  }

  // Get exercise statistics for a date range
  Future<Map<String, dynamic>> getExerciseStatsInRange(
    DateTime start,
    DateTime end,
  ) async {
    return _repository.getExerciseStatsInRange(start, end);
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

  // Helper method to get formatted total distance
  String get formattedTotalDistance {
    if (_todayTotalDistance == 0) return '';
    return '${_todayTotalDistance.toStringAsFixed(1)} km';
  }

  // Helper method to get formatted total calories
  String get formattedTotalCalories {
    if (_todayTotalCalories == 0) return '';
    return '${_todayTotalCalories.toStringAsFixed(0)} cal';
  }
}
