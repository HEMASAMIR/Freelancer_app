import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/core/di/service_locator.dart';
import 'package:freelancer/features/auth/logic/cubit/auth_cubit.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: AppColors.dividerGrey, thickness: 0.5),
        SizedBox(height: 20.h),

        // الشعار والكلمة الافتتاحية
        Image.asset("assets/images/splash.png", height: 50.h),
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

        // قسم Support
        _buildFooterSection(context, "Support", [
          _FooterLink("Terms and Conditions", () => _navigateTo(context, const TermsConditionsPage())),
          _FooterLink("Privacy Policy", () => _navigateTo(context, const PrivacyPolicyPage())),
        ]),

        // قسم Hosting
        _buildFooterSection(context, "Hosting", [
          _FooterLink("Become a Host", () => _navigateTo(context, const BecomeHostPage())),
        ]),

        // قسم QuickIn
        _buildFooterSection(context, "QuickIn", [
          _FooterLink("About Us", () => _navigateTo(context, const AboutUsPage())),
          _FooterLink("Contact Us", () => _navigateTo(context, const ContactUsPage())),
          _FooterLink("Careers", () => _navigateTo(context, const CareersPage())),
        ]),

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
              fontSize: 16.sp,
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
                    fontSize: 14.sp,
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
}

class _FooterLink {
  final String label;
  final VoidCallback onTap;

  _FooterLink(this.label, this.onTap);
}
