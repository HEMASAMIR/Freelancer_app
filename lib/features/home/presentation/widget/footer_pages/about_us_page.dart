import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/core/utils/widgets/custom_app_bar.dart';
import 'package:freelancer/features/home/presentation/widget/custom_footer.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

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
            'About Us',
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

          // ─── Welcome Section ──────────────────────────────────────
          _buildCard(
            icon: Icons.home_work_rounded,
            title: 'Welcome to Quick In',
            body:
                'Your trusted destination for short-term rentals across Egypt. We bring together property owners and travelers in one seamless platform — whether you\'re planning a relaxing escape, a business stay, or discovering Egypt for the first time.',
          ),
          SizedBox(height: 16.h),

          // ─── Our Story ────────────────────────────────────────────
          _buildCard(
            icon: Icons.auto_stories_rounded,
            title: 'Our Story',
            body:
                'Quick In was created with a deep understanding of the real estate and hospitality market, built on over two decades of hands-on experience. We saw the need for a smarter, more reliable way to connect people with the right spaces — so we built a platform that makes renting simple, secure, and accessible for everyone.',
          ),
          SizedBox(height: 16.h),

          // ─── Our Vision ───────────────────────────────────────────
          _buildCard(
            icon: Icons.visibility_rounded,
            title: 'Our Vision',
            body:
                'To redefine short-term rentals in Egypt and become a leading name across the region, known for trust, quality, and exceptional user experience.',
          ),
          SizedBox(height: 16.h),

          // ─── Our Mission ──────────────────────────────────────────
          _buildCard(
            icon: Icons.rocket_launch_rounded,
            title: 'Our Mission',
            body:
                'Our mission is to make finding and listing properties effortless. We provide a dependable platform that connects guests and hosts, ensuring smooth, transparent, and enjoyable rental experiences every time.',
          ),
          SizedBox(height: 16.h),

          // ─── Our Values ───────────────────────────────────────────
          _buildValuesCard(),
          SizedBox(height: 16.h),

          // ─── Our Services ─────────────────────────────────────────
          _buildCard(
            icon: Icons.room_service_rounded,
            title: 'Our Services',
            body:
                'From vibrant cities to coastal escapes, Quick In offers a wide range of rental options across Egypt. Whether you want to list your property or find the perfect stay, everything you need is in one place.',
          ),
          SizedBox(height: 16.h),

          // ─── Why Choose Quick In? ─────────────────────────────────
          _buildWhyChooseCard(),
          SizedBox(height: 32.h),

          const CustomFooter(),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  // ─── Helper Widgets ─────────────────────────────────────────────────
  Widget _buildCard({
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: AppColors.primaryBurgundy.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: AppColors.primaryBurgundy, size: 24.r),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.inkBlack,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            body,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.greyText,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValuesCard() {
    final values = [
      {
        'icon': Icons.verified_user_rounded,
        'title': 'Trust & Transparency',
        'desc': 'Clear communication and honest pricing at every step',
      },
      {
        'icon': Icons.star_rounded,
        'title': 'Excellence',
        'desc': 'Carefully selected properties that meet high standards',
      },
      {
        'icon': Icons.lightbulb_rounded,
        'title': 'Innovation',
        'desc': 'Smart solutions that make booking faster and easier',
      },
      {
        'icon': Icons.shield_rounded,
        'title': 'Dependability',
        'desc': 'A platform you can rely on, whether you\'re hosting or renting',
      },
      {
        'icon': Icons.favorite_rounded,
        'title': 'Hospitality',
        'desc': 'Creating welcoming experiences for every guest',
      },
    ];

    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: AppColors.primaryBurgundy.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.diamond_rounded, color: AppColors.primaryBurgundy, size: 24.r),
              ),
              SizedBox(width: 12.w),
              Text(
                'Our Values',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.inkBlack,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          ...values.map(
            (v) => Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCream,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      v['icon'] as IconData,
                      color: AppColors.primaryBurgundy,
                      size: 20.r,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          v['title'] as String,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.inkBlack,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          v['desc'] as String,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhyChooseCard() {
    final reasons = [
      {'icon': Icons.bolt_rounded, 'text': 'Fast & Simple Process – Book your stay in just a few easy steps'},
      {'icon': Icons.verified_rounded, 'text': 'Verified Listings – Trusted properties for your peace of mind'},
      {'icon': Icons.attach_money_rounded, 'text': 'Competitive Pricing – Great value with transparent rates'},
      {'icon': Icons.support_agent_rounded, 'text': 'Reliable Support – Our team is always ready to assist you'},
      {'icon': Icons.credit_card_rounded, 'text': 'Easy Booking & Payments – Smooth reservations with flexible payment options'},
    ];

    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: AppColors.primaryBurgundy.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.emoji_events_rounded, color: AppColors.primaryBurgundy, size: 24.r),
              ),
              SizedBox(width: 12.w),
              Text(
                'Why Choose Quick In?',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.inkBlack,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          ...reasons.map(
            (r) => Padding(
              padding: EdgeInsets.only(bottom: 14.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    r['icon'] as IconData,
                    color: AppColors.primaryBurgundy,
                    size: 22.r,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      r['text'] as String,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.greyText,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
