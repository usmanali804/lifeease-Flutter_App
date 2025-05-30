import 'package:flutter/foundation.dart';

@immutable
class SleepEntry {
  final DateTime startTime;
  final DateTime endTime;
  final int quality; // 1-5 rating
  final String? note;
  final List<String> tags; // e.g., ["restless", "deep sleep", "nightmare"]

  const SleepEntry({
    required this.startTime,
    required this.endTime,
    required this.quality,
    this.note,
    this.tags = const [],
  });

  Duration get duration => endTime.difference(startTime);

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'quality': quality,
      'note': note,
      'tags': tags,
    };
  }

  factory SleepEntry.fromJson(Map<String, dynamic> json) {
    return SleepEntry(
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      quality: json['quality'] as int,
      note: json['note'] as String?,
      tags: List<String>.from(json['tags'] as List),
    );
  }

  SleepEntry copyWith({
    DateTime? startTime,
    DateTime? endTime,
    int? quality,
    String? note,
    List<String>? tags,
  }) {
    return SleepEntry(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      quality: quality ?? this.quality,
      note: note ?? this.note,
      tags: tags ?? this.tags,
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

  // Helper method to get formatted time range
  String get formattedTimeRange {
    final start =
        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final end =
        '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    return '$start - $end';
  }

  // Helper method to get quality emoji
  String get qualityEmoji {
    switch (quality) {
      case 1:
        return '😫';
      case 2:
        return '😕';
      case 3:
        return '😐';
      case 4:
        return '😊';
      case 5:
        return '😴';
      default:
        return '❓';
    }
  }
}
