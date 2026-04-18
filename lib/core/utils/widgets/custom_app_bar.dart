import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/app_router/routes.dart';
import 'package:freelancer/core/di/service_locator.dart';
import 'package:freelancer/core/shared_helper/app_color.dart'; // تأكد من المسار الصحيح للالوان
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_cubit.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_state.dart';
import 'package:freelancer/features/auth/view/presentation/view/help_center.dart';
import 'package:freelancer/features/auth/view/presentation/view/login_view.dart';
import 'package:freelancer/features/auth/view/presentation/view/sign_up_view.dart';
import 'package:freelancer/features/search/data/search_model/search_params_model.dart';
import 'package:freelancer/features/search/logic/search_cubit/cubit/search_cubit.dart';
import 'package:freelancer/features/search/presentation/widget/airnab_search_model.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    Color customRedColor = AppColors.maroon;

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Q',
                    style: TextStyle(
                      color: customRedColor,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                  Text(
                    'QUICK IN',
                    style: TextStyle(
                      color: customRedColor,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),

              // Search Bar Section
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => BlocProvider(
                      create: (_) => sl<SearchCubit>(),
                      child: AirbnbSearchModal(
                        initialParams: SearchParamsModel(),
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
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
                          fontSize: 13.sp,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      CircleAvatar(
                        radius: 14.r,
                        backgroundColor: customRedColor,
                        child: Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 15.r,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Menu & Profile Section
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30.r),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PopupMenuButton<String>(
                          offset: Offset(40.w, 45.h),
                          icon: Icon(
                            Icons.menu,
                            color: Colors.black87,
                            size: 20.r,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          constraints: BoxConstraints(minWidth: 200.w),
                          menuPadding: EdgeInsets.zero,
                          onSelected: (value) =>
                              _handleMenuSelection(context, value),
                          itemBuilder: (_) {
                            if (state is AuthSuccess ||
                                state is AuthAdminSuccess) {
                              final user = state is AuthSuccess
                                  ? state.user
                                  : (state as AuthAdminSuccess).user;
                              final String name =
                                  user.userMetadata['full_name'] ??
                                  user.email.split('@')[0];
                              return [
                                PopupMenuItem(
                                  enabled: false,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                      Text(
                                        user.email ?? '',
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const PopupMenuDivider(height: 1),
                                _buildPopupItem('dashboard', 'Dashboard'),
                                _buildPopupItem('trips', 'Trips'),
                                _buildPopupItem('wishlists', 'Wishlists'),
                                const PopupMenuDivider(height: 1),
                                _buildPopupItem(
                                  'manage_listings',
                                  'Manage listings',
                                ),
                                _buildPopupItem('bookings', 'Bookings'),
                                const PopupMenuDivider(height: 1),
                                _buildPopupItem('account', 'Account'),
                                _buildPopupItem('help', 'Help Center'),
                                const PopupMenuDivider(height: 1),
                                _buildPopupItem('logout', 'Log out'),
                              ];
                            }

                            return [
                              _buildPopupItem(
                                'signup',
                                'Sign up',
                                isBold: true,
                              ),
                              _buildPopupItem('login', 'Log in'),
                              const PopupMenuDivider(height: 1),
                              _buildPopupItem('host', 'Host your home'),
                              _buildPopupItem('help', 'Help Center'),
                            ];
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 6.w),
                          child: Icon(
                            Icons.account_circle,
                            size: 26.r,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupItem(
    String value,
    String text, {
    bool isBold = false,
  }) {
    return PopupMenuItem<String>(
      value: value,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      height: 38.h,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: isBold ? FontWeight.w500 : FontWeight.w400,
          color: Colors.black87,
        ),
      ),
    );
  }

  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'login':
        showDialog(context: context, builder: (_) => const LoginView());
        break;

      case 'signup':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SignUpView()),
        );
        break;

      case 'host':
        final state = context.read<AuthCubit>().state;
        if (state is AuthSuccess || state is AuthAdminSuccess) {
          Navigator.pushNamed(context, AppRoutes.home);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors
                  .maroon, // استخدمنا اللون المارون بتاعك عشان يبقى شيك
              behavior: SnackBarBehavior
                  .floating, // خليناه عايم مش لزق في الشاشة من تحت
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  12.r,
                ), // زوايا مستديرة تليق بالديزاين
              ),
              margin: EdgeInsets.all(
                16.w,
              ), // مسافة من الجوانب عشان الـ floating يبان
              content: Text(
                'من فضلك سجل دخولك أولاً',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              action: SnackBarAction(
                label: 'Login',
                textColor:
                    Colors.white, // لون الزرار أبيض عشان يظهر على المارون
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const LoginView(),
                ),
              ),
            ),
          );
        }
        break;

      case 'help':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HelpCenter()),
        );
        break;

      case 'dashboard':
        {
          final authState = context.read<AuthCubit>().state;
          if (authState is AuthAdminSuccess) {
            Navigator.pushNamed(context, AppRoutes.adminDashboard);
          } else {
            // غير الادمن بيروح للهوم
            Navigator.pushNamed(context, AppRoutes.home);
          }
          break;
        }

      case 'trips':
      case 'bookings':
        Navigator.pushNamed(context, AppRoutes.trips);
        break;

      case 'wishlists':
        Navigator.pushNamed(context, AppRoutes.wishlists);
        break;

      case 'account':
        Navigator.pushNamed(context, AppRoutes.account);
        break;

      case 'manage_listings':
        {
          final authState = context.read<AuthCubit>().state;
          if (authState is AuthAdminSuccess) {
            // الادمن فقط يدخل لإدارة اللسينجز
            Navigator.pushNamed(context, AppRoutes.adminDashboard);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Admin access only'),
                backgroundColor: AppColors.maroon,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                margin: EdgeInsets.all(16.w),
              ),
            );
          }
          break;
        }

      case 'logout':
        context.read<AuthCubit>().signOut();
        break;
    }
  }

  @override
  Size get preferredSize => Size.fromHeight(80.h);
}
