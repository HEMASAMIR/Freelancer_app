import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freelancer/core/app_router/routes.dart';
import 'package:freelancer/core/shared_helper/app_color.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_cubit.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_state.dart';
import 'package:freelancer/features/host/logic/cubit/host_cubit.dart';
import 'package:freelancer/features/host/logic/cubit/host_state.dart';

class DashboardOverviewContent extends StatefulWidget {
  final Function(String)? onViewChanged;

  const DashboardOverviewContent({super.key, this.onViewChanged});

  @override
  State<DashboardOverviewContent> createState() => _DashboardOverviewContentState();
}

class _DashboardOverviewContentState extends State<DashboardOverviewContent> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAdminSuccess) {
      context.read<HostCubit>().getHostOverview(authState.user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Welcome back! Here\'s an overview of your account.',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
            ),
            SizedBox(height: 32.h),

            BlocBuilder<HostCubit, HostState>(
              builder: (context, state) {
                int? listingsCount;
                int? tripsCount;
                bool isLoading = state is HostLoading || state is HostInitial;
                
                if (state is HostDashboardLoaded) {
                  listingsCount = state.listingIds.length;
                  tripsCount = state.bookingIds.length;
                }

                return Column(
                  children: [
                    _buildDashboardCard(
                      title: 'My Listings',
                      subtitle: isLoading ? 'Loading data...' : 'Manage your ${listingsCount ?? 0} properties',
                      icon: Icons.home_outlined,
                      iconColor: Colors.blue,
                      onTap: () {
                        if (widget.onViewChanged != null) {
                          widget.onViewChanged!('My Listings');
                        } else {
                          Navigator.pushNamed(context, AppRoutes.adminDashboard);
                        }
                      },
                    ),
                    _buildDashboardCard(
                      title: 'My Trips',
                      subtitle: isLoading ? 'Loading data...' : 'View your ${tripsCount ?? 0} reservations',
                      icon: Icons.calendar_today_outlined,
                      iconColor: Colors.green,
                      onTap: () => Navigator.pushNamed(context, AppRoutes.trips),
                    ),
                    _buildDashboardCard(
                      title: 'Wishlists',
                      subtitle: 'Places you saved',
                      icon: Icons.favorite_border,
                      iconColor: Colors.pink,
                      onTap: () => Navigator.pushNamed(context, AppRoutes.wishlists),
                    ),
                    _buildDashboardCard(
                      title: 'Account Settings',
                      subtitle: 'Profile & verification',
                      icon: Icons.settings_outlined,
                      iconColor: Colors.blueGrey,
                      onTap: () => Navigator.pushNamed(context, AppRoutes.account),
                    ),
                  ],
                );
              },
            ),

            SizedBox(height: 24.h),

            _buildBecomeHostCard(context),

            SizedBox(height: 40.h),

            Center(
              child: Text(
                '© 2026 QuickIn Inc. · Terms · Sitemap · Privacy',
                style: TextStyle(fontSize: 10.sp, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        leading: Icon(icon, color: iconColor, size: 28.sp),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 14.sp,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildBecomeHostCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Become a Host',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Text(
            'Earn extra income by sharing your space with travelers.',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            // ← يروح لشاشة Identity Verification
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.identityVerification),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.maroon,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.home_work, size: 18.sp),
                SizedBox(width: 8.w),
                const Text('List Your Property'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
