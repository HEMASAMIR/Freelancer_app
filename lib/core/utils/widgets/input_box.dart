import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InputBox extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscure;
  final Widget? suffix;

  // 1. تم تصحيح اسم الـ Constructor (كان فيه _ زيادة)
  // 2. تم إضافة super.key بشكل صحيح
  const InputBox({
    super.key,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscure = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      style: TextStyle(fontSize: 13.sp, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13.sp, color: const Color(0xFFAAAAAA)),
        suffixIcon: suffix,
        // تم تعديل الـ constraints عشان الأيقونة ما تطلعش لازقة في الحواف
        suffixIconConstraints: BoxConstraints(minWidth: 40.w),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        filled: true,
        fillColor: const Color(0xFFEDE8DC),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: Color(0xFFD4CEBC), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: Color(0xFF8B1A1A), width: 1.5),
        ),
        // يُفضل إضافة border لضمان الشكل الموحد
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }
}
