import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/di/service_locator.dart';
import 'package:freelancer/features/auth/view/presentation/view/help_center.dart';
import 'package:freelancer/features/auth/view/presentation/view/host_your_home.dart';
import 'package:freelancer/features/auth/view/presentation/view/login_view.dart';
import 'package:freelancer/features/auth/view/presentation/view/sign_up_view.dart';
import 'package:freelancer/features/search/data/search_model/search_params_model.dart';
import 'package:freelancer/features/search/logic/search_cubit/cubit/search_cubit.dart';
import 'package:freelancer/features/search/presentation/widget/airnab_search_model.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    const Color customRedColor = Color(0xFF8B1A1A);

    return Container(
      color: Colors.white, // خلفية الـ AppBar
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ── Logo Section ──────────────────────────────────────
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

              // ── Search Button (The Trigger) ───────────────────────
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => BlocProvider(
                      create: (_) => sl<SearchCubit>(),
                      // بنبعت null للـ listing لأننا لسه في مرحلة البحث العام
                      // وبنبعت كائن params فاضي بدل null
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
                        color: Colors.black.withOpacity(0.06),
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

              // ── Menu Section ──────────────────────────────────────
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
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
                      elevation: 4,
                      constraints: BoxConstraints(minWidth: 200.w),
                      icon: Icon(Icons.menu, color: Colors.black87, size: 20.r),
                      offset: const Offset(-150, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      onSelected: (value) =>
                          _handleMenuSelection(context, value),
                      itemBuilder: (_) => _buildMenuItems(),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ميثود مساعدة لبناء المنيو عشان الكود ميبقاش زحمة
  List<PopupMenuEntry<String>> _buildMenuItems() {
    return [
      const PopupMenuItem(
        value: 'signup',
        child: Text('Sign up', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      const PopupMenuItem(value: 'login', child: Text('Log in')),
      const PopupMenuDivider(height: 1),
      const PopupMenuItem(value: 'host', child: Text('Host your home')),
      const PopupMenuItem(value: 'help', child: Text('Help Center')),
    ];
  }

  // ميثود للـ Navigation
  void _handleMenuSelection(BuildContext context, String value) {
    Widget? targetView;
    switch (value) {
      case 'signup':
        targetView = const SignUpView();
        break;
      case 'login':
        targetView = const LoginView();
        break;
      case 'host':
        targetView = const HostYourHome();
        break;
      case 'help':
        targetView = const HelpCenter();
        break;
    }

    if (targetView != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true, // عشان ياخد مساحة الشاشة كاملة لو محتاج
        backgroundColor: Colors.white, // نفس لون الـ AppBar والهوم
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        builder: (context) => ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          child: SizedBox(
            height:
                MediaQuery.of(context).size.height * 0.9, // يغطي 90% من الهوم
            child: targetView!,
          ),
        ),
      );
    }
  }

  // زودنا الـ Height شوية لـ 80 عشان الـ Padding والـ SafeArea
  @override
  Size get preferredSize => Size.fromHeight(80.h);
}
