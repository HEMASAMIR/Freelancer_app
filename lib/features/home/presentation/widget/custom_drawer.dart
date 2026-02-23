import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/Costant/app_color.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.bgColor,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 60.h),
        children: [
          _drawerItem("Help Center"),
          _drawerItem("Safety Information"),
          _drawerItem("Cancellation Options"),
          _drawerItem("Report a Concern"),
          const Divider(color: AppColors.dividerGrey),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 15.h),
            child: Text(
              "Hosting",
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
          ),
          _drawerItem("Become a Host"),
          _drawerItem("Host Resources"),
          _drawerItem("Community Forum"),
          _drawerItem("Host Responsibly"),
        ],
      ),
    );
  }

  Widget _drawerItem(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Text(
        title,
        style: TextStyle(fontSize: 16.sp, color: Colors.black),
      ),
    );
  }
}
