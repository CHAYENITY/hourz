import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import 'package:hourz/shared/index.dart';

import '../../providers/auth.provider.dart';
import '../auth.widget.dart';

class RegisterButton extends ConsumerWidget {
  const RegisterButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isValid = ref.watch(
      registerFormProvider.select((state) => state.isValid),
    );
    final isLoading = ref.watch(isLoadingProvider('auth-register'));

    return PrimaryButton(
      text: 'ถัดไป',
      onPressed: isValid
          ? () async {
              final success = await ref
                  .read(registerFormProvider.notifier)
                  .submit();
              if (success && context.mounted) {
                context.push(AppRoutePath.profileSetupStep1);
              }
            }
          : null,
      isLoading: isLoading,
      isDisabled: !isValid,
    );
  }
}
