import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hourz/shared/index.dart';

import '../widgets/register/index.dart';
import '../widgets/auth.widget.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    return const CustomStatusBar(
      child: Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Header
                    Center(
                      child: AuthHeader(title: 'เพื่อนที่พร้อมช่วย รอคุณอยู่!'),
                    ),

                    SizedBox(height: 32),

                    // Register Form
                    RegisterFormFields(),

                    SizedBox(height: 24),

                    // Register Button
                    RegisterButton(),

                    SizedBox(height: 8),

                    // Google Sign In Button
                    GoogleRegisterButton(),

                    SizedBox(height: 32),

                    // Navigation to Login
                    NavigationToLogin(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
