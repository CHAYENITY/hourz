import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hourz/shared/constants/app_routes.dart';
import '../providers/profile_setup_provider.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  final Map<String, String>? registrationData;
  const ProfileSetupScreen({super.key, this.registrationData});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  bool _navigated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_navigated) {
      // Reset state & set registration data
      ref.read(profileSetupProvider.notifier).reset();
      final data = widget.registrationData;
      if (data != null) {
        final email = data['email'];
        final password = data['password'];
        if (email != null && password != null) {
          ref
              .read(profileSetupProvider.notifier)
              .setRegistrationData(email, password);
        }
      }
      // Navigate only once
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.push(AppRoutePath.profileSetupStep1);
      });
      _navigated = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
