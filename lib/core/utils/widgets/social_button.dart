import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap; // ✅ أضفنا onTap

  const SocialButton({
    required this.label,
    required this.icon,
    this.onTap, // ✅
    super.key,
  });

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
      onPressed: onTap, // ✅
    );
  }
}

// ✅ OR Divider
class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: const Color(0xFFD4CEBC), thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Text(
            'OR',
            style: TextStyle(fontSize: 11.sp, color: Colors.grey),
          ),
        ),
        Expanded(child: Divider(color: const Color(0xFFD4CEBC), thickness: 1)),
      ],
    );
  }
}

// ✅ Bottom Auth Text مع onTap
class BottomAuthText extends StatelessWidget {
  final String text;
  final String actionText;
  final VoidCallback? onTap; // ✅

  const BottomAuthText({
    required this.text,
    required this.actionText,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap, // ✅
        child: RichText(
          text: TextSpan(
            text: text,
            style: TextStyle(color: Colors.black54, fontSize: 11.sp),
            children: [
              TextSpan(
                text: actionText,
                style: TextStyle(
                  color: const Color(0xFF8B1A1A),
                  fontWeight: FontWeight.w600,
                  fontSize: 11.sp,
                  decoration: TextDecoration.underline,
                  decorationColor: const Color(0xFF8B1A1A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
