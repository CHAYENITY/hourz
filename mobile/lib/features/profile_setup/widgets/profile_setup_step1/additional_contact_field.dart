import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hourz/shared/index.dart';
import '../../providers/profile_setup_provider.dart';

class AdditionalContactField extends ConsumerWidget {
  const AdditionalContactField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ Use .select() for better performance
    final additionalContact = ref.watch(
      profileSetupProvider.select((s) => s.additionalContact),
    );
    final isDisabled = ref.watch(isLoadingProvider('submit-profile'));

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
                    .read(profileSetupProvider.notifier)
                    .updateBasicInfo(additionalContact: value),
          enabled: !isDisabled,
        ),
      ],
    );
  }
}
