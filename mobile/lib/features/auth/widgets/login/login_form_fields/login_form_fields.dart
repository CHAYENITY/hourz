import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hourz/shared/index.dart';

import '../../../providers/auth.provider.dart';
import '../../auth.widget.dart';
import 'password_field.widget.dart';

class LoginFormFields extends ConsumerWidget {
  const LoginFormFields({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.watch(loginFormProvider.select((state) => state.email));
    final isLoading = ref.watch(isLoadingProvider('auth-login'));
    final isGoogleLoading = ref.watch(isLoadingProvider('auth-google'));
    final isDisabled = isLoading || isGoogleLoading;

    return Column(
      children: [
        // Email Field
        AuthTextField(
          label: 'อีเมล',
          hintText: 'user@chavenity.com',
          keyboardType: TextInputType.emailAddress,
          value: email,
          onChanged: (value) =>
              ref.read(loginFormProvider.notifier).setEmail(value),
          isDisabled: isDisabled,
        ),
        const SizedBox(height: 24),
        // Password Field
        PasswordField(isDisabled: isDisabled),
      ],
    );
  }
}
