import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/water_entry.dart';
import 'services/water_api_service.dart';
import '../../../../core/auth/auth_service.dart';

class WaterRepository {
  static const String _boxName = 'water_entries';
  late Box<WaterEntry> _waterBox;
  final List<WaterEntry> _entries = [];
  final Connectivity _connectivity = Connectivity();
  final WaterApiService _apiService;
  bool _isOnline = true;

  WaterRepository(AuthService authService)
    : _apiService = WaterApiService(authService: authService);

  Future<void> init() async {
    _waterBox = await Hive.openBox<WaterEntry>(_boxName);
    _loadEntries();
    _initConnectivity();
    await _syncWithBackend();
  }

  void _initConnectivity() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _isOnline = result != ConnectivityResult.none;
      if (_isOnline) {
        _syncEntries();
      }
    });
  }

  List<WaterEntry> get entries => List.unmodifiable(_entries);

  Future<void> saveWaterEntry(WaterEntry entry) async {
    try {
      // Add to local storage
      await _waterBox.add(entry);
      _entries.add(entry);
      _entries.sort((a, b) => b.date.compareTo(a.date));

      // Sync if online
      if (_isOnline) {
        await _syncEntry(entry);
      }
    } catch (e) {
      debugPrint('Error saving water entry: $e');
      rethrow;
    }
  }

  Future<void> _syncEntry(WaterEntry entry) async {
    try {
      final syncedEntry = await _apiService.syncEntry(entry);
      final index = _entries.indexWhere((e) => e.id == entry.id);
      if (index != -1) {
        _entries[index] = syncedEntry;
        await _waterBox.putAt(index, syncedEntry);
      }
    } catch (e) {
      debugPrint('Error syncing water entry: $e');
      rethrow;
    }
  }

  Future<void> _syncWithBackend() async {
    if (!_isOnline) return;

    try {
      // Get all entries from backend
      final remoteEntries = await _apiService.getAllEntries();

      // Update local entries with remote data
      for (final remoteEntry in remoteEntries) {
        final localIndex = _entries.indexWhere((e) => e.id == remoteEntry.id);
        if (localIndex != -1) {
          // Update existing entry
          _entries[localIndex] = remoteEntry;
          await _waterBox.putAt(localIndex, remoteEntry);
        } else {
          // Add new entry from backend
          _entries.add(remoteEntry);
          await _waterBox.add(remoteEntry);
        }
      }

      // Sync any local entries that aren't on the backend
      await _syncEntries();
    } catch (e) {
      debugPrint('Error syncing with backend: $e');
      rethrow;
    }
  }

  Future<void> _syncEntries() async {
    try {
      final unsyncedEntries =
          _entries.where((entry) => !entry.isSynced).toList();
      for (final entry in unsyncedEntries) {
        await _syncEntry(entry);
      }
    } catch (e) {
      debugPrint('Error syncing water entries: $e');
      rethrow;
    }
  }

  void _loadEntries() {
    _entries.clear();
    _entries.addAll(_waterBox.values.toList());
    _entries.sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> deleteWaterEntry(WaterEntry entry) async {
    try {
      final index = _entries.indexWhere((e) => e.id == entry.id);
      if (index != -1) {
        if (_isOnline) {
          await _apiService.deleteEntry(entry.id);
        }
        await _waterBox.deleteAt(index);
        _entries.removeAt(index);
      }
    } catch (e) {
      debugPrint('Error deleting water entry: $e');
      rethrow;
    }
  }

  Future<void> updateWaterEntry(WaterEntry entry) async {
    try {
      final index = _entries.indexWhere((e) => e.id == entry.id);
      if (index != -1) {
        if (_isOnline) {
          final updatedEntry = await _apiService.updateEntry(entry);
          await _waterBox.putAt(index, updatedEntry);
          _entries[index] = updatedEntry;
        } else {
          await _waterBox.putAt(index, entry);
          _entries[index] = entry;
        }
        _entries.sort((a, b) => b.date.compareTo(a.date));
      }
    } catch (e) {
      debugPrint('Error updating water entry: $e');
      rethrow;
    }
  }

  Future<void> close() async {
    await _waterBox.close();
    _apiService.dispose();
  }
}
