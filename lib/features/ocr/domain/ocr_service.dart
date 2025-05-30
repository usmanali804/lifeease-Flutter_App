import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:uuid/uuid.dart';
import 'ocr_history_item.dart';

class OCRService {
  final textRecognizer = TextRecognizer();
  final List<OCRHistoryItem> _history = [];
  final _uuid = const Uuid();

  List<OCRHistoryItem> get history => List.unmodifiable(_history);

  Future<String> extractTextFromImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );
      return recognizedText.text;
    } catch (e) {
      throw Exception('Failed to process image: $e');
    }
  }

  void addToHistory(String text, {String? imagePath}) {
    final item = OCRHistoryItem(
      id: _uuid.v4(),
      text: text,
      timestamp: DateTime.now(),
      imagePath: imagePath,
    );
    _history.insert(0, item);
  }

  void removeFromHistory(String id) {
    _history.removeWhere((item) => item.id == id);
  }

  void clearHistory() {
    _history.clear();
  }

  void dispose() {
    textRecognizer.close();
  }
}
