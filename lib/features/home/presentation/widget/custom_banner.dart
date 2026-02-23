import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/color/app_color.dart';

class OfferBanner extends StatelessWidget {
  const OfferBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primaryRed,
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, color: Colors.orangeAccent, size: 16.r),
          SizedBox(width: 8.w),
          Text(
            "Best Offers of the Week",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 8.w),
          Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12.r),
        ],
      ),
    );
  }
}
