import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hourz/shared/index.dart';
import '../../providers/profile_setup_provider.dart';

class BioField extends ConsumerWidget {
  const BioField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ Use .select() for better performance
    final bio = ref.watch(profileSetupProvider.select((s) => s.bio));
    final isDisabled = ref.watch(isLoadingProvider('submit-profile'));

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
          maxLines: 3,
          onChanged: isDisabled
              ? null
              : (value) => ref
                    .read(profileSetupProvider.notifier)
                    .updateBasicInfo(bio: value),
          enabled: !isDisabled,
        ),
      ],
    );
  }
}
