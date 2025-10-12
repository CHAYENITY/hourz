import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth.provider.dart';
import '../../../../shared/index.dart';
import '../auth.widget.dart';

class LoginButton extends ConsumerWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isValid = ref.watch(
      loginFormProvider.select((state) => state.isValid),
    );
    final isLoading = ref.watch(isLoadingProvider('auth-login'));

    return PrimaryButton(
      text: 'เข้าสู่ระบบ',
      onPressed: isValid
          ? () async {
              final isProfileSetup = await ref
                  .read(loginFormProvider.notifier)
                  .submit();
              if (context.mounted) {
                if (isProfileSetup) {
                  context.go(AppRoutePath.dashboard);
                } else {
                  context.go(AppRoutePath.profileSetup);
                }
              }
            }
          : null,
      isLoading: isLoading,
      isDisabled: !isValid,
    );
  }
}
