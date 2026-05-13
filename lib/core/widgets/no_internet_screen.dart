import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/shared_helper/app_color.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // أيقونة شيك جداً
            Container(
              padding: EdgeInsets.all(30.r),
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 100.sp,
                color: AppColors.primaryRed,
              ),
            ),
            SizedBox(height: 40.h),
            
            // العنوان
            Text(
              "انقطع الاتصال بالإنترنت",
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            
            // الوصف
            Text(
              "يبدو أنك غير متصل بالشبكة حالياً. يرجى التحقق من اتصال الواي فاي أو بيانات الهاتف للمتابعة.",
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 50.h),
            
            // زرار المحاولة
            SizedBox(
              width: double.infinity,
              height: 55.h,
              child: ElevatedButton(
                onPressed: () {
                  // الزرار ده مجرد "تذكير" للمستخدم، الـ Cubit هيحس بالنت لما يرجع أوتوماتيك
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "جاري المحاولة...",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            
            // لودر صغير
            SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryRed.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
