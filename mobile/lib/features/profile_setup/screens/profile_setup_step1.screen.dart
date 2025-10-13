import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hourz/shared/index.dart';

import '../widgets/profile_setup_progress.widget.dart';
import '../widgets/profile_setup_step1/index.dart';

class ProfileSetupStep1Screen extends ConsumerStatefulWidget {
  const ProfileSetupStep1Screen({super.key});

  @override
  ConsumerState<ProfileSetupStep1Screen> createState() =>
      _ProfileSetupStep1ScreenState();
}

class _ProfileSetupStep1ScreenState
    extends ConsumerState<ProfileSetupStep1Screen> {
  @override
  Widget build(BuildContext context) {
    final isLoading =
        ref.watch(isLoadingProvider('profile-setup')) ||
        ref.watch(isLoadingProvider('upload-profile-image'));

    return CustomStatusBar(
      child: Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 16),

                        // Progress indicator
                        const ProfileSetupProgress(
                          currentStep: 1,
                          totalSteps: 3,
                        ),

                        const SizedBox(height: 36),

                        // Header
                        const Header(),

                        const SizedBox(height: 28),

                        // Profile Setup Form
                        Step1Form(isLoading: isLoading),
                      ],
                    ),
                  ),
                ),

                // Buttons
                NavigationButton(isLoading: isLoading),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
