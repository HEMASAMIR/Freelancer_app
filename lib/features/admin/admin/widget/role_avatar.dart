import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RoleAvatar extends StatelessWidget {
  final String role;
  const RoleAvatar({required this.role});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Text(
          role,
          style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
