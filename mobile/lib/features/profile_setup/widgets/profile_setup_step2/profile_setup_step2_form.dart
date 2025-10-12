import 'package:flutter/material.dart';

import '../../models/profile_setup_model.dart';
import 'location_map_widget.dart';
import 'district_field.dart';
import 'province_field.dart';
import 'address_line_field.dart';

class ProfileSetupStep2Form extends StatelessWidget {
  final ProfileSetupModel state;
  final bool isDisabled;

  const ProfileSetupStep2Form({
    required this.state,
    required this.isDisabled,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Location Map
        const LocationMapWidget(),
        const SizedBox(height: 30),

        // Address
        const AddressLineField(),

        const SizedBox(height: 24),

        // Form fields
        const Row(
          children: [
            Expanded(child: DistrictField()),
            SizedBox(width: 16),
            Expanded(child: ProvinceField()),
          ],
        ),
      ],
    );
  }
}
