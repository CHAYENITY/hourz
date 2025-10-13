import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/profile_setup.provider.dart';

class ProvinceField extends ConsumerWidget {
  final bool isDisabled;
  const ProvinceField({super.key, required this.isDisabled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final province = ref.watch(
      profileSetupFormProvider.select((s) => s.address?.province ?? ''),
    );
    final provinceError = ref.watch(
      profileSetupFormProvider.select((s) => s.provinceError),
    );
    final provinceListAsync = ref.watch(provinceListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('จังหวัด', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        provinceListAsync.when(
          data: (provinceList) => DropdownButtonFormField<String>(
            initialValue: province.isNotEmpty ? province : null,
            items: provinceList
                .map(
                  (p) => DropdownMenuItem<String>(
                    value: p['name'],
                    child: Text(p['name'] ?? ''),
                  ),
                )
                .toList(),
            onChanged: isDisabled
                ? null
                : (value) {
                    final selected = provinceList.firstWhere(
                      (p) => p['name'] == value,
                      orElse: () => {},
                    );
                    ref
                        .read(profileSetupFormProvider.notifier)
                        .setAddress(province: selected['name'], district: '');
                  },
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              errorText: provinceError,
              isDense: true,
            ),
            hint: const Text('เลือกจังหวัด'),
          ),
          loading: () => const CircularProgressIndicator(),
          error: (e, st) => Text('โหลดจังหวัดไม่สำเร็จ'),
        ),
      ],
    );
  }
}
