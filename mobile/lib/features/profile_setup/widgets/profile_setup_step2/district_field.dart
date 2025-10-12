import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hourz/shared/index.dart';
import '../../providers/profile_setup_provider.dart';

class DistrictField extends ConsumerWidget {
  const DistrictField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ Use .select() for better performance
    final district = ref.watch(
      profileSetupProvider.select((s) => s.address?.district ?? ''),
    );
    final isDisabled = ref.watch(isLoadingProvider('submit-profile'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('อำเภอ/เขต', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: district,
          decoration: const InputDecoration(hintText: 'หาดใหญ่'),
          onChanged: isDisabled
              ? null
              : (value) => ref
                    .read(profileSetupProvider.notifier)
                    .updateAddress(district: value),
          enabled: !isDisabled,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'กรุณากรอกอำเภอ/เขต';
            }
            return null;
          },
        ),
      ],
    );
  }
}
