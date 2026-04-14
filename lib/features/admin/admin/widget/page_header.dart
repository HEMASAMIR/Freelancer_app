import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/utils/animation/animation_press_button.dart';

class PageHeader extends StatelessWidget {
  final Color maroonColor;
  final Color greyColor;
  const PageHeader({super.key, required this.maroonColor, required this.greyColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ Expanded يحجز المساحة المتبقية بعد الزرار
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
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Manage administrators\nand moderators.',
                style: TextStyle(fontSize: 14.sp, color: greyColor),
              ),
            ],
          ),
        ),

        SizedBox(width: 12.w),

        // ✅ الزرار بـ size ثابت - ميتمددش
        AnimatedPressButton(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Add Staff functionality coming soon!"),
                backgroundColor: Colors.blueGrey,
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: maroonColor,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min, // ✅ مهم جداً
              children: [
                Icon(Icons.person_add_alt_1, color: Colors.white, size: 18.sp),
                SizedBox(width: 6.w),
                Text(
                  'Add Staff\nMember',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
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
