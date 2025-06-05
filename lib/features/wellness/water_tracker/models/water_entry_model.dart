import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'water_entry_model.g.dart';

@HiveType(typeId: 3)
class WaterEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount; // in milliliters

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final String? note;

  @HiveField(4)
  final bool isSynced;

  WaterEntry({
    String? id,
    required this.amount,
    required this.date,
    this.note,
    this.isSynced = false,
  }) : id = id ?? const Uuid().v4();

  WaterEntry copyWith({
    String? id,
    double? amount,
    DateTime? date,
    String? note,
    bool? isSynced,
  }) {
    return WaterEntry(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
      'isSynced': isSynced,
    };
  }

  factory WaterEntry.fromJson(Map<String, dynamic> json) {
    return WaterEntry(
      id: json['id'] as String,
      amount: json['amount'] as double,
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
      isSynced: json['isSynced'] as bool? ?? false,
    );
  }
}
