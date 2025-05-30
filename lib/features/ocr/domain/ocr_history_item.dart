import 'package:json_annotation/json_annotation.dart';

part 'ocr_history_item.g.dart';

@JsonSerializable()
class OCRHistoryItem {
  final String id;
  final String text;
  final DateTime timestamp;
  final String? imagePath;

  OCRHistoryItem({
    required this.id,
    required this.text,
    required this.timestamp,
    this.imagePath,
  });

  factory OCRHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$OCRHistoryItemFromJson(json);

  Map<String, dynamic> toJson() => _$OCRHistoryItemToJson(this);

  OCRHistoryItem copyWith({
    String? text,
    String? imagePath,
  }) {
    return OCRHistoryItem(
      id: id,
      text: text ?? this.text,
      timestamp: timestamp,
      imagePath: imagePath ?? this.imagePath,
    );
  }
} 