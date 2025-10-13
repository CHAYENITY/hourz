import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/profile_setup.provider.dart';

class AdditionalContactField extends ConsumerWidget {
  final bool isDisabled;

  const AdditionalContactField({super.key, required this.isDisabled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final additionalContact = ref.watch(
      profileSetupFormProvider.select((s) => s.additionalContact),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ช่องทางติดต่อเพิ่มเติม',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: additionalContact,
          decoration: const InputDecoration(
            hintText: 'Facebook: Hourz Official / LineID: @hourzofficial',
          ),
          onChanged: isDisabled
              ? null
              : (value) => ref
                    .read(profileSetupFormProvider.notifier)
                    .setAdditionalContact(value),
          enabled: !isDisabled,
        ),
      ],
    );
  }
}
