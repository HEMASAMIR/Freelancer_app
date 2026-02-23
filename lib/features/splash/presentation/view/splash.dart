import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/Costant/app_color.dart';
import 'package:freelancer/features/home/presentation/view/home.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Homescreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),

            // اللوجو
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryRed, width: 8.w),
              ),
              child: Center(
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryRed,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),

            SizedBox(height: 24.h),

            Text(
              "QuickIn",
              style: TextStyle(
                color: AppColors.primaryRed,
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              "Loading amazing stays...",
              style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
            ),

            const Spacer(flex: 2),

            // أنيميشن الـ Lottie
            Lottie.asset(
              'assets/lottie/loading_lottie.json',
              width: 120.w,
              height: 120.h,
              fit: BoxFit.contain,
              repeat: true,
              reverse: false,
              animate: true,
            ),

            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}
