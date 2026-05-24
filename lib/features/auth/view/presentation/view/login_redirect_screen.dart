import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/app_router/routes.dart';
import 'package:freelancer/core/shared_helper/app_color.dart';
import 'package:freelancer/core/utils/widgets/custom_app_bar.dart';
import 'package:freelancer/features/home/presentation/widget/custom_drawer.dart';
import 'package:freelancer/features/home/presentation/widget/custom_footer.dart';

class LoginRedirectScreen extends StatelessWidget {
  const LoginRedirectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3F0),
      appBar: const CustomAppBar(),
      drawer: const SideDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Log in to QuickIn',
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.label,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Welcome back! Please sign in to continue.',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.sub,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 32.h),
                        Text(
                          'Use the menu in the top right corner to log in or sign up.',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.sub,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24.h),
                        SizedBox(
                          height: 48.h,
                          width: 200.w,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                AppRoutes.home,
                                (route) => false,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFF5B0F16,
                              ), // Maroon
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Go to homepage',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Footer
                const CustomFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
