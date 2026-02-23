import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/color/app_color.dart';

class HaveAccountWidget extends StatelessWidget {
  final String text1;
  final String text2;
  final VoidCallback onTap;

  const HaveAccountWidget({
    super.key,
    required this.text1,
    required this.text2,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text1,
          style: TextStyle(fontSize: 12.sp, color: AppColors.sub),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            text2,
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF8B1A1A),
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              decorationColor: const Color(0xFF8B1A1A),
            ),
          ),
        ),
      ],
    );
  }
}
