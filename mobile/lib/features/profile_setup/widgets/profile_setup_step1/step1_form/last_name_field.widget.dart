import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/profile_setup.provider.dart';

class LastNameField extends ConsumerWidget {
  final bool isDisabled;

  const LastNameField({super.key, required this.isDisabled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastName = ref.watch(
      profileSetupFormProvider.select((s) => s.lastName),
    );
    final lastNameError = ref.watch(
      profileSetupFormProvider.select((s) => s.lastNameError),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('นามสกุล', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: lastName,
          decoration: InputDecoration(
            hintText: 'โคนัน',
            errorText: lastNameError,
          ),
          onChanged: isDisabled
              ? null
              : (value) => ref
                    .read(profileSetupFormProvider.notifier)
                    .setLastName(value),
          enabled: !isDisabled,
          validator: (_) => lastNameError,
        ),
      ],
    );
  }
}
