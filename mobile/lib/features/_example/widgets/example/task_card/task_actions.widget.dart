import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hourz/shared/index.dart';
import '../../../models/example.model.dart';
import '../../../providers/example.provider.dart';

/// 🎬 Task Actions Widget
class TaskActions extends ConsumerWidget {
  final Task task;
  final bool isDisabled;

  const TaskActions({super.key, required this.task, required this.isDisabled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Edit button
        IconButton(
          onPressed: isDisabled
              ? null
              : () {
                  context.go(AppRoutePath.editTask, extra: task);
                },
          icon: const Icon(Icons.edit),
          iconSize: 20,
          tooltip: 'Edit Task',
          color: AppColors.primary,
        ),

        // Delete button
        IconButton(
          onPressed: isDisabled
              ? null
              : () {
                  _showDeleteConfirmation(context, ref);
                },
          icon: const Icon(Icons.delete),
          iconSize: 20,
          tooltip: 'Delete Task',
          color: AppColors.destructive,
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
