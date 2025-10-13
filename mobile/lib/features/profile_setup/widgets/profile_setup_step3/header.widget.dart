import 'package:flutter/material.dart';

import 'package:hourz/shared/index.dart';

class Step3Header extends StatelessWidget {
  const Step3Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'อัพโหลดบัตรประจำตัวประชาชน',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.mutedForeground,
            ),
          ),
        ),
        SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'ยืนยันตัวตนด้วย Citizen ID ของคุณ',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
