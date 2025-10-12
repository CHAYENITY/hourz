import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/example.provider.dart';
import '../widgets/example/index.dart';

/// ➕ Add Task Screen - หน้าจอเพิ่ม task ใหม่
class AddTaskScreen extends ConsumerWidget {
  const AddTaskScreen({super.key});

  Future<void> _createTask(BuildContext context, WidgetRef ref) async {
    final formState = ref.read(taskFormProvider);
    await ref
        .read(taskListProvider.notifier)
        .createTask(
          title: formState.title.trim(),
          description: formState.description.trim(),
        );

    // Navigate back on success
    if (context.mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('➕ Add Task')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TaskForm(
          title: 'Create Task',
          onSubmit: () => _createTask(context, ref),
        ),
      ),
    );
  }
}
