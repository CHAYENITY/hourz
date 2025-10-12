import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../auth.widget.dart';

class NavigationToLogin extends StatelessWidget {
  const NavigationToLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthNavigationLink(
      question: 'มีบัญชีแล้ว?',
      linkText: 'เข้าสู่ระบบเลย',
      onTap: () => context.goNamed('login'),
    );
  }
}
