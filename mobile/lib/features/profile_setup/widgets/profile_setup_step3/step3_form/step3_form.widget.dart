import 'package:flutter/material.dart';

// import 'citizen_id_image_picker.widget.dart';
import 'privacy_warning.widget.dart';

class Step3Form extends StatelessWidget {
  final bool isDisabled;

  const Step3Form({super.key, required this.isDisabled});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Citizen ID Upload
        // const CitizenIdImagePicker(),

        const SizedBox(height: 30),

        // Privacy Warning
        const PrivacyWarning(),
      ],
    );
  }
}
