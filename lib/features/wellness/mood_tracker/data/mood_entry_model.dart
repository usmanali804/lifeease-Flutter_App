import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

part 'mood_entry_model.g.dart';

@HiveType(typeId: 2)
class MoodEntry extends HiveObject {
  @HiveField(0)
  final String mood; // e.g., "happy", "sad"

  @HiveField(1)
  final String? note;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  bool isSynced;

  @HiveField(4)
  String? syncError;

  MoodEntry({
    required this.mood,
    this.note,
    required this.date,
    this.isSynced = false,
    this.syncError,
  });

  // For JSON serialization (used by SharedPreferences)
  Map<String, dynamic> toJson() {
    return {
      'mood': mood,
      'note': note,
      'date': date.toIso8601String(),
      'isSynced': isSynced,
      'syncError': syncError,
    };
  }

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      mood: json['mood'] as String,
      note: json['note'] as String?,
      date: DateTime.parse(json['date'] as String),
      isSynced: json['isSynced'] as bool? ?? false,
      syncError: json['syncError'] as String?,
    );
  }

  // Add copyWith method for easy updates
  MoodEntry copyWith({
    String? mood,
    String? note,
    DateTime? date,
    bool? isSynced,
    String? syncError,
  }) {
    return MoodEntry(
      mood: mood ?? this.mood,
      note: note ?? this.note,
      date: date ?? this.date,
      isSynced: isSynced ?? this.isSynced,
      syncError: syncError ?? this.syncError,
    );
  }
}
