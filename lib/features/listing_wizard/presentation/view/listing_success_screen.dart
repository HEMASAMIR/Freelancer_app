import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/app_router/routes.dart';
import 'package:freelancer/core/constant/constant.dart';

class ListingSuccessScreen extends StatefulWidget {
  const ListingSuccessScreen({super.key});

  @override
  State<ListingSuccessScreen> createState() => _ListingSuccessScreenState();
}

class _ListingSuccessScreenState extends State<ListingSuccessScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.adminDashboard, (route) => false);
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
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Row(
                children: [
                   Icon(Icons.check_circle_outline, color: Colors.green, size: 24.sp),
                   SizedBox(width: 8.w),
                   Text('Listing created successfully!', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.inkBlack)),
                ],
              ),
            ),
            const Spacer(),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryRed, width: 2),
                    ),
                    child: Icon(Icons.maps_home_work_outlined, color: AppColors.primaryRed, size: 48.sp),
                  ),
                  SizedBox(height: 16.h),
                  Text('QuickIn', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w700, color: AppColors.primaryRed)),
                  SizedBox(height: 8.h),
                  Text('Listing among stays...', style: TextStyle(fontSize: 14.sp, color: AppColors.greyText)),
                  SizedBox(height: 24.h),
                  CircularProgressIndicator(color: AppColors.primaryRed),
                ],
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
