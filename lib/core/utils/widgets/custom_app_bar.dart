import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/utils/widgets/social_button.dart';
import 'package:freelancer/features/auth/view/presentation/view/help_center.dart';
import 'package:freelancer/features/auth/view/presentation/view/host_your_home.dart';
import 'package:freelancer/features/auth/view/presentation/view/login_view.dart';
import 'package:freelancer/features/auth/view/presentation/view/sign_up_view.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    const Color customRedColor = Color(0xFF8B1A1A);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Q',
                style: TextStyle(
                  color: customRedColor,
                  fontSize: 26.sp,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              Text(
                'QUICK IN',
                style: TextStyle(
                  color: customRedColor,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Text(
                  'Search',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 10.w),
                CircleAvatar(
                  radius: 14.r,
                  backgroundColor: customRedColor,
                  child: Icon(Icons.search, color: Colors.white, size: 16.r),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PopupMenuButton<String>(
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  constraints: BoxConstraints(minWidth: 220.w, maxWidth: 220.w),
                  icon: const Icon(Icons.menu, color: Colors.black87),
                  offset: const Offset(-170, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  onSelected: (value) {
                    if (value == 'signup') {
                      BottomAuthText(
                        context,
                        text: "Already have an account? ",
                        actionText: "Log In",
                      );
                    } else if (value == 'login') {
                      BottomAuthText(
                        context,
                        text: "Don't have an account? ",
                        actionText: 'Sign Up',
                      );
                    } else if (value == 'host') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HostYourHome()),
                      );
                    } else if (value == 'help') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HelpCenter()),
                      );
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'signup',
                      child: Text(
                        'Sign up',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const PopupMenuItem(value: 'login', child: Text('Log in')),
                    const PopupMenuDivider(height: 1),
                    const PopupMenuItem(
                      value: 'host',
                      child: Text('Host your home'),
                    ),
                    const PopupMenuItem(
                      value: 'help',
                      child: Text('Help Center'),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: Icon(
                    Icons.account_circle,
                    size: 28.r,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
