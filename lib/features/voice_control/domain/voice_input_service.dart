import 'package:speech_to_text/speech_to_text.dart';

class VoiceInputService {
  final SpeechToText _speech = SpeechToText();
  bool _isAvailable = false;
  bool _isListening = false;

  Future<bool> initSpeech() async {
    _isAvailable = await _speech.initialize();
    return _isAvailable;
  }

  Future<void> startListening(
    Function(String) onResult, {
    String localeId = 'en_US',
  }) async {
    if (!_isAvailable) await initSpeech();
    if (_isAvailable && !_isListening) {
      _speech.listen(
        onResult: (result) {
          onResult(result.recognizedWords);
        },
        localeId: localeId,
        listenFor: const Duration(seconds: 30),
        listenOptions: SpeechListenOptions(partialResults: true),
      );
      _isListening = true;
    }
  }

  void stopListening() {
    if (_isListening) {
      _speech.stop();
      _isListening = false;
    }
  }

  void cancelListening() {
    if (_isListening) {
      _speech.cancel();
      _isListening = false;
    }
  }

  bool get isListening => _isListening;
}
