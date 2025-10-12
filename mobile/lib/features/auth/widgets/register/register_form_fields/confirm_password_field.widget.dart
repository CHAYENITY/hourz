import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hourz/shared/index.dart';

import '../../../providers/auth.provider.dart';
import '../../auth.widget.dart';

class ConfirmPasswordField extends ConsumerWidget {
  final bool isDisabled;

  const ConfirmPasswordField({super.key, required this.isDisabled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final confirmPassword = ref.watch(
      registerFormProvider.select((state) => state.confirmPassword),
    );
    final obscureConfirmPassword = ref.watch(
      registerFormProvider.select((state) => state.obscureConfirmPassword),
    );
    final confirmPasswordError = ref.watch(
      registerFormProvider.select((state) => state.confirmPasswordError),
    );

    return AuthTextField(
      label: 'ยืนยันรหัสผ่าน',
      hintText: '••••••••••••••',
      obscureText: obscureConfirmPassword,
      value: confirmPassword,
      onChanged: (value) =>
          ref.read(registerFormProvider.notifier).setConfirmPassword(value),
      isDisabled: isDisabled,
      suffixIcon: IconButton(
        icon: Icon(
          obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
          color: AppColors.primary,
        ),
        onPressed: isDisabled
            ? null
            : () => ref
                  .read(registerFormProvider.notifier)
                  .toggleConfirmPasswordVisibility(),
      ),
      errorText: confirmPasswordError,
    );
  }
}
