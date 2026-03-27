import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PropertyTypeTag extends StatelessWidget {
  final String name;

  const PropertyTypeTag({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEC),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        name.toUpperCase(),
        style: TextStyle(
          fontSize: 10.sp,
          color: const Color(0xFFBD1E59),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
