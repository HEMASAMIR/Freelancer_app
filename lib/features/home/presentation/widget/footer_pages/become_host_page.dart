import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/app_router/routes.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/core/utils/widgets/custom_app_bar.dart';
import 'package:freelancer/features/auth/logic/cubit/auth_cubit.dart';
import 'package:freelancer/features/auth/logic/cubit/auth_state.dart';
import 'package:freelancer/features/auth/view/presentation/view/login_view.dart';
import 'package:freelancer/features/home/presentation/widget/custom_footer.dart';

class BecomeHostPage extends StatelessWidget {
  const BecomeHostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      appBar: const CustomAppBar(),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        children: [
          // ─── Header ───────────────────────────────────────────────
          Text(
            'Become a Host',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.inkBlack,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            width: 60.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.primaryBurgundy,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 24.h),

          // ─── Hero Card ────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryBurgundy,
                  AppColors.primaryBurgundy.withValues(alpha: 0.85),
                ],
              ),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBurgundy.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.home_work_rounded,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 48.r,
                ),
                SizedBox(height: 20.h),
                Text(
                  'Turn Your Property\nInto Income',
                  style: TextStyle(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Join thousands of hosts in Egypt who are earning by sharing their spaces on Quick In.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.6,
                  ),
                ),
                SizedBox(height: 24.h),
                BlocBuilder<AuthCubit, AuthCubitState>(
                  builder: (context, state) {
                    return GestureDetector(
                      onTap: () {
                        if (state is AuthSuccess || state is AuthAdminSuccess) {
                          Navigator.pushNamed(context, AppRoutes.myListings);
                        } else {
                          showDialog(
                            context: context,
                            builder: (_) => BlocProvider.value(
                              value: context.read<AuthCubit>(),
                              child: const LoginView(),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 28.w,
                          vertical: 14.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        child: Text(
                          'Start Hosting',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBurgundy,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // ─── How It Works ─────────────────────────────────────────
          _buildSectionTitle('How It Works'),
          SizedBox(height: 16.h),
          _buildStepCard(
            number: '1',
            title: 'Create Your Listing',
            desc: 'Add photos, set your price, and describe your space. It\'s free and takes just a few minutes.',
            icon: Icons.add_photo_alternate_rounded,
          ),
          SizedBox(height: 12.h),
          _buildStepCard(
            number: '2',
            title: 'Welcome Your Guests',
            desc: 'Accept booking requests and prepare your space. We\'ll help you with tips and resources.',
            icon: Icons.people_rounded,
          ),
          SizedBox(height: 12.h),
          _buildStepCard(
            number: '3',
            title: 'Get Paid',
            desc: 'Payments are processed automatically after each confirmed checkout. Track your earnings in your dashboard.',
            icon: Icons.account_balance_wallet_rounded,
          ),
          SizedBox(height: 24.h),

          // ─── Why Host With Us ─────────────────────────────────────
          _buildSectionTitle('Why Host With Quick In?'),
          SizedBox(height: 16.h),
          _buildFeatureCard(
            icon: Icons.security_rounded,
            title: 'Secure Payments',
            desc: 'We handle all payments and ensure you get paid on time, every time.',
          ),
          SizedBox(height: 12.h),
          _buildFeatureCard(
            icon: Icons.support_agent_rounded,
            title: '24/7 Support',
            desc: 'Our dedicated team is available around the clock to help you with any questions.',
          ),
          SizedBox(height: 12.h),
          _buildFeatureCard(
            icon: Icons.trending_up_rounded,
            title: 'Maximize Your Earnings',
            desc: 'Smart pricing tools and wide visibility help you earn more from your property.',
          ),
          SizedBox(height: 12.h),
          _buildFeatureCard(
            icon: Icons.verified_user_rounded,
            title: 'Verified Guests',
            desc: 'All guests are verified through our platform, giving you peace of mind.',
          ),
          SizedBox(height: 12.h),
          _buildFeatureCard(
            icon: Icons.shield_rounded,
            title: 'Host Protection',
            desc: 'Security deposits and our trust system protect your property from damages.',
          ),
          SizedBox(height: 24.h),

          // ─── Commission Info ──────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.primaryBurgundy.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primaryBurgundy,
                      size: 22.r,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Platform Fees',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.inkBlack,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                _feeRow('Host Commission', '3%'),
                SizedBox(height: 8.h),
                _feeRow('Guest Commission', '10%'),
                SizedBox(height: 12.h),
                Text(
                  'All transactions are calculated in Egyptian Pounds (EGP). Commission rates are subject to change with notice.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.greyText,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),

          const CustomFooter(),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  // ─── Helper Widgets ─────────────────────────────────────────────────
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.inkBlack,
      ),
    );
  }

  Widget _buildStepCard({
    required String number,
    required String title,
    required String desc,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: AppColors.primaryBurgundy,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: AppColors.primaryBurgundy, size: 20.r),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.inkBlack,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.greyText,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: AppColors.primaryBurgundy.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: AppColors.primaryBurgundy, size: 24.r),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.inkBlack,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.greyText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _feeRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.greyText,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppColors.primaryBurgundy.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBurgundy,
            ),
          ),
        ),
      ],
    );
  }
}
