import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/app_router/routes.dart';

class IdentityVerificationScreen extends StatelessWidget {
  const IdentityVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          child: Center(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(32.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDE7),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: const Color(0xFFFFCC02).withValues(alpha: 0.6),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Shield Icon
                  Container(
                    padding: EdgeInsets.all(16.w),
                    child: Icon(
                      Icons.shield_outlined,
                      size: 64.sp,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Title
                  Text(
                    'Identity Verification Required',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF92400E),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Subtitle
                  Text(
                    'You need to verify your identity before you can list a property.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: 28.h),

                  // Verify Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.account,
                        arguments: 1, // ✅ يفتح تاب Verification مباشرة
                      ),
                      icon: Icon(
                        Icons.shield,
                        size: 18.sp,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Verify Your Identity',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7B1C1C),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // Footer
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: Center(
          child: Text(
            '© 2026 QuickIn, Inc. · Terms · Sitemap · Privacy',
            style: TextStyle(fontSize: 10.sp, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
