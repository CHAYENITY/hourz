import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hourz/shared/index.dart';
import 'email_field.widget.dart';
import 'password_field.dart';
import 'confirm_password_field.widget.dart';
import 'term.checkbox.widget.dart';

class RegisterFormFields extends ConsumerWidget {
  const RegisterFormFields({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isLoadingProvider('auth-register'));
    final isGoogleLoading = ref.watch(isLoadingProvider('auth-google'));
    final isDisabled = isLoading || isGoogleLoading;

    return Column(
      children: [
        // Email Field
        EmailField(isDisabled: isDisabled),

        const SizedBox(height: 24),

        // Password Field
        PasswordField(isDisabled: isDisabled),

        const SizedBox(height: 24),

        // Confirm Password Field
        ConfirmPasswordField(isDisabled: isDisabled),

        const SizedBox(height: 24),

        // Terms Checkbox
        TermsCheckbox(isDisabled: isDisabled),
      ],
    );
  }
}
