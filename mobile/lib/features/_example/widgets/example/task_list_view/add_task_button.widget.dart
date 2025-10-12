import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hourz/shared/index.dart';

import '../../../providers/example.provider.dart';

/// ➕ Add Task Button Widget (rebuilds only when loading states change)
class AddTaskButton extends ConsumerWidget {
  const AddTaskButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isTasksLoadingProvider);
    final isActionLoading = ref.watch(isTaskActionLoadingProvider);

    return FloatingActionButton(
      onPressed: isLoading || isActionLoading
          ? null
          : () {
              context.go(AppRoutePath.addTask);
            },
      tooltip: 'Add Task',
      child: const Icon(Icons.add),
    );
  }
}
