import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/task_repository.dart';
import '../../domain/models/task.dart';
import 'task_form_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  @override
  Widget build(BuildContext context) {
    final repository = context.read<TaskRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () async {
              try {
                await repository.syncTasks();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tasks synced successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Sync failed: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Task>>(
        future: repository.getAllTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final tasks = snapshot.data ?? [];

          if (tasks.isEmpty) {
            return const Center(
              child: Text(
                'No tasks yet. Tap + to add a new task.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                // Trigger a rebuild
              });
            },
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Dismissible(
                  key: Key(task.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    return await showDialog<bool>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('Delete Task'),
                                content: const Text(
                                  'Are you sure you want to delete this task?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                        ) ??
                        false;
                  },
                  onDismissed: (direction) async {
                    try {
                      await repository.deleteTask(task.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Task deleted')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to delete task: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: ListTile(
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration:
                            task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (task.description != null)
                          Text(
                            task.description!,
                            style: TextStyle(
                              decoration:
                                  task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                            ),
                          ),
                        Text(
                          'Due: ${task.dueDate.year}-${task.dueDate.month.toString().padLeft(2, '0')}-${task.dueDate.day.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color:
                                task.dueDate.isBefore(DateTime.now()) &&
                                        !task.isCompleted
                                    ? Colors.red
                                    : null,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!task.isSynced)
                          const Icon(Icons.sync_disabled, color: Colors.orange),
                        Checkbox(
                          value: task.isCompleted,
                          onChanged: (value) async {
                            if (value != null) {
                              try {
                                await repository.updateTask(
                                  task.copyWith(isCompleted: value),
                                );
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Failed to update task: $e',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                        ),
                      ],
                    ),
                    onTap: () async {
                      final updatedTask = await Navigator.push<Task?>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskFormScreen(task: task),
                        ),
                      );
                      if (updatedTask != null && mounted) {
                        setState(() {
                          // Trigger a rebuild to show updated task
                        });
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTask = await Navigator.push<Task?>(
            context,
            MaterialPageRoute(builder: (context) => const TaskFormScreen()),
          );
          if (newTask != null && mounted) {
            setState(() {
              // Trigger a rebuild to show new task
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
