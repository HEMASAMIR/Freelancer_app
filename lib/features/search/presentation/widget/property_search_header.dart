import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PropertySearchHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;

  const PropertySearchHeader({
    super.key,
    required this.title,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      child: Row(
        children: [
          // زر الإغلاق
          IconButton(
            icon: Icon(Icons.close, size: 22.r, color: Colors.black),
            onPressed: onClose,
          ),
          const Spacer(),
          // العنوان في المنتصف
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          // مساحة موازنة لضمان توسيط النص تماماً (تساوي حجم الـ IconButton)
          SizedBox(width: 48.w),
        ],
      ),
    );
  }
}
