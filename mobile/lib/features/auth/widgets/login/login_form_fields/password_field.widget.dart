import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth.provider.dart';
import '../../../../../shared/index.dart';
import '../../auth.widget.dart';

class PasswordField extends ConsumerWidget {
  final bool isDisabled;
  const PasswordField({super.key, required this.isDisabled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final password = ref.watch(
      loginFormProvider.select((state) => state.password),
    );
    final obscurePassword = ref.watch(
      loginFormProvider.select((state) => state.obscurePassword),
    );

    return AuthTextField(
      label: 'รหัสผ่าน',
      hintText: '••••••••••••••',
      obscureText: obscurePassword,
      value: password,
      onChanged: (value) =>
          ref.read(loginFormProvider.notifier).setPassword(value),
      isDisabled: isDisabled,
      suffixIcon: IconButton(
        icon: Icon(
          obscurePassword ? Icons.visibility_off : Icons.visibility,
          color: AppColors.primary,
        ),
        onPressed: isDisabled
            ? null
            : () => ref
                  .read(loginFormProvider.notifier)
                  .togglePasswordVisibility(),
      ),
    );
  }
}
