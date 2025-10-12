import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../auth.widget.dart';

class NavigationToRegister extends StatelessWidget {
  const NavigationToRegister({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthNavigationLink(
      question: 'ยังไม่มีบัญชี?',
      linkText: 'มาลงทะเบียนเลย',
      onTap: () => context.goNamed('register'),
    );
  }
}
