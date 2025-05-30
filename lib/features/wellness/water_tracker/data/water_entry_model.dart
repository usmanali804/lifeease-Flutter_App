import 'package:flutter/foundation.dart';

@immutable
class WaterEntry {
  final double amount; // in milliliters
  final DateTime date;
  final String? note;

  const WaterEntry({required this.amount, required this.date, this.note});

  Map<String, dynamic> toJson() {
    return {'amount': amount, 'date': date.toIso8601String(), 'note': note};
  }

  factory WaterEntry.fromJson(Map<String, dynamic> json) {
    return WaterEntry(
      amount: json['amount'] as double,
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
    );
  }

  WaterEntry copyWith({double? amount, DateTime? date, String? note}) {
    return WaterEntry(
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}
