import 'package:hive/hive.dart';

part 'water_entry.g.dart';

@HiveType(typeId: 3)
class WaterEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String? note;

  @HiveField(4)
  final bool isSynced;

  WaterEntry({
    required this.id,
    required this.date,
    required this.amount,
    this.note,
    this.isSynced = false,
  });

  WaterEntry copyWith({
    String? id,
    DateTime? date,
    double? amount,
    String? note,
    bool? isSynced,
  }) {
    return WaterEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'amount': amount,
      'note': note,
      'isSynced': isSynced,
    };
  }

  factory WaterEntry.fromJson(Map<String, dynamic> json) {
    return WaterEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      amount: json['amount'] as double,
      note: json['note'] as String?,
      isSynced: json['isSynced'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WaterEntry &&
        other.id == id &&
        other.date == date &&
        other.amount == amount &&
        other.note == note &&
        other.isSynced == isSynced;
  }

  @override
  int get hashCode {
    return Object.hash(id, date, amount, note, isSynced);
  }
}
