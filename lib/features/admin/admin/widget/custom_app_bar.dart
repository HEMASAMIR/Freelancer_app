import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/core/utils/widgets/quickin_logo.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: const Icon(Icons.menu, color: Colors.black),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          QuickInLogo(height: 30.h, isHorizontal: true),
          SizedBox(width: 8.w),
          Text(
            'Dashboard',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 16.w),
          child: CircleAvatar(
            radius: 14.r,
            backgroundColor: Colors.grey.shade200,
            child: Icon(Icons.person, size: 18.sp, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
