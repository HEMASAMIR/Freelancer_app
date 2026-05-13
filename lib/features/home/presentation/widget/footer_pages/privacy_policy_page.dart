import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/core/utils/widgets/custom_app_bar.dart';
import 'package:freelancer/features/home/presentation/widget/custom_footer.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
            'Privacy Policy',
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
            'At QuickIn, we respect your privacy and are committed to protecting your personal information. This Privacy Policy explains what information we collect, how we use it, and the choices you have regarding your data.',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.greyText,
              height: 1.6,
            ),
          ),
          SizedBox(height: 24.h),

          // ─── Consent ──────────────────────────────────────────────
          _buildCard(
            'Consent',
            'By using our website or services, you agree to this Privacy Policy and consent to the collection and use of information as described below.',
          ),
          SizedBox(height: 16.h),

          // ─── Information We Collect ────────────────────────────────
          _buildCardWithBullets(
            'Information We Collect',
            'We may collect the following types of information:',
            [
              'Personal details such as name, email address, phone number, and company name (when you register or contact us)',
              'Account information provided during sign-up',
              'Booking, order, or payment-related information (if applicable)',
              'Usage data such as pages visited, interactions, and preferences',
              'Location information (if required for service functionality)',
              'Messages, attachments, or other information you send to us directly',
            ],
          ),
          SizedBox(height: 16.h),

          // ─── How We Use Your Information ──────────────────────────
          _buildCardWithBullets(
            'How We Use Your Information',
            'We use the information we collect to:',
            [
              'Provide, operate, and maintain our services',
              'Improve and personalize user experience',
              'Process transactions and manage accounts',
              'Communicate with you about updates, support, and promotions',
              'Analyze usage to improve features and functionality',
              'Develop new services and offerings',
              'Prevent fraud and enhance security',
            ],
          ),
          SizedBox(height: 16.h),

          // ─── Log Files ────────────────────────────────────────────
          _buildCardWithBullets(
            'Log Files',
            'Like most websites, QuickIn uses log files. These may include:',
            [
              'IP addresses',
              'Browser type',
              'Internet Service Provider (ISP)',
              'Date and time of access',
              'Referring and exit pages',
              'Click activity',
            ],
            footer: 'This data is used for analytics, site administration, and improving user experience and is not directly linked to personally identifiable information.',
          ),
          SizedBox(height: 16.h),

          // ─── Cookies ──────────────────────────────────────────────
          _buildCardWithBullets(
            'Cookies and Tracking Technologies',
            'QuickIn uses cookies and similar technologies to:',
            [
              'Store user preferences',
              'Improve website performance',
              'Understand user behavior',
              'Personalize content and experience',
            ],
            footer: 'You may disable cookies through your browser settings, but some features may not function properly.',
          ),
          SizedBox(height: 16.h),

          // ─── Advertising ──────────────────────────────────────────
          _buildCardWithBullets(
            'Advertising and Third-Party Tools',
            'We may use third-party advertising tools such as Facebook Pixel or similar services to:',
            [
              'Deliver personalized advertisements',
              'Measure ad performance',
              'Improve marketing strategies',
            ],
            footer: 'These tools may collect anonymized and hashed data and may use cookies or similar technologies. QuickIn does not control how third-party advertisers use their data.',
          ),
          SizedBox(height: 16.h),

          // ─── Third-Party ──────────────────────────────────────────
          _buildCard(
            'Third-Party Privacy Policies',
            'Our Privacy Policy does not apply to third-party websites or advertisers. We encourage you to review their privacy policies for more information on how they handle your data and how to opt out of certain practices.',
          ),
          SizedBox(height: 16.h),

          // ─── GDPR ─────────────────────────────────────────────────
          _buildCardWithBullets(
            'Data Protection Rights (GDPR)',
            'If you are located in the EEA, you have the following rights:',
            [
              'Right to access your personal data',
              'Right to correct inaccurate data',
              'Right to request deletion of your data',
              'Right to restrict or object to processing',
              'Right to data portability',
            ],
            footer: 'We will respond to valid requests within one month.',
          ),
          SizedBox(height: 16.h),

          // ─── CCPA ─────────────────────────────────────────────────
          _buildCardWithBullets(
            'California Privacy Rights (CCPA)',
            'If you are a California resident, you have the right to:',
            [
              'Request disclosure of the personal data we collect',
              'Request deletion of your personal data',
              'Request that your data is not sold',
            ],
            footer: 'We do not sell personal information. Requests will be processed within one month.',
          ),
          SizedBox(height: 16.h),

          // ─── Data Security ────────────────────────────────────────
          _buildCard(
            'Data Security',
            'We use reasonable technical and organizational measures to protect your data. However, no method of transmission over the internet is 100% secure, and we cannot guarantee absolute security.',
          ),
          SizedBox(height: 16.h),

          // ─── Children ─────────────────────────────────────────────
          _buildCard(
            'Children\'s Privacy',
            'QuickIn does not knowingly collect personal data from children under the age of 13. If you believe a child has provided personal information, please contact us so we can remove it.',
          ),
          SizedBox(height: 16.h),

          // ─── Data Sharing ─────────────────────────────────────────
          _buildCardWithBullets(
            'Data Sharing',
            'We do not sell or rent your personal information. We may share data only with:',
            [
              'Trusted service providers who assist in operating our platform',
              'Legal authorities when required by law',
              'Parties involved in protecting our legal rights or preventing fraud',
            ],
          ),
          SizedBox(height: 16.h),

          // ─── Updates ──────────────────────────────────────────────
          _buildCard(
            'Updates to This Policy',
            'We may update this Privacy Policy from time to time. Any changes will be posted on this page, and significant updates may be communicated directly through email or our platform.',
          ),
          SizedBox(height: 32.h),

          const CustomFooter(),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  // ─── Helper Widgets ─────────────────────────────────────────────────
  Widget _buildCard(String title, String body) {
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
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.inkBlack,
            ),
          ),
          SizedBox(height: 12.h),
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

  Widget _buildCardWithBullets(
    String title,
    String intro,
    List<String> bullets, {
    String? footer,
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
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.inkBlack,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            intro,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.greyText,
              height: 1.6,
            ),
          ),
          SizedBox(height: 12.h),
          ...bullets.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 8.h, left: 4.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 6.h, right: 8.w),
                    child: Container(
                      width: 6.r,
                      height: 6.r,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryBurgundy,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
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
          if (footer != null) ...[
            SizedBox(height: 8.h),
            Text(
              footer,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.greyText,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
