import 'package:flutter/material.dart';

import 'location_map.widget.dart';
import 'district_field.widget.dart';
import 'province_field.widget.dart';
import 'address_line_field.widget.dart';

class Step2Form extends StatelessWidget {
  final bool isLoading;

  const Step2Form({super.key, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TODO: Location Map
        LocationMap(isDisabled: isLoading),
        const SizedBox(height: 30),

        // Address Line
        AddressLineField(isDisabled: isLoading),

        const SizedBox(height: 24),

        // District & Province
        Row(
          children: [
            Expanded(child: DistrictField(isDisabled: isLoading)),
            const SizedBox(width: 16),
            Expanded(child: ProvinceField(isDisabled: isLoading)),
          ],
        ),
      ],
    );
  }
}
