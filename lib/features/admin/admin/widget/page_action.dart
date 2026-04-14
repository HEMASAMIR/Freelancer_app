import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PageActionBtn extends StatelessWidget {
  final IconData icon;
  const PageActionBtn({super.key, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Icon(icon, size: 18.sp, color: Colors.grey),
    );
  }
}
