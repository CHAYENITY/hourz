import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/auth.provider.dart';
import '../../auth.widget.dart';

class EmailField extends ConsumerWidget {
  final bool isDisabled;

  const EmailField({super.key, required this.isDisabled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.watch(
      registerFormProvider.select((state) => state.email),
    );
    final emailError = ref.watch(
      registerFormProvider.select((state) => state.emailError),
    );
    return AuthTextField(
      label: 'อีเมล',
      hintText: 'user@chavenity.com',
      keyboardType: TextInputType.emailAddress,
      value: email,
      onChanged: (value) =>
          ref.read(registerFormProvider.notifier).setEmail(value),
      isDisabled: isDisabled,
      errorText: emailError,
    );
  }
}
