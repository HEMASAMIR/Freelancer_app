import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/constant/constant.dart';

class BestOffersBanner extends StatelessWidget {
  const BestOffersBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // العرض بالكامل
      width: double.infinity,
      // الطول متناسب مع الشاشة
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration:  BoxDecoration(
        // نفس درجة اللون العنابي الغامق الموجودة في الصورة
        color: AppColors.primaryBurgundy,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // أيقونة التكت (الخصم)
          Icon(Icons.local_offer_outlined, color: Colors.white, size: 16.sp),
          SizedBox(width: 8.w),
          // النص
          Text(
            "Best Offers of the Week",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(width: 8.w),
          // السهم الصغير
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.white,
            size: 10.sp, // حجم صغير جداً للسهم كما في الصورة
          ),
        ],
      ),
    );
  }
}
