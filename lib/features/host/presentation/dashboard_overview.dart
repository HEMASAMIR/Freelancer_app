import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/core/app_router/routes.dart';
import 'package:freelancer/features/home/presentation/widget/custom_drawer.dart';
import 'package:freelancer/features/home/presentation/widget/custom_footer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class DashboardOverviewScreen extends StatelessWidget {
  const DashboardOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      drawer: const SideDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCream,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppColors.inkBlack),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.inkBlack,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Back',
          ),
        ],
        title: Text(
          'Overview',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.inkBlack,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Section ──────────────────────────────────────────
              Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkBlack,
                  letterSpacing: -1.0,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Welcome back! Here's an overview of your account.",
                style: TextStyle(
                  fontSize: 15.sp,
                  color: AppColors.greyText,
                ),
              ),
              SizedBox(height: 32.h),

              // ── 4 Navigation/Quick-Stats Cards Grid/List ────────────────
              AnimationLimiter(
                child: Column(
                  children: [
                    AnimationConfiguration.staggeredList(
                      position: 0,
                      duration: const Duration(milliseconds: 500),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: _buildDashboardCard(
                            context: context,
                            title: 'My Listings',
                            subtitle: 'Manage your active properties',
                            icon: Icons.home_work_outlined,
                            iconColor: const Color(0xFF1E3A8A), // Rich Blue
                            bgColor: const Color(0xFFEFF6FF),
                            route: AppRoutes.myListings,
                          ),
                        ),
                      ),
                    ),
                    AnimationConfiguration.staggeredList(
                      position: 1,
                      duration: const Duration(milliseconds: 500),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: _buildDashboardCard(
                            context: context,
                            title: 'My Trips',
                            subtitle: 'View your reservations',
                            icon: Icons.calendar_month_outlined,
                            iconColor: const Color(0xFF047857), // Emerald Green
                            bgColor: const Color(0xFFECFDF5),
                            route: AppRoutes.trips,
                          ),
                        ),
                      ),
                    ),
                    AnimationConfiguration.staggeredList(
                      position: 2,
                      duration: const Duration(milliseconds: 500),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: _buildDashboardCard(
                            context: context,
                            title: 'Wishlists',
                            subtitle: 'Your saved listings and folders',
                            icon: Icons.favorite_border_rounded,
                            iconColor: const Color(0xFFBE185D), // Pink/Red
                            bgColor: const Color(0xFFFDF2F8),
                            route: AppRoutes.wishlists,
                          ),
                        ),
                      ),
                    ),
                    AnimationConfiguration.staggeredList(
                      position: 3,
                      duration: const Duration(milliseconds: 500),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: _buildDashboardCard(
                            context: context,
                            title: 'Account Settings',
                            subtitle: 'Profile details & identity verification',
                            icon: Icons.settings_outlined,
                            iconColor: const Color(0xFF4B5563), // Cool Grey
                            bgColor: const Color(0xFFF3F4F6),
                            route: AppRoutes.account,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),
              const CustomFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String route,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, route),
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.dividerGrey.withOpacity(0.4),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Icon Backdrop Circle
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24.r,
                  ),
                ),
                SizedBox(width: 16.w),
                // Text Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.inkBlack,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.greyText,
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow
                Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.primaryBurgundy,
                  size: 20.r,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
