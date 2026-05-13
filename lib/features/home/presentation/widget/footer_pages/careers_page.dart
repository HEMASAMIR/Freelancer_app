import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/core/utils/widgets/custom_app_bar.dart';
import 'package:freelancer/features/home/presentation/widget/custom_footer.dart';

class CareersPage extends StatelessWidget {
  const CareersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: const CustomAppBar(),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        children: [
          // ─── Header ───────────────────────────────────────────────
          Text(
            'Careers',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.inkBlack,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            width: 60.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.primaryBurgundy,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'At QuickIn we are always excited about great talent and passionate people who want to build meaningful products and impactful experiences.',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.greyText,
              height: 1.6,
            ),
          ),
          SizedBox(height: 32.h),

          // ─── No Open Positions Card ───────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(32.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBurgundy.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.work_off_rounded,
                    color: AppColors.primaryBurgundy,
                    size: 48.r,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'No Open Positions Right Now',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.inkBlack,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                Text(
                  'We currently do not have any open roles available. However, we are always growing and may open new opportunities in the future.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.greyText,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),
                Text(
                  'We encourage you to check back again soon for updates.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.primaryBurgundy,
                    fontWeight: FontWeight.w600,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),

          const CustomFooter(),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }
}
