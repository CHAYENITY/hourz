import 'package:flutter/material.dart';
import 'package:hourz/shared/index.dart';

/// 🏷️ Task Status Badge Widget
class TaskStatusBadge extends StatelessWidget {
  final bool isCompleted;

  const TaskStatusBadge({super.key, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted ? AppColors.primary : AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isCompleted ? 'Done' : 'Pending',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
