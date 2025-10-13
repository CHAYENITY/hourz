import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/profile_setup.provider.dart';

class DistrictField extends ConsumerWidget {
  final bool isDisabled;
  const DistrictField({super.key, required this.isDisabled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final province = ref.watch(
      profileSetupFormProvider.select((s) => s.address?.province ?? ''),
    );
    final district = ref.watch(
      profileSetupFormProvider.select((s) => s.address?.district ?? ''),
    );
    final districtError = ref.watch(
      profileSetupFormProvider.select((s) => s.districtError),
    );

    final provinceListAsync = ref.watch(provinceListProvider);
    final provinceList = provinceListAsync.asData?.value ?? [];
    final selectedProvince = provinceList.firstWhere(
      (p) => p['name'] == province,
      orElse: () => {},
    );
    final provinceId = selectedProvince['id'] ?? '';

    final districtListAsync = provinceId.isNotEmpty
        ? ref.watch(districtListProvider(provinceId))
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('อำเภอ/เขต', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        if (provinceId.isEmpty)
          const Text(
            'กรุณาเลือกจังหวัดก่อน',
            style: TextStyle(color: Colors.grey),
          ),
        if (provinceId.isNotEmpty && districtListAsync != null)
          districtListAsync.when(
            data: (districtList) => DropdownButtonFormField<String>(
              initialValue: district.isNotEmpty ? district : null,
              items: districtList
                  .map(
                    (d) => DropdownMenuItem<String>(
                      value: d['name'],
                      child: Text(d['name'] ?? ''),
                    ),
                  )
                  .toList(),
              onChanged: isDisabled
                  ? null
                  : (value) {
                      ref
                          .read(profileSetupFormProvider.notifier)
                          .setAddress(district: value);
                    },
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                errorText: districtError,
                isDense: true,
              ),
              hint: const Text('เลือกอำเภอ/เขต'),
            ),
            loading: () => const CircularProgressIndicator(),
            error: (e, st) => Text('โหลดอำเภอ/เขตไม่สำเร็จ'),
          ),
      ],
    );
  }
}
