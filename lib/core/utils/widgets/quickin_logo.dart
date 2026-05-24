import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/constant/constant.dart';

class QuickInLogo extends StatelessWidget {
  final double height;
  final bool isHorizontal;
  
  const QuickInLogo({
    super.key, 
    this.height = 45,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isHorizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo_512x512_fixed.png',
            height: height * 0.8,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 6.w),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "QUICK IN",
                style: TextStyle(
                  color: AppColors.primaryBurgundy,
                  fontSize: (height * 0.4).sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  height: 1.0,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                "Find it. Book it.",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: (height * 0.22).sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Vertical layout
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/logo_512x512_fixed.png',
          height: height * 0.65,
          fit: BoxFit.contain,
        ),
        SizedBox(height: 2.h),
        Text(
          "QUICK IN",
          style: TextStyle(
            color: AppColors.primaryBurgundy,
            fontSize: (height * 0.25).sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
            height: 1.0,
          ),
        ),
        Text(
          "Find it. Book it.",
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: (height * 0.12).sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}
