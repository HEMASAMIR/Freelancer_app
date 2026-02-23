import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F4EB),
        border: Border(
          top: BorderSide(color: Colors.grey.shade300, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(Icons.arrow_back_ios_new, color: Colors.black54, size: 22.r),
          Icon(Icons.arrow_forward_ios, color: Colors.black54, size: 22.r),
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add, color: Colors.black87, size: 24.r),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.crop_square_rounded,
                size: 32.r,
                color: Colors.black87,
              ),
              Text(
                "10",
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Icon(Icons.more_horiz, color: Colors.black87, size: 30.r),
        ],
      ),
    );
  }
}
