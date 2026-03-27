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
