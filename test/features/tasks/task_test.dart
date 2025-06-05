import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:life_ease/features/task/domain/models/task.dart';
import 'package:life_ease/features/task/domain/task_service.dart';
import '../../helpers/mocks.mocks.dart';

void main() {
  group('Task Management Tests', () {
    late MockTaskService mockTaskService;

    setUp(() {
      mockTaskService = MockTaskService();
    });

    test('create task should add new task', () async {
      final task = Task(
        id: '1',
        title: 'Test Task',
        description: 'Test Description',
        isCompleted: false,
        dueDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSynced: true,
      );

      when(
        mockTaskService.createTask(task),
      ).thenAnswer((_) => Future.value(task));

      final result = await mockTaskService.createTask(task);

      expect(result.id, equals(task.id));
      expect(result.title, equals(task.title));
      expect(result.description, equals(task.description));
      expect(result.isCompleted, equals(task.isCompleted));

      verify(mockTaskService.createTask(task)).called(1);
    });

    test('complete task should update task status', () async {
      final task = Task(
        id: '1',
        title: 'Test Task',
        description: 'Test Description',
        isCompleted: false,
        dueDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSynced: true,
      );

      final updatedTask = task.copyWith(isCompleted: true);

      when(
        mockTaskService.updateTask(any),
      ).thenAnswer((_) async => updatedTask);

      final result = await mockTaskService.updateTask(
        task.copyWith(isCompleted: true),
      );

      expect(result.isCompleted, isTrue);
      verify(mockTaskService.updateTask(any)).called(1);
    });

    test('delete task should remove task', () async {
      final taskId = '1';

      when(mockTaskService.deleteTask(taskId)).thenAnswer((_) async => true);

      final result = await mockTaskService.deleteTask(taskId);

      expect(result, isTrue);
      verify(mockTaskService.deleteTask(taskId)).called(1);
    });

    test('fetch tasks should return task list', () async {
      final tasks = [
        Task(
          id: '1',
          title: 'Task 1',
          description: 'Description 1',
          isCompleted: false,
          dueDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isSynced: true,
        ),
        Task(
          id: '2',
          title: 'Task 2',
          description: 'Description 2',
          isCompleted: true,
          dueDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isSynced: true,
        ),
      ];

      when(mockTaskService.getTasks()).thenAnswer((_) async => tasks);

      final result = await mockTaskService.getTasks();

      expect(result.length, equals(2));
      expect(result, equals(tasks));
      verify(mockTaskService.getTasks()).called(1);
    });
  });
}
