import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import '../../domain/models/task.dart';
import '../../../../services/connectivity_service.dart';
import '../services/task_api_service.dart';
import '../../../../core/mixins/disposable.dart';

class TaskRepository with Disposable {
  final Box<Task> _taskBox;
  final ConnectivityService _connectivityService;
  final TaskApiService _apiService;
  static const String _boxName = 'tasks';

  TaskRepository(this._connectivityService, this._apiService)
    : _taskBox = Hive.box<Task>(_boxName);

  /// Initialize Hive box for tasks
  static Future<void> init({HiveCipher? encryptionCipher}) async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<Task>(_boxName, encryptionCipher: encryptionCipher);
    }
  }

  /// Get all tasks, prioritizing local storage
  Future<List<Task>> getAllTasks() async {
    final isOnline = await _connectivityService.isOnline();
    if (isOnline) {
      try {
        final remoteTasks = await _apiService.getAllTasks();
        // Update local storage with remote data
        for (final task in remoteTasks) {
          await _taskBox.put(task.id, task.copyWith(isSynced: true));
        }
      } catch (e) {
        debugPrint('Error fetching remote tasks: $e');
        // Continue with local data if remote fetch fails
      }
    }
    return _taskBox.values.toList();
  }

  /// Get a single task by ID
  Future<Task?> getTask(String id) async {
    return _taskBox.get(id);
  }

  /// Create a new task
  Future<Task> createTask(Task task) async {
    final isOnline = await _connectivityService.isOnline();

    // Save locally first
    await _taskBox.put(task.id, task.copyWith(isSynced: isOnline));

    if (isOnline) {
      try {
        final remoteTask = await _apiService.createTask(task);
        await _taskBox.put(task.id, remoteTask.copyWith(isSynced: true));
        return remoteTask;
      } catch (e) {
        await _taskBox.put(
          task.id,
          task.copyWith(isSynced: false, syncError: e.toString()),
        );
        rethrow;
      }
    }

    return task;
  }

  /// Update an existing task
  Future<Task> updateTask(Task task) async {
    final isOnline = await _connectivityService.isOnline();

    // Update locally first
    await _taskBox.put(task.id, task.copyWith(isSynced: isOnline));

    if (isOnline) {
      try {
        final remoteTask = await _apiService.updateTask(task);
        await _taskBox.put(task.id, remoteTask.copyWith(isSynced: true));
        return remoteTask;
      } catch (e) {
        await _taskBox.put(
          task.id,
          task.copyWith(isSynced: false, syncError: e.toString()),
        );
        rethrow;
      }
    }

    return task;
  }

  /// Delete a task
  Future<void> deleteTask(String id) async {
    final isOnline = await _connectivityService.isOnline();

    // Delete locally first
    await _taskBox.delete(id);

    if (isOnline) {
      try {
        await _apiService.deleteTask(id);
      } catch (e) {
        debugPrint('Failed to delete task remotely: $e');
        // If remote delete fails, we might want to keep the task locally
        // with a "deleted" flag or handle it differently
        rethrow;
      }
    }
  }

  /// Sync all unsynced tasks
  Future<void> syncTasks() async {
    final isOnline = await _connectivityService.isOnline();
    if (!isOnline) return;

    final unsyncedTasks =
        _taskBox.values.where((task) => !task.isSynced).toList();

    for (final task in unsyncedTasks) {
      try {
        if (task.syncError?.contains('delete') ?? false) {
          await _apiService.deleteTask(task.id);
        } else {
          await _apiService.updateTask(task);
        }
        await _taskBox.put(
          task.id,
          task.copyWith(isSynced: true, syncError: null),
        );
      } catch (e) {
        await _taskBox.put(task.id, task.copyWith(syncError: e.toString()));
      }
    }
  }

  /// Get tasks that need syncing
  List<Task> getUnsyncedTasks() {
    return _taskBox.values.where((task) => !task.isSynced).toList();
  }

  @override
  void dispose() {
    _apiService.dispose();
  }
}
