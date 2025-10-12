import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hourz/shared/index.dart';

import '../../providers/auth.provider.dart';
import '../auth.widget.dart';

class GoogleRegisterButton extends ConsumerWidget {
  const GoogleRegisterButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGoogleLoading = ref.watch(isLoadingProvider('auth-google'));
    final isRegisterLoading = ref.watch(isLoadingProvider('auth-register'));

    return GoogleSignInButton(
      text: 'ลงทะเบียนด้วย Google',
      onPressed: () => ref.read(authProvider.notifier).loginWithGoogle(),
      isLoading: isGoogleLoading,
      isDisabled: isRegisterLoading,
    );
  }
}
