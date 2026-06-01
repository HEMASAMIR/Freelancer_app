import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/core/utils/widgets/custom_app_bar.dart';
import 'package:freelancer/features/home/presentation/widget/custom_footer.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

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
            'Contact Us',
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
          SizedBox(height: 16.h),
          Text(
            'We\'re here to help you anytime and we love hearing from you. Whether you have a question, need support, or want to list your property, feel free to reach out through any of the following channels.',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.greyText,
              height: 1.6,
            ),
          ),
          SizedBox(height: 24.h),

          // ─── Call ──────────────────────────────────────
          _buildContactCard(
            icon: Icons.phone_rounded,
            title: '📞 Call Us',
            subtitle: 'For quick assistance, contact us directly via phone:',
            action: '+20 111 010 5107',
            onTap: () => _launchUrl('tel:+201110105107'),
          ),
          SizedBox(height: 16.h),

          // ─── WhatsApp ──────────────────────────────────────
          _buildContactCard(
            icon: Icons.chat_rounded,
            title: '💬 WhatsApp',
            subtitle: 'Reach out to us on WhatsApp for fast support:',
            action: '+20 111 010 5107',
            onTap: () => _launchUrl('https://wa.me/201110105107'),
          ),
          SizedBox(height: 16.h),

          // ─── Email ────────────────────────────────────────────────
          _buildContactCard(
            icon: Icons.email_rounded,
            title: '📧 Email Us',
            subtitle: 'You can also send us an email and we\'ll get back to you as soon as possible:',
            action: 'info@quickin.com',
            onTap: () => _launchUrl('mailto:info@quickin.com'),
          ),
          SizedBox(height: 16.h),

          // ─── Social Media ─────────────────────────────────────────
          Container(
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
                      child: Icon(
                        Icons.share_rounded,
                        color: AppColors.primaryBurgundy,
                        size: 24.r,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        '📱 Follow Us on Social Media',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.inkBlack,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    _socialButton(
                      icon: Icon(Icons.tiktok, color: Colors.black, size: 22.r), // TikTok icon
                      label: 'TikTok',
                      onTap: () => _launchUrl('https://www.tiktok.com/@quick.in1'),
                    ),
                    SizedBox(width: 16.w),
                    _socialButton(
                      icon: _buildInstagramIcon(size: 22.r),
                      label: 'Instagram',
                      onTap: () => _launchUrl('https://www.instagram.com/quickin.egy_?igsh=MXQ1OTNraXloY3dhOQ%3D%3D&utm_source=qr'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // ─── Office Address ───────────────────────────────────────
          _buildContactCard(
            icon: Icons.location_on_rounded,
            title: '📍 Our Office Address',
            subtitle: 'Visit us at our headquarters:',
            action: 'Address: Cairo, Egypt',
            onTap: null,
          ),
          SizedBox(height: 32.h),

          const CustomFooter(),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  // ─── Helper Widgets ─────────────────────────────────────────────────
  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String action,
    VoidCallback? onTap,
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
            subtitle,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.greyText,
              height: 1.6,
            ),
          ),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.backgroundCream,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.dividerGrey,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      action,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: onTap != null ? AppColors.primaryBurgundy : AppColors.inkBlack,
                      ),
                    ),
                  ),
                  if (onTap != null)
                    Icon(
                      Icons.open_in_new_rounded,
                      size: 18.r,
                      color: AppColors.primaryBurgundy,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialButton({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.backgroundCream,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.dividerGrey),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inkBlack,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch $url: $e');
    }
  }

  Widget _buildInstagramIcon({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: const LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            Color(0xFFFCAF45), // Yellow-orange
            Color(0xFFF58529), // Orange
            Color(0xFFDD2A7B), // Pink-red
            Color(0xFF812A90), // Purple
            Color(0xFF515BD4), // Blue
          ],
          stops: [0.0, 0.15, 0.5, 0.85, 1.0],
        ),
      ),
      padding: EdgeInsets.all(size * 0.15),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: size * 0.08),
          borderRadius: BorderRadius.circular(size * 0.22),
        ),
        child: Stack(
          children: [
            Center(
              child: Container(
                width: size * 0.28,
                height: size * 0.28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: size * 0.08),
                ),
              ),
            ),
            Positioned(
              top: size * 0.04,
              right: size * 0.04,
              child: Container(
                width: size * 0.07,
                height: size * 0.07,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
