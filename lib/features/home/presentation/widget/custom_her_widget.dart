import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HeroWidget extends StatelessWidget {
  const HeroWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 480.h,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                'https://images.unsplash.com/photo-1613490493576-7fde63acd811?q=80&w=1000',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          height: 480.h,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
            ),
          ),
        ),
        Positioned(
          bottom: 50.h,
          left: 20.w,
          right: 20.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Curated stays\nfor slow travelers",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36.sp,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
              SizedBox(height: 15.h),
              Text(
                "Handpicked homes designed for comfort,\nbeauty, and calm.",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 17.sp,
                  height: 1.4,
                ),
              ),
            ],
          ),        ),
      ],
    );
  }
}
