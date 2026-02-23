import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/color/app_color.dart';

class BottomAuthText extends StatelessWidget {
  final String text;
  final String actionText;
  final VoidCallback onTap;

  const BottomAuthText({
    super.key,
    required this.text,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.sub, // تأكد من وجود هذا اللون في ثوابتك
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionText,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.ed, // اللون الأساسي للتطبيق
            ),
          ),
        ),
      ],
    );
  }
}
