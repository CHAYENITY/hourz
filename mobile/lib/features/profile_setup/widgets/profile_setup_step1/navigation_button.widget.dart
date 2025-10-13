import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:hourz/shared/index.dart';

import '../../providers/profile_setup.provider.dart';

class NavigationButton extends ConsumerWidget {
  final bool isLoading;

  const NavigationButton({super.key, required this.isLoading});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isStep1Valid = ref.watch(
      profileSetupFormProvider.select((state) => state.isStep1Valid),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading || !Navigator.canPop(context)
                  ? null
                  : () => context.pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'ย้อนกลับ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: (isLoading || !isStep1Valid)
                  ? null
                  : () => _handleNext(context, ref),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'ถัดไป',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleNext(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(profileSetupFormProvider.notifier);
    final isValid = await notifier.validateStep1();
    if (context.mounted && isValid) {
      context.push(AppRoutePath.profileSetupStep2);
    }
  }
}
