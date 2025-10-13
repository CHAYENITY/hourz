import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/profile_setup.provider.dart';

class PhoneNumberField extends ConsumerWidget {
  final bool isDisabled;

  const PhoneNumberField({super.key, required this.isDisabled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phoneNumber = ref.watch(
      profileSetupFormProvider.select((s) => s.phoneNumber),
    );
    final phoneNumberError = ref.watch(
      profileSetupFormProvider.select((s) => s.phoneNumberError),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('เบอร์โทรศัพท์', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: phoneNumber,
          decoration: InputDecoration(
            hintText: '0XX-XXX-XXXX',
            // errorText: phoneNumberError,
          ),
          keyboardType: TextInputType.phone,
          onChanged: isDisabled
              ? null
              : (value) => ref
                    .read(profileSetupFormProvider.notifier)
                    .setPhoneNumber(value),
          enabled: !isDisabled,
          validator: (_) => phoneNumberError,
        ),
      ],
    );
  }
}
