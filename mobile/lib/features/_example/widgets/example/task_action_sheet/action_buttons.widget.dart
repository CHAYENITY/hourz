import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hourz/shared/index.dart';
import '../../../models/example.model.dart';
import '../../../providers/example.provider.dart';

/// 🎬 Action Buttons Widget
class ActionButtons extends ConsumerWidget {
  final Task task;

  const ActionButtons({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Toggle completion
        ListTile(
          leading: Icon(
            task.isCompleted ? Icons.undo : Icons.check_circle,
            color: task.isCompleted ? AppColors.secondary : AppColors.primary,
          ),
          title: Text(
            task.isCompleted ? 'Mark as Pending' : 'Mark as Complete',
          ),
          onTap: () {
            Navigator.pop(context);
            ref.read(taskListProvider.notifier).toggleTaskCompletion(task.id);
          },
        ),

        // Edit
        ListTile(
          leading: Icon(Icons.edit, color: AppColors.primary),
          title: const Text('Edit Task'),
          onTap: () {
            Navigator.pop(context);
            context.go(AppRoutePath.editTask, extra: task);
          },
        ),

        // Delete
        ListTile(
          leading: Icon(Icons.delete, color: AppColors.destructive),
          title: const Text('Delete Task'),
          onTap: () {
            Navigator.pop(context);
            _showDeleteConfirmation(context, ref);
          },
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
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
              ref.read(taskListProvider.notifier).deleteTask(task.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.destructive),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
