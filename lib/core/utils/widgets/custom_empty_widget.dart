import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomEmptyWidget extends StatelessWidget {
  final String message;
  final IconData icon;

  const CustomEmptyWidget({
    super.key,
    this.message = "No listings found",
    this.icon = Icons.search_off,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 70.r, color: Colors.grey[400]),
        SizedBox(height: 15.h),
        Text(
          message,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
