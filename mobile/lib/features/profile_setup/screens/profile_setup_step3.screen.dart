import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hourz/shared/index.dart';

import '../widgets/profile_setup_progress.widget.dart';
import '../widgets/profile_setup_step3/index.dart';

class ProfileSetupStep3Screen extends ConsumerStatefulWidget {
  const ProfileSetupStep3Screen({super.key});

  @override
  ConsumerState<ProfileSetupStep3Screen> createState() =>
      _ProfileSetupStep3ScreenState();
}

class _ProfileSetupStep3ScreenState
    extends ConsumerState<ProfileSetupStep3Screen> {
  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingProvider('submit-profile'));

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
                        const ProfileSetupProgress(
                          currentStep: 3,
                          totalSteps: 3,
                        ),

                        const SizedBox(height: 36),

                        const Step3Header(),

                        const SizedBox(height: 28),

                        Step3Form(isDisabled: isLoading),
                      ],
                    ),
                  ),
                ),

                Step3NavigationButton(isLoading: isLoading),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
