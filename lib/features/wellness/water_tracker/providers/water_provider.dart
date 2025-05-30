import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../data/water_repository.dart';
import '../models/water_entry.dart';

class WaterProvider with ChangeNotifier {
  final WaterRepository _repository;
  final Connectivity _connectivity = Connectivity();
  bool _isOnline = true;
  String? _error;
  bool _isLoading = false;
  bool _isNetworkOperation = false;

  WaterProvider(this._repository) {
    _initConnectivity();
    initialize();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  bool get isOnline => _isOnline;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isNetworkOperation => _isNetworkOperation;
  List<WaterEntry> get entries => _repository.entries;

  // Recommended daily water intake in milliliters (2.5 liters)
  static const double recommendedDailyIntake = 2500.0;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.init();
      if (_isOnline) {
        await _syncEntries();
      }
    } catch (e) {
      _error = 'Failed to initialize water tracking: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _initConnectivity() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _isOnline = result != ConnectivityResult.none;
      if (_isOnline) {
        _syncEntries();
      }
      notifyListeners();
    });
  }

  Future<void> _syncEntries() async {
    try {
      // The repository handles the actual syncing
      // We just need to notify listeners of any changes
      notifyListeners();
    } catch (e) {
      _error = 'Failed to sync water entries: $e';
      debugPrint(_error);
      notifyListeners();
    }
  }

  Future<void> addWaterEntry(double amount, {String? note}) async {
    try {
      _error = null;
      final entry = WaterEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        amount: amount,
        note: note,
        isSynced: _isOnline,
      );

      await _repository.saveWaterEntry(entry);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add water entry: ${_getErrorMessage(e)}';
      debugPrint(_error);
      notifyListeners();
      // Rethrow specific errors that need to be handled by UI
      if (e is Exception) {
        rethrow;
      }
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString();
    } else if (error is Error) {
      return 'An unexpected error occurred: ${error.toString()}';
    }
    return 'An unknown error occurred';
  }

  Future<void> updateWaterEntry(WaterEntry entry) async {
    try {
      _error = null;
      await _repository.updateWaterEntry(entry);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update water entry: $e';
      debugPrint(_error);
      notifyListeners();
    }
  }

  Future<void> deleteWaterEntry(WaterEntry entry) async {
    try {
      _error = null;
      await _repository.deleteWaterEntry(entry);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete water entry: $e';
      debugPrint(_error);
      notifyListeners();
    }
  }

  Future<void> _performNetworkOperation(
    Future<void> Function() operation,
  ) async {
    _isNetworkOperation = true;
    _error = null;
    notifyListeners();

    try {
      await operation();
    } catch (e) {
      _error = _getErrorMessage(e);
      rethrow;
    } finally {
      _isNetworkOperation = false;
      notifyListeners();
    }
  }

  Future<void> syncEntries() async {
    await _performNetworkOperation(() async {
      if (!_isOnline) {
        throw Exception('No internet connection');
      }
      await _syncEntries();
    });
  }

  Future<void> retryEntry(WaterEntry entry) async {
    await _performNetworkOperation(() async {
      if (!_isOnline) {
        throw Exception('No internet connection');
      }
      await _repository.updateWaterEntry(entry.copyWith(isSynced: true));
    });
  }

  double getTodayTotalWater() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return entries
        .where((entry) {
          final entryDate = DateTime(
            entry.date.year,
            entry.date.month,
            entry.date.day,
          );
          return entryDate.isAtSameMomentAs(today);
        })
        .fold<double>(0.0, (sum, entry) => sum + entry.amount);
  }

  List<WaterEntry> getTodayEntries() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return entries.where((entry) {
      final entryDate = DateTime(
        entry.date.year,
        entry.date.month,
        entry.date.day,
      );
      return entryDate.isAtSameMomentAs(today);
    }).toList();
  }

  double getProgressPercentage() {
    return (getTodayTotalWater() / recommendedDailyIntake).clamp(0.0, 1.0);
  }

  String getRemainingWater() {
    final remaining = recommendedDailyIntake - getTodayTotalWater();
    return remaining > 0
        ? '${remaining.toStringAsFixed(0)}ml'
        : 'Goal achieved!';
  }

  @override
  void dispose() {
    _repository.close();
    super.dispose();
  }
}
