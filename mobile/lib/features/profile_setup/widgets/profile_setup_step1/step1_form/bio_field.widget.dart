import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/profile_setup.provider.dart';

class BioField extends ConsumerWidget {
  final bool isDisabled;

  const BioField({super.key, required this.isDisabled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bio = ref.watch(profileSetupFormProvider.select((s) => s.bio));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('แนะนำตัวเอง', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: bio,
          decoration: const InputDecoration(
            hintText: 'ชอบช่วยเหลือเรื่องสัตว์เลี้ยงและงานสวน',
          ),
          onChanged: isDisabled
              ? null
              : (value) =>
                    ref.read(profileSetupFormProvider.notifier).setBio(value),
          enabled: !isDisabled,
        ),
      ],
    );
  }
}
