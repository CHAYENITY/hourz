import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hourz/shared/index.dart';
import '../models/example.model.dart';
import '../providers/example.provider.dart';
import '../widgets/example/index.dart';

/// ✏️ Edit Task Screen - หน้าจอแก้ไข task
class EditTaskScreen extends ConsumerWidget {
  final Task task;

  const EditTaskScreen({super.key, required this.task});

  Future<void> _updateTask(BuildContext context, WidgetRef ref) async {
    final formState = ref.read(taskFormProvider);
    final updatedTask = task.copyWith(
      title: formState.title.trim(),
      description: formState.description.trim(),
    );
    await ref.read(taskListProvider.notifier).updateTask(updatedTask);

    // Navigate back on success
    if (context.mounted) {
      context.pop();
    }
  }

  void _deleteTask(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
              ref.read(taskListProvider.notifier).deleteTask(task.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.destructive),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('✏️ Edit Task'),
        actions: [
          IconButton(
            onPressed: () => _deleteTask(context, ref),
            icon: const Icon(Icons.delete),
            color: AppColors.destructive,
            tooltip: 'Delete Task',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TaskForm(
          initialTask: task,
          title: 'Update Task',
          onSubmit: () => _updateTask(context, ref),
        ),
      ),
    );
  }
}
