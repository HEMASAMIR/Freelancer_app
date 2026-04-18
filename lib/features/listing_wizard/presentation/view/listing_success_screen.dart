import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/app_router/routes.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:lottie/lottie.dart'; // Just in case, but let's use Icons if not available.

class ListingSuccessScreen extends StatefulWidget {
  const ListingSuccessScreen({super.key});

  @override
  State<ListingSuccessScreen> createState() => _ListingSuccessScreenState();
}

class _ListingSuccessScreenState extends State<ListingSuccessScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.dashboard, (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100.w,
                    height: 100.h,
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.hourglass_top_rounded, color: AppColors.primaryRed, size: 50.sp),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Under Review',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.inkBlack,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: Text(
                      'Your listing has been submitted and is pending verification by the admin. It will be live once approved.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.greyText,
                        height: 1.5,
                      ),
                    ),
                  ),
                  SizedBox(height: 40.h),
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Redirecting to dashboard...',
                    style: TextStyle(fontSize: 12.sp, color: AppColors.greyText),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 2),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.dashboard, (route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                  child: Text(
                    'Go to Dashboard',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
