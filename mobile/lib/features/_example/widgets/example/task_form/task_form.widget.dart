import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/example.model.dart';
import '../../../providers/example.provider.dart';

/// 📝 Task Form Widget - สำหรับการเพิ่ม/แก้ไข task (uses taskFormProvider)
class TaskForm extends ConsumerStatefulWidget {
  final Task? initialTask;
  final String title;
  final void Function() onSubmit;

  const TaskForm({
    super.key,
    this.initialTask,
    required this.title,
    required this.onSubmit,
  });

  @override
  ConsumerState<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends ConsumerState<TaskForm> {
  @override
  void initState() {
    super.initState();
    // Initialize form state after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialTask != null) {
        ref
            .read(taskFormProvider.notifier)
            .setInitialValues(widget.initialTask!);
      } else {
        ref.read(taskFormProvider.notifier).reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ⚡ Use .select() for specific fields - prevents unnecessary rebuilds
    final title = ref.watch(taskFormProvider.select((s) => s.title));
    final description = ref.watch(
      taskFormProvider.select((s) => s.description),
    );
    final isValid = ref.watch(taskFormProvider.select((s) => s.isValid));
    final isLoading = ref.watch(isTaskActionLoadingProvider);

    return Column(
      children: [
        // Loading indicator
        if (isLoading) const LinearProgressIndicator(),

        const SizedBox(height: 16),

        // Title field
        TextFormField(
          initialValue: title,
          decoration: const InputDecoration(
            labelText: 'Title *',
            hintText: 'Enter task title',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.title),
          ),
          onChanged: (value) {
            ref.read(taskFormProvider.notifier).setTitle(value);
          },
          textInputAction: TextInputAction.next,
          enabled: !isLoading,
        ),

        const SizedBox(height: 16),

        // Description field
        TextFormField(
          initialValue: description,
          decoration: const InputDecoration(
            labelText: 'Description *',
            hintText: 'Enter task description',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.description),
          ),
          onChanged: (value) {
            ref.read(taskFormProvider.notifier).setDescription(value);
          },
          maxLines: 3,
          textInputAction: TextInputAction.done,
          enabled: !isLoading,
          onFieldSubmitted: (_) => isValid ? widget.onSubmit() : null,
        ),

        const SizedBox(height: 24),

        // Submit button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isValid && !isLoading ? widget.onSubmit : null,
            icon: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(
              isLoading
                  ? (widget.initialTask != null ? 'Updating...' : 'Creating...')
                  : widget.title,
            ),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
          ),
        ),
      ],
    );
  }
}
