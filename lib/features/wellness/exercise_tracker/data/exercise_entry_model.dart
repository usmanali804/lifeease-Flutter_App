import 'package:flutter/foundation.dart';

@immutable
class ExerciseEntry {
  final String
  type; // e.g., "running", "walking", "cycling", "swimming", "yoga"
  final Duration duration;
  final double? caloriesBurned;
  final DateTime date;
  final String? note;
  final double?
  distance; // in kilometers, optional for exercises like running, walking, cycling

  const ExerciseEntry({
    required this.type,
    required this.duration,
    this.caloriesBurned,
    required this.date,
    this.note,
    this.distance,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'duration': duration.inMinutes,
      'caloriesBurned': caloriesBurned,
      'date': date.toIso8601String(),
      'note': note,
      'distance': distance,
    };
  }

  factory ExerciseEntry.fromJson(Map<String, dynamic> json) {
    return ExerciseEntry(
      type: json['type'] as String,
      duration: Duration(minutes: json['duration'] as int),
      caloriesBurned: json['caloriesBurned'] as double?,
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
      distance: json['distance'] as double?,
    );
  }

  ExerciseEntry copyWith({
    String? type,
    Duration? duration,
    double? caloriesBurned,
    DateTime? date,
    String? note,
    double? distance,
  }) {
    return ExerciseEntry(
      type: type ?? this.type,
      duration: duration ?? this.duration,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      date: date ?? this.date,
      note: note ?? this.note,
      distance: distance ?? this.distance,
    );
  }

  // Helper method to get formatted duration
  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  // Helper method to get formatted distance
  String get formattedDistance {
    if (distance == null) return '';
    return '${distance!.toStringAsFixed(1)} km';
  }

  // Helper method to get formatted calories
  String get formattedCalories {
    if (caloriesBurned == null) return '';
    return '${caloriesBurned!.toStringAsFixed(0)} cal';
  }
}
