import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchFilterField extends StatelessWidget {
  SearchFilterField();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Filter by email...',
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
          prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
        ),
      ),
    );
  }
}
