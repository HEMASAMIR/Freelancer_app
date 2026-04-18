import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freelancer/core/shared_helper/app_color.dart';
import 'package:freelancer/features/admin/logic/admin_management_cubit.dart';
import 'package:freelancer/features/admin/logic/admin_management_state.dart';

class DashboardOverviewContent extends StatefulWidget {
  final Function(String)? onViewChanged;

  const DashboardOverviewContent({super.key, this.onViewChanged});

  @override
  State<DashboardOverviewContent> createState() =>
      _DashboardOverviewContentState();
}

class _DashboardOverviewContentState extends State<DashboardOverviewContent> {
  @override
  void initState() {
    super.initState();
    // Load real stats from Supabase
    context.read<AdminManagementCubit>().loadDashboardStats();
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
              'Dashboard Overview',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Welcome to the admin dashboard. Here\'s what is happening on your platform.',
              style:
                  TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
            ),
            SizedBox(height: 28.h),

            // ── Stats Cards ────────────────────────────────────────────
            BlocBuilder<AdminManagementCubit, AdminManagementState>(
              builder: (context, state) {
                int totalListings = 0;
                int totalUsers = 0;
                int bookingsThisMonth = 0;
                int pendingApprovals = 0;
                final isLoading = state is AdminManagementLoading ||
                    state is AdminManagementInitial;

                if (state is AdminDashboardStatsLoaded) {
                  totalListings = state.totalListings;
                  totalUsers = state.totalUsers;
                  bookingsThisMonth = state.bookingsThisMonth;
                  pendingApprovals = state.pendingApprovals;
                }

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            title: 'Total Listings',
                            value: totalListings,
                            icon: Icons.home_work_outlined,
                            iconBg: const Color(0xFFEBF3FF),
                            iconColor: const Color(0xFF2563EB),
                            linkLabel: 'Active listings on the platform',
                            isLoading: isLoading,
                            onTap: () =>
                                widget.onViewChanged?.call('Listings'),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _statCard(
                            title: 'Total Users',
                            value: totalUsers,
                            icon: Icons.people_outline,
                            iconBg: const Color(0xFFF0FDF4),
                            iconColor: const Color(0xFF16A34A),
                            linkLabel: 'Registered users',
                            isLoading: isLoading,
                            onTap: () =>
                                widget.onViewChanged?.call('Fans'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            title: 'Bookings This Month',
                            value: bookingsThisMonth,
                            icon: Icons.calendar_month_outlined,
                            iconBg: const Color(0xFFFFF7ED),
                            iconColor: const Color(0xFFEA580C),
                            linkLabel: 'New bookings this month',
                            isLoading: isLoading,
                            onTap: () =>
                                widget.onViewChanged?.call('Bookings'),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _statCard(
                            title: 'Pending Approvals',
                            value: pendingApprovals,
                            icon: Icons.pending_actions_outlined,
                            iconBg: const Color(0xFFFDF4FF),
                            iconColor: const Color(0xFF9333EA),
                            linkLabel: 'Items awaiting review',
                            isLoading: isLoading,
                            onTap: () =>
                                widget.onViewChanged?.call('Approvals'),
                            isAlert: pendingApprovals > 0,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),

            SizedBox(height: 24.h),

            // ── Quick Actions ──────────────────────────────────────────
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 12.h),

            _quickAction(
              'All Listings',
              Icons.maps_home_work_outlined,
              Colors.blue,
              'View and manage all properties',
              () => widget.onViewChanged?.call('Listings'),
            ),
            _quickAction(
              'Bookings',
              Icons.calendar_today_outlined,
              Colors.green,
              'Review all booking requests',
              () => widget.onViewChanged?.call('Bookings'),
            ),
            _quickAction(
              'Approvals',
              Icons.approval_outlined,
              Colors.orange,
              'Review pending approvals',
              () => widget.onViewChanged?.call('Approvals'),
            ),
            _quickAction(
              'Financials',
              Icons.account_balance_outlined,
              Colors.purple,
              'View earnings & financial reports',
              () => widget.onViewChanged?.call('Financials'),
            ),
            _quickAction(
              'Staff',
              Icons.manage_accounts_outlined,
              Colors.teal,
              'Manage admin staff accounts',
              () => widget.onViewChanged?.call('Staff'),
            ),

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

  Widget _statCard({
    required String title,
    required int value,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String linkLabel,
    required bool isLoading,
    required VoidCallback onTap,
    bool isAlert = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: isAlert
              ? Border.all(color: Colors.orange.shade300, width: 1.5)
              : Border.all(color: Colors.grey.shade100, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(icon, size: 20.sp, color: iconColor),
                ),
                if (isAlert)
                  Icon(Icons.info_outline,
                      size: 16.sp, color: Colors.orange.shade400),
              ],
            ),
            SizedBox(height: 12.h),
            isLoading
                ? Container(
                    width: 40.w,
                    height: 28.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  )
                : Text(
                    value.toString(),
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
            SizedBox(height: 4.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              linkLabel,
              style:
                  TextStyle(fontSize: 10.sp, color: Colors.grey.shade500),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAction(
    String title,
    IconData icon,
    Color color,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding:
            EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: color, size: 20.sp),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style:
              TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
        ),
        trailing: Icon(Icons.arrow_forward_ios_rounded,
            size: 12.sp, color: Colors.grey.shade400),
      ),
    );
  }
}
