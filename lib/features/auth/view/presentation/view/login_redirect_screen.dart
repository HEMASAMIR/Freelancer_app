import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/app_router/routes.dart';
import 'package:freelancer/core/shared_helper/app_color.dart';
import 'package:freelancer/core/utils/widgets/custom_app_bar.dart';
import 'package:freelancer/features/auth/logic/cubit/auth_cubit.dart';
import 'package:freelancer/features/home/presentation/widget/custom_drawer.dart';
import 'package:freelancer/features/home/presentation/widget/custom_footer.dart';

class LoginRedirectScreen extends StatelessWidget {
  const LoginRedirectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3F0),
      appBar: const CustomAppBar(),
      drawer: const SideDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Log in to QuickIn',
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.label,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Welcome back! Please sign in to continue.',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.sub,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 32.h),
                        // Login Button
                        _buildActionButton(
                          context,
                          label: 'Log In',
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.login),
                          isPrimary: true,
                        ),
                        SizedBox(height: 12.h),
                        // Sign Up Button
                        _buildActionButton(
                          context,
                          label: 'Create Account',
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.signUp),
                          isPrimary: false,
                        ),
                        SizedBox(height: 24.h),
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Text(
                                'or',
                                style: TextStyle(color: AppColors.sub),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        // Google Sign In Button
                        _buildSocialButton(
                          context,
                          label: 'Continue with Google',
                          isGoogle: true,
                          onPressed: () {
                            context.read<AuthCubit>().signInWithGoogle();
                          },
                        ),
                        SizedBox(height: 12.h),
                        // Apple Sign In Button
                        _buildSocialButton(
                          context,
                          label: 'Continue with Apple',
                          icon: Icons.apple,
                          color: const Color(0xFF5B0F16),
                          onPressed: () {
                            context.read<AuthCubit>().signInWithApple();
                          },
                        ),
                        SizedBox(height: 32.h),
                        TextButton(
                          onPressed: () => Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.home,
                            (route) => false,
                          ),
                          child: Text(
                            'Skip for now',
                            style: TextStyle(
                              color: AppColors.sub,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Footer
                const CustomFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return SizedBox(
      height: 52.h,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? const Color(0xFF5B0F16) : Colors.white,
          foregroundColor: isPrimary ? Colors.white : const Color(0xFF5B0F16),
          side: isPrimary ? null : const BorderSide(color: Color(0xFF5B0F16)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context, {
    required String label,
    IconData? icon,
    Color? color,
    bool isGoogle = false,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 52.h,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: isGoogle
            ? Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Google_%22G%22_Logo.svg/512px-Google_%22G%22_Logo.svg.png',
                height: 24.h,
              )
            : Icon(icon, color: Colors.white, size: 24.sp),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: isGoogle ? Colors.black87 : Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isGoogle ? Colors.white : (color ?? Colors.black),
          foregroundColor: isGoogle ? Colors.black87 : Colors.white,
          side: isGoogle ? const BorderSide(color: Colors.black12) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
