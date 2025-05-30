import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../data/mood_entry_model.dart';
import '../data/mood_repository.dart';

class MoodProvider extends ChangeNotifier {
  final MoodRepository _repository;
  final Connectivity _connectivity;
  MoodEntry? _todayMood;
  List<MoodEntry> _moodHistory = [];
  bool _isLoading = false;
  bool _isOnline = true;
  String? _error;

  MoodProvider(this._repository, {Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity() {
    _initConnectivity();
  }

  MoodEntry? get todayMood => _todayMood;
  List<MoodEntry> get moodHistory => _moodHistory;
  bool get isLoading => _isLoading;
  bool get isOnline => _isOnline;
  String? get error => _error;

  void _initConnectivity() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _isOnline = result != ConnectivityResult.none;
      if (_isOnline) {
        _syncEntries();
      }
      notifyListeners();
    });
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Initialize the provider
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.init();
      _todayMood = await _repository.getTodayMoodEntry();
      _moodHistory = _repository.entries;
      _isOnline =
          await _connectivity.checkConnectivity() != ConnectivityResult.none;
      if (_isOnline) {
        await _syncEntries();
      }
    } catch (e) {
      _error = 'Error initializing mood provider: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _syncEntries() async {
    try {
      await _repository.syncEntries();
      _moodHistory = _repository.entries;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to sync entries: $e';
      debugPrint(_error);
      notifyListeners();
    }
  }

  // Save a new mood entry
  Future<void> saveMoodEntry(String mood, {String? note}) async {
    final entry = MoodEntry(
      mood: mood,
      note: note,
      date: DateTime.now(),
      isSynced: _isOnline,
    );

    try {
      _error = null;
      await _repository.saveMoodEntry(entry);
      _todayMood = entry;
      _moodHistory = _repository.entries;
      notifyListeners();
    } catch (e) {
      _error = 'Error saving mood entry: $e';
      debugPrint(_error);
      notifyListeners();
      rethrow;
    }
  }

  // Retry syncing a failed entry
  Future<void> retryEntry(MoodEntry entry) async {
    try {
      _error = null;
      await _repository.retryEntry(entry);
      _moodHistory = _repository.entries;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to retry entry: $e';
      debugPrint(_error);
      notifyListeners();
      rethrow;
    }
  }

  // Delete a mood entry
  Future<void> deleteMoodEntry(MoodEntry entry) async {
    try {
      _error = null;
      await _repository.deleteMoodEntry(entry);
      _moodHistory = _repository.entries;
      if (_todayMood?.date.isAtSameMomentAs(entry.date) ?? false) {
        _todayMood = null;
      }
      notifyListeners();
    } catch (e) {
      _error = 'Error deleting mood entry: $e';
      debugPrint(_error);
      notifyListeners();
      rethrow;
    }
  }
}
