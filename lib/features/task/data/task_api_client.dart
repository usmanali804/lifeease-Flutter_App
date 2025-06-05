import '../../../core/network/base_api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/task_model.dart';

class TaskApiClient extends BaseApiClient {
  Future<List<Task>> getTasks({
    Map<String, dynamic>? filters,
    String? sortBy,
    bool ascending = true,
  }) async {
    return handleResponse(
      () => apiService.get(
        ApiEndpoints.tasks,
        queryParameters: {
          if (filters != null) ...filters,
          if (sortBy != null) 'sortBy': sortBy,
          'sortOrder': ascending ? 'asc' : 'desc',
        },
      ),
      (data) => (data as List).map((item) => Task.fromJson(item)).toList(),
    );
  }

  Future<Task> getTaskById(String id) async {
    return handleResponse(
      () => apiService.get('${ApiEndpoints.taskById}$id'),
      (data) => Task.fromJson(data),
    );
  }

  Future<Task> createTask(TaskCreateDto dto) async {
    return handleResponse(
      () => apiService.post(ApiEndpoints.tasks, data: dto.toJson()),
      (data) => Task.fromJson(data),
    );
  }

  Future<Task> updateTask(String id, TaskUpdateDto dto) async {
    return handleResponse(
      () => apiService.put('${ApiEndpoints.taskById}$id', data: dto.toJson()),
      (data) => Task.fromJson(data),
    );
  }

  Future<void> deleteTask(String id) async {
    return handleResponse(
      () => apiService.delete('${ApiEndpoints.taskById}$id'),
      (_) => null,
    );
  }

  Future<List<TaskCategory>> getTaskCategories() async {
    return handleResponse(
      () => apiService.get(ApiEndpoints.taskCategories),
      (data) =>
          (data as List)
              .map(
                (item) => TaskCategory.values.firstWhere(
                  (e) => e.toString().split('.').last == item['name'],
                  orElse: () => TaskCategory.other,
                ),
              )
              .toList(),
    );
  }
}

class TaskCreateDto {
  final String title;
  final String? description;
  final DateTime dueDate;
  final TaskCategory category;
  final TaskPriority priority;
  final List<String>? tags;

  TaskCreateDto({
    required this.title,
    this.description,
    required this.dueDate,
    required this.category,
    this.priority = TaskPriority.medium,
    this.tags,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    if (description != null) 'description': description,
    'dueDate': dueDate.toIso8601String(),
    'category': category.name,
    'priority': priority.name,
    if (tags != null) 'tags': tags,
  };
}

class TaskUpdateDto {
  final String? title;
  final String? description;
  final DateTime? dueDate;
  final TaskCategory? category;
  final TaskPriority? priority;
  final List<String>? tags;
  final bool? completed;

  TaskUpdateDto({
    this.title,
    this.description,
    this.dueDate,
    this.category,
    this.priority,
    this.tags,
    this.completed,
  });

  Map<String, dynamic> toJson() => {
    if (title != null) 'title': title,
    if (description != null) 'description': description,
    if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
    if (category != null) 'category': category!.name,
    if (priority != null) 'priority': priority!.name,
    if (tags != null) 'tags': tags,
    if (completed != null) 'completed': completed,
  };
}
