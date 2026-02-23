import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/color/app_color.dart';

class CustomLabel extends StatelessWidget {
  final String text;

  // التعديل هنا: الـ Constructor بقى أنضف وبيستقبل النص مباشرة
  const CustomLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.label,
      ),
    );
  }
}
