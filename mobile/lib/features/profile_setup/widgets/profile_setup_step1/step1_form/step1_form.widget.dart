import 'package:flutter/material.dart';

import 'first_name_field.widget.dart';
import 'last_name_field.widget.dart';
import 'bio_field.widget.dart';
import 'phone_number_field.widget.dart';
import 'additional_contact_field.widget.dart';
import 'profile_image_picker.widget.dart';

class Step1Form extends StatelessWidget {
  final bool isLoading;

  const Step1Form({super.key, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile Image
        ProfileImagePicker(isDisabled: isLoading),
        const SizedBox(height: 28),
        // First Name & Last Name
        Row(
          children: [
            Expanded(child: FirstNameField(isDisabled: isLoading)),
            SizedBox(width: 28),
            Expanded(child: LastNameField(isDisabled: isLoading)),
          ],
        ),
        const SizedBox(height: 28),
        PhoneNumberField(isDisabled: isLoading),
        const SizedBox(height: 28),
        BioField(isDisabled: isLoading),
        const SizedBox(height: 28),
        AdditionalContactField(isDisabled: isLoading),
      ],
    );
  }
}
