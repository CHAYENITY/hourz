import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/profile_setup.provider.dart';

class AddressLineField extends ConsumerWidget {
  final bool isDisabled;

  const AddressLineField({super.key, required this.isDisabled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressLine = ref.watch(
      profileSetupFormProvider.select((s) => s.address?.addressLine ?? ''),
    );
    final addressLineError = ref.watch(
      profileSetupFormProvider.select((s) => s.addressLineError),
    );

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
          decoration: InputDecoration(
            hintText: 'หมู่ 2 บล็อก 21 เมืองเบกะ จังหวัดทตโตริ ประเทศญี่ปุ่น',
            errorText: addressLineError,
          ),
          maxLines: 1,
          onChanged: isDisabled
              ? null
              : (value) => ref
                    .read(profileSetupFormProvider.notifier)
                    .setAddress(addressLine: value),
          enabled: !isDisabled,
          validator: (_) => addressLineError,
        ),
      ],
    );
  }
}
