import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hourz/shared/index.dart';

import '../widgets/profile_setup_progress.widget.dart';
import '../widgets/profile_setup_step2/index.dart';

class ProfileSetupStep2Screen extends ConsumerStatefulWidget {
  const ProfileSetupStep2Screen({super.key});

  @override
  ConsumerState<ProfileSetupStep2Screen> createState() =>
      _ProfileSetupStep2ScreenState();
}

class _ProfileSetupStep2ScreenState
    extends ConsumerState<ProfileSetupStep2Screen> {
  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingProvider('profile-setup'));

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
                          currentStep: 2,
                          totalSteps: 3,
                        ),

                        const SizedBox(height: 36),

                        // Header
                        const Header(),

                        const SizedBox(height: 28),

                        // Profile Setup Form
                        Step2Form(isLoading: isLoading),
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
