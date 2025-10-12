import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/profile_setup_provider.dart';
import '../../../../shared/index.dart';

class LastNameField extends ConsumerWidget {
  const LastNameField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ Use .select() for better performance
    final lastName = ref.watch(profileSetupProvider.select((s) => s.lastName));
    final isDisabled = ref.watch(isLoadingProvider('submit-profile'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('นามสกุล', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: lastName,
          decoration: const InputDecoration(hintText: 'โคนัน'),
          onChanged: isDisabled
              ? null
              : (value) => ref
                    .read(profileSetupProvider.notifier)
                    .updateBasicInfo(lastName: value),
          enabled: !isDisabled,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'กรุณากรอกนามสกุล';
            }
            return null;
          },
        ),
      ],
    );
  }
}
