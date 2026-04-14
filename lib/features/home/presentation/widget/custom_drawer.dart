import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freelancer/core/app_router/routes.dart';
import 'package:freelancer/core/shared_helper/app_color.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_cubit.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_state.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/features/auth/view/presentation/view/login_view.dart';
import 'package:freelancer/features/auth/view/presentation/view/help_center.dart';

enum DrawerMode { home, user, admin }

class SideDrawer extends StatefulWidget {
  final Function(String)? onItemSelected;
  const SideDrawer({super.key, this.onItemSelected});

  @override
  State<SideDrawer> createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
  String _selected = '';
  bool _isListingsExpanded = false;

  void _select(String item, BuildContext context, DrawerMode mode) {
    setState(() => _selected = item);

    // 1. اقفل الدرور الأول
    Navigator.of(context).pop();

    // 2. معالجة خاصة لـ Host Your Home
    if (item == 'Host Your Home') {
      final state = context.read<AuthCubit>().state;
      if (state is AuthSuccess || state is AuthAdminSuccess) {
        Navigator.of(context).pushNamed(AppRoutes.hostDashboard);
      } else {
        // ... SnackBar code
      }
      return;
    }

    // 3. معالجة الـ Overview وبقية العناصر
    // بنستخدم Future.delayed بسيط عشان نضمن إن الـ pop خلص والـ context جاهز للـ push
    Future.delayed(Duration.zero, () {
      if (!context.mounted) return;
      if (item == 'Log out' || item == 'Logout') {
        context.read<AuthCubit>().signOut();
      } else if (item == 'Log in') {
        _showLoginDialog(context);
      } else if (item == 'Help Center') {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HelpCenter()));
      } else if (item == 'Settings' || item == 'Notifications') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$item coming soon!"),
            backgroundColor: Colors.blueGrey,
          ),
        );
      } else if (widget.onItemSelected != null) {
        widget.onItemSelected!(item);
      } else {
        final route = _getRouteForItem(item, mode);
        if (route != null) {
          // تأكد إن AppRoutes.adminDashboard هو المسار لـ AdminOverviewScreen
          if (route == AppRoutes.adminDashboard || route == AppRoutes.adminOverview) {
            Navigator.of(context).pushNamed(route, arguments: item);
          } else {
            Navigator.of(context).pushNamed(route);
          }
        }
      }
    });
  }

  // ميثود إظهار شاشة تسجيل الدخول كـ Dialog
  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: context.read<AuthCubit>(),
        child: const LoginView(),
      ),
    );
  }

  String? _getRouteForItem(String item, DrawerMode mode) {
    if (item == 'Overview') {
      return AppRoutes.adminOverview;
    }
    switch (item) {
      case 'Personal Info':
      case 'Account':
        return AppRoutes.account;
      case 'Trips':
      case 'Bookings':
        return AppRoutes.trips;
      case 'Wishlists':
        return AppRoutes.wishlists;
      case 'Earnings & Balance':
      case 'My Listings':
      case 'All Listings':
      case 'Create New':
        return AppRoutes.adminDashboard;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        DrawerMode mode = DrawerMode.home;
        dynamic currentUser;

        if (state is AuthAdminSuccess) {
          mode = DrawerMode.admin;
          currentUser = state.user;
        } else if (state is AuthSuccess) {
          mode = DrawerMode.user;
          currentUser = state.user;
        }

        return Drawer(
          backgroundColor: AppColors.bgColor,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    children: _buildMenuItems(mode, context),
                  ),
                ),
                _buildFooter(currentUser),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 32.h, 20.w, 24.h),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: AppColors.primaryRed,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: const Icon(Icons.home, color: Colors.white, size: 20),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'QuickIn',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.1,
                ),
              ),
              Text(
                'Your Dashboard',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMenuItems(DrawerMode mode, BuildContext context) {
    if (mode == DrawerMode.home) {
      return [
        _buildSectionHeader('Welcome', context, mode),
        _buildNavigationItem('Log in', Icons.login, context, mode),
        _buildNavigationItem('Sign up', Icons.app_registration, context, mode),
        SizedBox(height: 16.h),
        _buildSectionHeader('Be a Host', context, mode),
        _buildNavigationItem(
          'Host Your Home',
          Icons.home_work_outlined,
          context,
          mode,
        ),
      ];
    }

    return [
      _buildSectionHeader('Dashboard', context, mode),
      _buildNavigationItem('Overview', Icons.pie_chart_outline, context, mode),
      SizedBox(height: 16.h),
      _buildSectionHeader('Account', context, mode),
      _buildNavigationItem(
        'Personal Info',
        Icons.person_outline,
        context,
        mode,
      ),
      SizedBox(height: 16.h),
      _buildSectionHeader('Guest', context, mode),
      _buildNavigationItem('Trips', Icons.flight_takeoff, context, mode),
      _buildNavigationItem('Wishlists', Icons.favorite_border, context, mode),
      SizedBox(height: 16.h),
      _buildSectionHeader('Hosting', context, mode),
      _buildNavigationItem(
        'Host Your Home',
        Icons.dashboard_customize_outlined,
        context,
        mode,
      ),
      if (mode == DrawerMode.admin) ...[
        SizedBox(height: 16.h),
        _buildSectionHeader('Admin Tools', context, mode),
        _buildExpandableNavigationItem(
          'My Listings',
          Icons.maps_home_work_outlined,
          context,
          mode,
          [
            _buildSubNavigationItem('All Listings', context, mode),
            _buildSubNavigationItem('Create New', context, mode),
          ],
        ),
        _buildNavigationItem(
          'Bookings',
          Icons.calendar_today_outlined,
          context,
          mode,
        ),
        _buildNavigationItem(
          'Earnings & Balance',
          Icons.account_balance_wallet_outlined,
          context,
          mode,
        ),
      ],
    ];
  }

  Widget _buildSectionHeader(
    String title,
    BuildContext context,
    DrawerMode mode,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildNavigationItem(
    String title,
    IconData icon,
    BuildContext context,
    DrawerMode mode,
  ) {
    final isSelected = _selected == title;
    return InkWell(
      onTap: () => _select(title, context, mode),
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade200 : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: Colors.black87),
            SizedBox(width: 16.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableNavigationItem(
    String title,
    IconData icon,
    BuildContext context,
    DrawerMode mode,
    List<Widget> children,
  ) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16.w),
        leading: Icon(icon, size: 20.sp, color: Colors.black87),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        initiallyExpanded: _isListingsExpanded,
        onExpansionChanged: (val) => setState(() => _isListingsExpanded = val),
        childrenPadding: EdgeInsets.only(left: 48.w, bottom: 8.h),
        children: children,
      ),
    );
  }

  Widget _buildSubNavigationItem(
    String title,
    BuildContext context,
    DrawerMode mode,
  ) {
    final isSelected = _selected == title;
    return InkWell(
      onTap: () => _select(title, context, mode),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13.sp,
            color: isSelected ? Colors.black : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(dynamic user) {
    if (user == null) return const SizedBox.shrink();
    final String name =
        user.userMetadata?['full_name'] ?? user.email?.split('@')[0] ?? 'User';
    final String email = user.email ?? '';
    final String initials = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return PopupMenuButton<String>(
      offset: const Offset(0, -280),
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: AppColors.bgColor,
                child: Text(
                  initials,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryRed,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'Personal Info',
          child: Row(
            children: [
              Icon(Icons.person_outline, size: 20.sp, color: Colors.grey.shade700),
              SizedBox(width: 12.w),
              Text('Personal Info', style: TextStyle(fontSize: 14.sp)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'Settings',
          child: Row(
            children: [
              Icon(Icons.settings_outlined, size: 20.sp, color: Colors.grey.shade700),
              SizedBox(width: 12.w),
              Text('Settings', style: TextStyle(fontSize: 14.sp)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'Notifications',
          child: Row(
            children: [
              Icon(Icons.notifications_outlined, size: 20.sp, color: Colors.grey.shade700),
              SizedBox(width: 12.w),
              Text('Notifications', style: TextStyle(fontSize: 14.sp)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'Help Center',
          child: Row(
            children: [
              Icon(Icons.help_outline, size: 20.sp, color: Colors.grey.shade700),
              SizedBox(width: 12.w),
              Text('Help Center', style: TextStyle(fontSize: 14.sp)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'Log out',
          child: Row(
            children: [
              Icon(Icons.logout, size: 20.sp, color: Colors.grey.shade700),
              SizedBox(width: 12.w),
              Text('Log out', style: TextStyle(fontSize: 14.sp)),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        DrawerMode mode = DrawerMode.user;
        final state = context.read<AuthCubit>().state;
        if (state is AuthAdminSuccess) mode = DrawerMode.admin;
        _select(value, context, mode);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        color: Colors.black.withValues(alpha: 0.02),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20.r,
              backgroundColor: Colors.white,
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryRed,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.unfold_more_outlined, size: 20.sp, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }
}
