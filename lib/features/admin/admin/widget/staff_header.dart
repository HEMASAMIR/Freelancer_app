import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StaffPageHeader extends StatelessWidget {
  final Color maroonColor;
  final Color greyColor;
  final VoidCallback? onAddTap;

  const StaffPageHeader({
    super.key,
    this.maroonColor = const Color(0xFF710E21),
    this.greyColor = const Color(0xFF717171),
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // القسم الأيمن: النصوص
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Staff\nManagement',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                  color: Colors.black,
                  fontFamily: 'Cairo', // أو الخط المستخدم في مشروعك
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Manage administrators\nand moderators.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: greyColor,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),

        // القسم الأيسر: زر الإضافة بأنيميشن
        _AnimatedPressButton(
          onTap: onAddTap ?? () {},
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: maroonColor,
              borderRadius: BorderRadius.circular(8.r),
              boxShadow: [
                BoxShadow(
                  color: maroonColor.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_add_alt_1, color: Colors.white, size: 18.sp),
                SizedBox(width: 8.w),
                Text(
                  'Add Staff Member',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// أنيميشن الضغط (السكيل) ليعطي إحساساً تفاعلياً راقياً
class _AnimatedPressButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _AnimatedPressButton({required this.child, required this.onTap});

  @override
  State<_AnimatedPressButton> createState() => _AnimatedPressButtonState();
}

class _AnimatedPressButtonState extends State<_AnimatedPressButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}
