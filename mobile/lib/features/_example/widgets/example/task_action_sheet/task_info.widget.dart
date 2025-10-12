import 'package:flutter/material.dart';
import 'package:hourz/shared/index.dart';
import '../../../models/example.model.dart';

/// 📝 Task Info Widget (static)
class TaskInfo extends StatelessWidget {
  final Task task;

  const TaskInfo({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: task.isCompleted
                ? AppColors.primary.withAlpha(20)
                : AppColors.secondary.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            task.isCompleted
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: task.isCompleted ? AppColors.primary : AppColors.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (task.description.isNotEmpty)
                Text(
                  task.description,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
