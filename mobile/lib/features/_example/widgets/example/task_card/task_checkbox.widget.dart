import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hourz/shared/index.dart';
import '../../../models/example.model.dart';
import '../../../providers/example.provider.dart';

/// ✅ Task Checkbox Widget (rebuilds only when toggled)
class TaskCheckbox extends ConsumerWidget {
  final Task task;
  final bool isDisabled;

  const TaskCheckbox({super.key, required this.task, required this.isDisabled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Checkbox(
      value: task.isCompleted,
      onChanged: isDisabled
          ? null
          : (value) {
              ref.read(taskListProvider.notifier).toggleTaskCompletion(task.id);
            },
      activeColor: AppColors.primary,
    );
  }
}
