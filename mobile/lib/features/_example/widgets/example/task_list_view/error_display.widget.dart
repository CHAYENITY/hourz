import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:hourz/shared/index.dart';

/// ⚠️ Error Display Widget (rebuilds only when error changes)
class ErrorDisplay extends ConsumerWidget {
  const ErrorDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final currentError = ref.watch(errorProvider);

    // if (currentError == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Error occurred',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                  ),
                ),
                // Text(
                //   currentError.message,
                //   style: TextStyle(color: Colors.red.shade700),
                // ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            color: Colors.red.shade600,
            onPressed: () {
              // ref.read(errorProvider.notifier).clearError();
            },
          ),
        ],
      ),
    );
  }
}
