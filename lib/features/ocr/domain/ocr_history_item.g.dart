// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ocr_history_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OCRHistoryItem _$OCRHistoryItemFromJson(Map<String, dynamic> json) =>
    OCRHistoryItem(
      id: json['id'] as String,
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      imagePath: json['imagePath'] as String?,
    );

Map<String, dynamic> _$OCRHistoryItemToJson(OCRHistoryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'timestamp': instance.timestamp.toIso8601String(),
      'imagePath': instance.imagePath,
    };
