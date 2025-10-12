import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/gestures.dart';

import 'package:hourz/shared/index.dart';

import '../../../providers/auth.provider.dart';
import '../terms_dialog.widget.dart';

class TermsCheckbox extends ConsumerWidget {
  final bool isDisabled;

  const TermsCheckbox({super.key, this.isDisabled = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agreeToTerms = ref.watch(
      registerFormProvider.select((state) => state.agreeToTerms),
    );
    final setAgreeToTerms = ref
        .read(registerFormProvider.notifier)
        .setAgreeToTerms;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.translate(
          offset: const Offset(-6, 0),
          child: Checkbox(
            value: agreeToTerms,
            onChanged: isDisabled
                ? null
                : (bool? newValue) =>
                      _handleCheckboxTap(context, newValue, setAgreeToTerms),
            activeColor: AppColors.background,
            checkColor: AppColors.mutedForeground,
            side: WidgetStateBorderSide.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const BorderSide(color: AppColors.muted);
              } else {
                return const BorderSide(color: AppColors.muted);
              }
            }),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: isDisabled
                ? null
                : () => _handleCheckboxTap(
                    context,
                    !agreeToTerms,
                    setAgreeToTerms,
                  ),
            child: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: RichText(
                text: TextSpan(
                  style: AppTheme.richText,
                  children: [
                    const TextSpan(text: 'ฉันได้อ่านและยอมรับ '),
                    TextSpan(
                      text: 'ข้อกำหนดและเงื่อนไข',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () =>
                            _showTermsDialog(context, setAgreeToTerms),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleCheckboxTap(
    BuildContext context,
    bool? newValue,
    void Function(bool) setAgreeToTerms,
  ) {
    if (newValue == true) {
      // Show terms dialog when trying to check the checkbox
      _showTermsDialog(context, setAgreeToTerms);
    } else {
      // Allow unchecking directly
      setAgreeToTerms(false);
    }
  }

  void _showTermsDialog(
    BuildContext context,
    void Function(bool) setAgreeToTerms,
  ) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return TermsDialog(
          onAccept: () {
            Navigator.of(context).pop();
            setAgreeToTerms(true);
          },
          onCancel: () {
            Navigator.of(context).pop();
            setAgreeToTerms(false);
          },
        );
      },
    );
  }
}
