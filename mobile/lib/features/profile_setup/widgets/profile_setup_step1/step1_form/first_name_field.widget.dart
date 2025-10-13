import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/profile_setup.provider.dart';

class FirstNameField extends ConsumerWidget {
  final bool isDisabled;

  const FirstNameField({super.key, required this.isDisabled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstName = ref.watch(
      profileSetupFormProvider.select((s) => s.firstName),
    );
    final firstNameError = ref.watch(
      profileSetupFormProvider.select((s) => s.firstNameError),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ชื่อ', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: firstName,
          decoration: InputDecoration(
            hintText: 'เอโดวาวะ',
            errorText: firstNameError,
          ),
          onChanged: isDisabled
              ? null
              : (value) => ref
                    .read(profileSetupFormProvider.notifier)
                    .setFirstName(value),
          enabled: !isDisabled,
          validator: (_) => firstNameError,
        ),
      ],
    );
  }
}
