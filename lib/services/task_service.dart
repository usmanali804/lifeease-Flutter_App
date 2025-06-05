import '../data/models/task_model.dart';

abstract class TaskService {
  Future<List<Task>> getTasks();
  Future<Task> createTask(Task task);
  Future<Task> updateTask(Task task);
  Future<bool> deleteTask(String taskId);
  Future<Task?> getTaskById(String taskId);
}
