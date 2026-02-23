import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomFotter extends StatelessWidget {
  const CustomFotter({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: Colors.grey, thickness: 0.5),
        SizedBox(height: 20.h),

        // الشعار والكلمة الافتتاحية
        Image.asset("assets/images/splash.png", height: 50.h), // تأكد من المسار
        SizedBox(height: 10.h),
        Text(
          "Find it. Book it. Live it.",
          style: TextStyle(color: Colors.grey[700], fontSize: 14.sp),
        ),
        SizedBox(height: 10.h),
        Text(
          "Curated stays for slow travelers. Handpicked homes designed for comfort, beauty, and calm.",
          style: TextStyle(color: Colors.grey[600], fontSize: 13.sp),
        ),

        SizedBox(height: 30.h),

        // قسم Support
        _buildFooterSection("Support", [
          "Help Center",
          "Safety Information",
          "Cancellation Options",
          "Report a Concern",
        ]),

        // قسم Hosting
        _buildFooterSection("Hosting", [
          "Become a Host",
          "Host Resources",
          "Community Forum",
          "Host Responsibly",
        ]),

        // قسم QuickIn
        _buildFooterSection("QuickIn", [
          "About Us",
          "Newsroom",
          "Careers",
          "Contact",
        ]),

        const Divider(),
        SizedBox(height: 15.h),

        // الجزء السفلي (حقوق النشر)
        Text(
          "© 2026 QuickIn, Inc. · Terms · Sitemap · Privacy",
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[800]),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Icon(Icons.language, size: 18.r),
            SizedBox(width: 5.w),
            Text(
              "English (US)   \$ USD",
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 50.h), // مساحة عشان الـ Bottom Nav
      ],
    );
  }

  Widget _buildFooterSection(String title, List<String> items) {
    return Padding(
      padding: EdgeInsets.only(bottom: 25.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10.h),
          ...items.map(
            (item) => Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Text(
                item,
                style: TextStyle(color: Colors.grey[700], fontSize: 14.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
