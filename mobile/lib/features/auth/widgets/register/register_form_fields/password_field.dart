import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hourz/shared/index.dart';

import '../../../providers/auth.provider.dart';
import '../../auth.widget.dart';

class PasswordField extends ConsumerWidget {
  final bool isDisabled;

  const PasswordField({super.key, required this.isDisabled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final password = ref.watch(
      registerFormProvider.select((state) => state.password),
    );
    final obscurePassword = ref.watch(
      registerFormProvider.select((state) => state.obscurePassword),
    );
    final passwordError = ref.watch(
      registerFormProvider.select((state) => state.passwordError),
    );

    return AuthTextField(
      label: 'รหัสผ่าน',
      hintText: '••••••••••••••',
      obscureText: obscurePassword,
      value: password,
      onChanged: (value) =>
          ref.read(registerFormProvider.notifier).setPassword(value),
      isDisabled: isDisabled,
      suffixIcon: IconButton(
        icon: Icon(
          obscurePassword ? Icons.visibility_off : Icons.visibility,
          color: AppColors.primary,
        ),
        onPressed: isDisabled
            ? null
            : () => ref
                  .read(registerFormProvider.notifier)
                  .togglePasswordVisibility(),
      ),
      errorText: passwordError,
    );
  }
}
