import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../repositories/task_repository.dart';
import '../../domain/models/task.dart';
import '../../../../services/connectivity_service.dart';

class TaskService {
  final TaskRepository _repository;
  final ConnectivityService _connectivityService;
  Timer? _syncTimer;
  StreamSubscription? _connectivitySubscription;

  TaskService(this._repository, this._connectivityService) {
    _setupConnectivityListener();
    _setupPeriodicSync();
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = _connectivityService.onConnectivityChanged
        .listen((result) async {
          if (result != ConnectivityResult.none) {
            await syncTasks();
          }
        });
  }

  void _setupPeriodicSync() {
    // Sync every 5 minutes when online
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      if (await _connectivityService.isOnline()) {
        await syncTasks();
      }
    });
  }

  Future<void> dispose() async {
    _syncTimer?.cancel();
    await _connectivitySubscription?.cancel();
  }

  // Task CRUD operations
  Future<List<Task>> getAllTasks() async {
    return _repository.getAllTasks();
  }

  Future<Task?> getTask(String id) async {
    return _repository.getTask(id);
  }

  Future<Task> createTask(Task task) async {
    return _repository.createTask(task);
  }

  Future<Task> updateTask(Task task) async {
    return _repository.updateTask(task);
  }

  Future<void> deleteTask(String id) async {
    await _repository.deleteTask(id);
  }

  // Sync operations
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  Future<void> syncTasks() async {
    int retryCount = 0;
    while (retryCount < _maxRetries) {
      try {
        await _repository.syncTasks();
        break;
      } catch (e) {
        retryCount++;
        debugPrint('Sync attempt $retryCount failed: $e');
        if (retryCount == _maxRetries) {
          rethrow;
        }
        await Future.delayed(_retryDelay * retryCount);
      }
    }
  }

  List<Task> getUnsyncedTasks() {
    return _repository.getUnsyncedTasks();
  }

  Future<bool> hasUnsyncedChanges() async {
    return _repository.getUnsyncedTasks().isNotEmpty;
  }
}
