import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hourz/shared/index.dart';

import '../widgets/login/index.dart';
import '../widgets/auth.widget.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomStatusBar(
      child: const Scaffold(
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
                    Center(child: AuthHeader(title: 'ยินดีต้อนรับกลับมา!')),

                    SizedBox(height: 32),

                    // Login Form
                    LoginFormFields(),

                    SizedBox(height: 24),

                    // Login Button
                    LoginButton(),

                    SizedBox(height: 8),

                    // Google Sign In Button
                    GoogleLoginButton(),

                    SizedBox(height: 32),

                    // Navigation to Register
                    NavigationToRegister(),
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
