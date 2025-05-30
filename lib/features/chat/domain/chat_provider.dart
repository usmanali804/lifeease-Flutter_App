import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../data/chat_repository.dart';
import 'message.dart';

class ChatProvider with ChangeNotifier {
  final ChatRepository _repository;
  final Connectivity _connectivity;
  bool _isLoading = false;
  bool _isOnline = true;
  String? _error;

  ChatProvider({required ChatRepository repository, Connectivity? connectivity})
    : _repository = repository,
      _connectivity = connectivity ?? Connectivity() {
    _initConnectivity();
    _loadMessages();
  }

  List<Message> get messages => _repository.messages;
  bool get isLoading => _isLoading;
  bool get isOnline => _isOnline;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _initConnectivity() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _isOnline = result != ConnectivityResult.none;
      if (_isOnline) {
        _syncMessages();
      }
      notifyListeners();
    });
  }

  Future<void> _loadMessages() async {
    try {
      await _repository.loadMessages();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load messages: $e';
      notifyListeners();
    }
  }

  Future<void> _syncMessages() async {
    try {
      await _repository.syncMessages();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to sync messages: $e';
      notifyListeners();
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final message = Message(text: text, sender: 'user', isSynced: _isOnline);

      await _repository.addMessage(message);

      if (_isOnline) {
        // Simulate AI response
        await Future.delayed(const Duration(milliseconds: 600));
        final aiMessage = Message(
          text: "This is an AI reply to: $text",
          sender: 'bot',
          isSynced: true,
        );
        await _repository.addMessage(aiMessage);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to send message: $e';
      notifyListeners();
    }
  }

  Future<void> retryFailedMessage(Message message) async {
    try {
      _error = null;
      await _repository.retryMessage(message);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to retry message: $e';
      notifyListeners();
    }
  }

  Future<void> clearMessages() async {
    try {
      await _repository.clearMessages();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to clear messages: $e';
      notifyListeners();
    }
  }

  // For persistence (optional)
  List<Map<String, dynamic>> toJson() =>
      _repository.messages.map((message) => message.toJson()).toList();

  void loadFromJson(List<Map<String, dynamic>> json) {
    _repository.messages.clear();
    _repository.messages.addAll(
      json.map((data) => Message.fromJson(data)).toList(),
    );
    notifyListeners();
  }
}
