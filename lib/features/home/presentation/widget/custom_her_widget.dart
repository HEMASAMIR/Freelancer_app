import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HeroWidget extends StatelessWidget {
  const HeroWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Background image ────────────────────────────────────────────────
        Container(
          width: double.infinity,
          height: 480.h,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: CachedNetworkImageProvider(
                'https://images.unsplash.com/photo-1613490493576-7fde63acd811?q=80&w=1000',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // ── Dark gradient overlay ───────────────────────────────────────────
        Container(
          height: 480.h,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.65),
              ],
            ),
          ),
        ),
        // ── Text content ────────────────────────────────────────────────────
        Positioned(
          bottom: 50.h,
          left: 20.w,
          right: 20.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Find it. Book it. Live it",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30.sp,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
              SizedBox(height: 15.h),
              Text(
                "Carefully selected homes from trusted hosts,\ndesigned with guests in mind.",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 17.sp,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
