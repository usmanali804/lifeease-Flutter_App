import 'package:hive/hive.dart';

part 'message.g.dart';

@HiveType(typeId: 1)
class Message extends HiveObject {
  @HiveField(0)
  final String text;

  @HiveField(1)
  final String sender;

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  bool isSynced;

  @HiveField(4)
  String? syncError;

  Message({
    required this.text,
    required this.sender,
    DateTime? timestamp,
    this.isSynced = false,
    this.syncError,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'text': text,
    'sender': sender,
    'timestamp': timestamp.toIso8601String(),
    'isSynced': isSynced,
    'syncError': syncError,
  };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    text: json['text'] as String,
    sender: json['sender'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    isSynced: json['isSynced'] as bool? ?? false,
    syncError: json['syncError'] as String?,
  );
}
