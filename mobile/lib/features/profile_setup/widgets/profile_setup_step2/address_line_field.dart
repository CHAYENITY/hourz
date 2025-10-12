import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/profile_setup_provider.dart';
import '../../../../shared/index.dart';

class AddressLineField extends ConsumerWidget {
  const AddressLineField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ Use .select() for better performance
    final addressLine = ref.watch(
      profileSetupProvider.select((s) => s.address?.addressLine ?? ''),
    );
    final isDisabled = ref.watch(isLoadingProvider('submit-profile'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ที่อยู่ (กรอกด้วยตนเอง)',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: addressLine,
          decoration: const InputDecoration(
            hintText: 'หมู่ 2 บล็อก 21 เมืองเบกะ จังหวัดทตโตริ ประเทศญี่ปุ่น',
          ),
          maxLines: 2,
          onChanged: isDisabled
              ? null
              : (value) => ref
                    .read(profileSetupProvider.notifier)
                    .updateAddress(addressLine: value),
          enabled: !isDisabled,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'กรุณากรอกที่อยู่';
            }
            return null;
          },
        ),
      ],
    );
  }
}
