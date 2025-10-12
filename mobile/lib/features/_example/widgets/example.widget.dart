import 'package:flutter/material.dart';
import 'package:hourz/shared/index.dart';
import 'package:hourz/shared/utils/common.util.dart' as app_utils;
import '../models/example.model.dart';
import 'example/task_card/index.dart';
import 'example/task_action_sheet/index.dart';

/// 🎴 Task Card Widget - แสดงข้อมูล task ในรูปแบบ card
class TaskCard extends StatelessWidget {
  final Task task;
  final bool isDisabled;

  const TaskCard({super.key, required this.task, this.isDisabled = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: task.isCompleted
            ? AppColors.primary.withAlpha(10)
            : theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: task.isCompleted
              ? AppColors.primary.withAlpha(30)
              : Colors.grey.withAlpha(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: isDisabled ? null : () => _showTaskActions(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with title and status
              Row(
                children: [
                  // Completion checkbox (separate widget for rebuild optimization)
                  TaskCheckbox(task: task, isDisabled: isDisabled),

                  // Title
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: task.isCompleted ? Colors.grey.shade600 : null,
                      ),
                    ),
                  ),

                  // Status badge
                  TaskStatusBadge(isCompleted: task.isCompleted),
                ],
              ),

              const SizedBox(height: 8),

              // Description
              if (task.description.isNotEmpty) ...[
                Text(
                  task.description,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
              ],

              // Footer with date and actions
              Row(
                children: [
                  // Created date
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    app_utils.DateUtils.formatDateTime(task.createdAt),
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),

                  // Completed date (if completed)
                  if (task.isCompleted && task.completedAt != null) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Done ${app_utils.DateUtils.formatDateTime(task.completedAt!)}',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],

                  const Spacer(),

                  // Action buttons (separate widget)
                  TaskActions(task: task, isDisabled: isDisabled),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show task action bottom sheet
  void _showTaskActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => TaskActionSheet(task: task),
    );
  }
}

/// 📋 Task Action Sheet - แสดง actions สำหรับ task
class TaskActionSheet extends StatelessWidget {
  final Task task;

  const TaskActionSheet({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 16),

          // Task info (static)
          TaskInfo(task: task),

          const SizedBox(height: 24),

          // Actions (separate widget with ref)
          ActionButtons(task: task),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
