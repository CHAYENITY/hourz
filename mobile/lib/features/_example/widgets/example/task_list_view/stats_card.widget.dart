import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hourz/shared/index.dart';

import '../../../providers/example.provider.dart';

/// 📊 Stats Card Widget (rebuilds only when stats change)
class StatsCard extends ConsumerWidget {
  const StatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ⚡ Watch only the stats - no rebuild when list items change
    final totalCount = ref.watch(taskStatsProvider.select((s) => s['total']!));
    final completedCount = ref.watch(
      taskStatsProvider.select((s) => s['completed']!),
    );
    final pendingCount = ref.watch(
      taskStatsProvider.select((s) => s['pending']!),
    );

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          StatItem(
            icon: Icons.list_alt,
            label: 'Total',
            value: totalCount.toString(),
            color: AppColors.primary,
          ),
          StatItem(
            icon: Icons.check_circle,
            label: 'Completed',
            value: completedCount.toString(),
            color: AppColors.primary,
          ),
          StatItem(
            icon: Icons.radio_button_unchecked,
            label: 'Pending',
            value: pendingCount.toString(),
            color: AppColors.secondaryForeground,
          ),
        ],
      ),
    );
  }
}

/// 📊 Statistics Item Widget (static, never rebuilds unless parent changes)
class StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const StatItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
