import 'package:flutter/material.dart';

import 'package:hourz/shared/index.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'ยืนยันตำแหน่งพื้นที่',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.mutedForeground,
            ),
          ),
        ),

        const SizedBox(height: 4),

        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'กำหนดพื้นที่สำหรับการใช้บริการเลย',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
