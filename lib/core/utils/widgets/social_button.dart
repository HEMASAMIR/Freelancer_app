import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  const SocialButton({required this.label, required this.icon, super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        minimumSize: Size(double.infinity, 48.h),
        side: const BorderSide(color: Colors.grey),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
      icon: Icon(icon, color: Colors.black, size: 24.sp),
      label: Text(label, style: const TextStyle(color: Colors.black)),
      onPressed: () {},
    );
  }
}

// 2. الخط الفاصل "OR"
class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Text(
            "OR",
            style: TextStyle(color: Colors.grey, fontSize: 12.sp),
          ),
        ),
        const Expanded(child: Divider(thickness: 1)),
      ],
    );
  }
}

// 3. حقل الإدخال المخصص
class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final bool isPassword;
  const CustomTextField({
    required this.label,
    required this.hint,
    this.isPassword = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        TextField(
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            suffixIcon: isPassword
                ? const Icon(Icons.visibility_off_outlined)
                : null,
          ),
        ),
      ],
    );
  }
}

class BottomAuthText extends StatelessWidget {
  const BottomAuthText({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: "Already have an account? ",
          style: TextStyle(color: Colors.black, fontSize: 14.sp),
          children: [
            TextSpan(
              text: "Log in",
              style: TextStyle(
                color: const Color(0xFF8B1A1A),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
