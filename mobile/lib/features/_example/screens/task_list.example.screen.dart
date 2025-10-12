import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hourz/shared/index.dart';

import '../providers/example.provider.dart';
import '../widgets/example/index.dart';

/// 📋 Task List Screen - หน้าจอหลักสำหรับแสดงรายการ tasks
class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  @override
  void initState() {
    super.initState();
    // โหลด tasks เมื่อเข้าหน้า
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(taskListProvider.notifier).loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    // ⚡ Use derived providers - rebuilds only when specific values change
    final isLoading = ref.watch(isTasksLoadingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📋 Tasks'),
        actions: [
          // Theme toggle button
          IconButton(
            icon: const Icon(Icons.brightness_6),
            tooltip: 'Toggle Theme',
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Tasks',
            onPressed: isLoading
                ? null
                : () {
                    ref.read(taskListProvider.notifier).refreshTasks();
                  },
          ),
        ],
      ),
      body: Column(
        children: [
          // Error display (rebuilds only when error changes)
          const ErrorDisplay(),

          // Task Statistics Card (rebuilds only when stats change)
          const StatsCard(),

          // Loading indicator
          if (isLoading) const LinearProgressIndicator(),

          // Task List (rebuilds only when list changes)
          const Expanded(child: TaskListView()),
        ],
      ),
      floatingActionButton: const AddTaskButton(),
    );
  }
}
