import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import 'package:hourz/features/auth/providers/auth.provider.dart';
import 'package:hourz/shared/constants/app_routes.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final registerState = ref.read(registerFormProvider);
      final hasEmail = registerState.email.isNotEmpty;
      final hasPassword = registerState.password.isNotEmpty;
      if (!mounted) return;
      if (hasEmail && hasPassword) {
        context.push(AppRoutePath.profileSetupStep1);
      } else {
        context.go(AppRoutePath.register);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
