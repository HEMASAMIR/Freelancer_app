import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/core/di/service_locator.dart';
import 'package:freelancer/core/utils/widgets/quickin_logo.dart';
import 'package:freelancer/features/auth/logic/cubit/auth_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:freelancer/features/home/presentation/widget/footer_pages/about_us_page.dart';
import 'package:freelancer/features/home/presentation/widget/footer_pages/become_host_page.dart';
import 'package:freelancer/features/home/presentation/widget/footer_pages/careers_page.dart';
import 'package:freelancer/features/home/presentation/widget/footer_pages/contact_us_page.dart';
import 'package:freelancer/features/home/presentation/widget/footer_pages/privacy_policy_page.dart';
import 'package:freelancer/features/home/presentation/widget/footer_pages/terms_conditions_page.dart';
import 'package:freelancer/features/home/presentation/widget/footer_pages/sitemap_page.dart';


class CustomFooter extends StatelessWidget {
  const CustomFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: AppColors.dividerGrey, thickness: 0.5),
        SizedBox(height: 20.h),

        // الشعار والكلمة الافتتاحية
        Align(
          alignment: Alignment.centerLeft,
          child: QuickInLogo(height: 70.h, isHorizontal: false),
        ),
        SizedBox(height: 10.h),
        Text(
          "Find it. Book it. Live it.",
          style: TextStyle(
            color: AppColors.primaryBurgundy,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          "Curated stays for slow travelers. Handpicked homes designed for comfort, beauty, and calm.",
          style: TextStyle(color: AppColors.greyText, fontSize: 13.sp),
        ),

        SizedBox(height: 30.h),

        SizedBox(height: 30.h),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFooterSection(context, "Support", [
              _FooterLink("Terms", () => _navigateTo(context, const TermsConditionsPage())),
              _FooterLink("Privacy", () => _navigateTo(context, const PrivacyPolicyPage())),
            ]),
            _buildFooterSection(context, "Hosting", [
              _FooterLink("Become Host", () => _navigateTo(context, const BecomeHostPage())),
            ]),
            _buildFooterSection(context, "QuickIn", [
              _FooterLink("About", () => _navigateTo(context, const AboutUsPage())),
              _FooterLink("Contact", () => _navigateTo(context, const ContactUsPage())),
              _FooterLink("Careers", () => _navigateTo(context, const CareersPage())),
            ]),
          ],
        ),

        const Divider(color: AppColors.dividerGrey),
        SizedBox(height: 10.h),

        // Social Links
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.chat_rounded, color: const Color(0xFF25D366), size: 28.sp), // WhatsApp Green
              onPressed: () => _launchUrl('https://wa.me/201110105107'),
            ),
            SizedBox(width: 15.w),
            IconButton(
              icon: Icon(Icons.tiktok, color: Colors.black, size: 28.sp), // TikTok Black
              onPressed: () => _launchUrl('https://www.tiktok.com/@quick.in1'),
            ),
            SizedBox(width: 15.w),
            IconButton(
              icon: _buildInstagramIcon(size: 26.sp),
              onPressed: () => _launchUrl('https://www.instagram.com/quickin.egy_?igsh=MXQ1OTNraXloY3dhOQ%3D%3D&utm_source=qr'),
            ),
          ],
        ),
        SizedBox(height: 10.h),

        const Divider(color: AppColors.dividerGrey),
        SizedBox(height: 15.h),

        // الجزء السفلي
        Wrap(
          spacing: 4.w,
          runSpacing: 4.h,
          children: [
            Text(
              "© 2026 QuickIn, Inc.",
              style: TextStyle(fontSize: 12.sp, color: AppColors.greyText),
            ),
            Text(" · ", style: TextStyle(fontSize: 12.sp, color: AppColors.greyText)),
            _bottomLink(context, "Terms", const TermsConditionsPage()),
            Text(" · ", style: TextStyle(fontSize: 12.sp, color: AppColors.greyText)),
            _bottomLink(context, "Sitemap", const SitemapPage()),
            Text(" · ", style: TextStyle(fontSize: 12.sp, color: AppColors.greyText)),
            _bottomLink(context, "Privacy", const PrivacyPolicyPage()),
          ],
        ),

        SizedBox(height: 50.h),
      ],
    ),
    );
  }

  Widget _buildFooterSection(
    BuildContext context,
    String title,
    List<_FooterLink> links,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 25.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.inkBlack,
            ),
          ),
          SizedBox(height: 10.h),
          ...links.map(
            (link) => Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: GestureDetector(
                onTap: link.onTap,
                child: Text(
                  link.label,
                  style: TextStyle(
                    color: AppColors.greyText,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomLink(BuildContext context, String label, Widget? page) {
    return GestureDetector(
      onTap: page != null ? () => _navigateTo(context, page) : null,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          color: AppColors.greyText,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: sl<AuthCubit>()),
          ],
          child: page,
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

class _FooterLink {
  final String label;
  final VoidCallback onTap;

  _FooterLink(this.label, this.onTap);
}
