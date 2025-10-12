import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth.provider.dart';
import '../../../../shared/index.dart';
import '../auth.widget.dart';

class GoogleLoginButton extends ConsumerWidget {
  const GoogleLoginButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGoogleLoading = ref.watch(isLoadingProvider('auth-google'));
    final isLoginLoading = ref.watch(isLoadingProvider('auth-login'));

    return GoogleSignInButton(
      text: 'เข้าสู่ระบบด้วย Google',
      onPressed: () => ref.read(authProvider.notifier).loginWithGoogle(),
      isLoading: isGoogleLoading,
      isDisabled: isLoginLoading,
    );
  }
}
