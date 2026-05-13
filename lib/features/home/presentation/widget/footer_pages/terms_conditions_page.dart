import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/core/utils/widgets/custom_app_bar.dart';
import 'package:freelancer/features/home/presentation/widget/custom_footer.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

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
            'Terms and Conditions',
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

          // ─── Welcome ──────────────────────────────────────────────
          _buildCard([
            _sectionTitle('Welcome'),
            _paragraph(
              'Quick In Service is offered by Quick In, a digital platform operating in accordance with the applicable laws and regulations of the Arab Republic of Egypt.\n\n'
              'Please read these Terms and Conditions carefully before using the platform or making any booking. By signing up, activating an account, or using any service, you agree to be bound by these Terms ("General Terms and Conditions").',
            ),
          ]),
          SizedBox(height: 16.h),

          // ─── 1. General ───────────────────────────────────────────
          _buildCard([
            _numberedTitle('1. General'),
            _paragraph(
              'These General Terms, along with the Service Tariffs and Application Form, constitute the full agreement between you and quickin-eg.com for any service provided through the platform ("Service"), including any relevant software, content, or platform functionality.\n\n'
              'These Terms supersede any previous versions or prior agreements.\n\n'
              'They apply to all services available via the website, mobile apps, email communications, or phone services.\n\n'
              'By using the platform and completing bookings, you acknowledge reading, understanding, and agreeing to the Terms, including the Privacy Policy.\n\n'
              'The Arabic version is the official legally binding version. In case of discrepancy, the Arabic text prevails.',
            ),
          ]),
          SizedBox(height: 16.h),

          // ─── 2. Eligibility ───────────────────────────────────────
          _buildCard([
            _numberedTitle('2. Eligibility'),
            _paragraph(
              'Users must be at least 18 years old to use the platform unless otherwise stated.\n\n'
              'Some customers may not be eligible for certain services due to credit history, past payment records, or other factors.',
            ),
          ]),
          SizedBox(height: 16.h),

          // ─── 3. Amendments ────────────────────────────────────────
          _buildCard([
            _numberedTitle('3. Amendments'),
            _bulletList([
              'quickin-eg.com may amend these Terms or fees at any time.',
              'Amendments take effect immediately upon publication on the website.',
              'Users agree to review the platform regularly to remain aware of updates.',
              'Continued use signifies acceptance of any changes.',
            ]),
          ]),
          SizedBox(height: 16.h),

          // ─── 4. Nature and Scope of Services ──────────────────────
          _buildCard([
            _numberedTitle('4. Nature and Scope of Services'),
            _bulletList([
              'Platform Role: quickin-eg.com provides an online platform to advertise, sell, and book trips, residences, or other services.',
              'Intermediary Role: Once a booking is made, quickin-eg.com acts as an intermediary, sending booking details to the relevant service provider.',
              'Information Accuracy: While due diligence is taken, quickin-eg.com does not guarantee 100% accuracy of third-party information.',
              'Non-Endorsement: Listings are not recommendations or endorsements of service quality, location, or facilities.',
              'Account Responsibility: Users are responsible for their account details and must keep login credentials confidential.',
              'Offers & Language: Offers are displayed in Arabic by default; users can change the language.',
              'Service Provider Responsibility: Hosts/providers are responsible for updating pricing, availability, policies, and all other relevant information.',
            ]),
          ]),
          SizedBox(height: 16.h),

          // ─── 5. Host Responsibilities ─────────────────────────────
          _buildCard([
            _numberedTitle('5. Host Responsibilities'),
            _bulletList([
              'Confirm ownership and the legal right to rent the listed property.',
              'Provide accurate, complete property information.',
              'Maintain the property in good condition.',
              'Ensure insurance coverage.',
              'Respond promptly to bookings and inquiries.',
              'Comply with all platform terms and rules.',
            ]),
          ]),
          SizedBox(height: 16.h),

          // ─── 6. Client / Tenant Responsibilities ──────────────────
          _buildCard([
            _numberedTitle('6. Client / Tenant Responsibilities'),
            _bulletList([
              'Use the platform and rented property responsibly.',
              'Pay all platform fees and applicable charges on time.',
              'Care for the rented property and report any damages.',
              'Ensure any required insurance is valid.',
              'Comply with all platform rules and policies.',
            ]),
          ]),
          SizedBox(height: 16.h),

          // ─── 7. Payments and Invoices ──────────────────────────────
          _buildCard([
            _numberedTitle('7. Payments and Invoices'),
            _bulletList([
              'Online Payments: quickin-eg.com offers online payment through integrated methods (credit card, Apple Pay, Google Pay, etc.).',
              'Advance Payment: Users must pay in advance when booking a service, ensuring all payment details are correct and sufficient funds are available.',
              'Saved Payment Methods: Users may choose to save their payment methods for future transactions with consent.',
              'Unauthorized Use: Any suspected fraud or unauthorized use should be reported to the payment provider.',
              'E-Billing: quickin-eg.com provides e-billing. Delays caused by third parties or failure to access e-bills do not create liability.',
              'Invoice Disputes: Any dispute regarding invoice amounts must be reported within 7 days of the invoice date through official customer service channels.',
            ]),
          ]),
          SizedBox(height: 16.h),

          // ─── 8. Booking, Cancellation, and No-Show Policy ─────────
          _buildCard([
            _numberedTitle('8. Booking, Cancellation, and No-Show Policy'),
            _paragraph(
              'When making a booking, users accept the specific policies displayed during the booking process.\n\n'
              'Receiving a booking confirmation obligates the user to honor the booking and pay the full service fee as specified by the provider.\n\n'
              'Errors in pricing or calculations can be corrected by quickin-eg.com.\n\n'
              'Cancellation and other policies (age requirements, deposits, extra beds, breakfast, pets, accepted cards) are available on the provider\'s information page, during booking, or in the confirmation email.\n\n'
              'Pre-paid bookings follow the service provider\'s cancellation policy.\n\n'
              'Late arrivals should notify the service provider to avoid cancellation.\n\n'
              'Users are responsible for the actions of all members in their booking group and must obtain consent before sharing personal data.\n\n'
              'Refunds, cancellations, and no-show fees depend on the service provider\'s policies.',
            ),
          ]),
          SizedBox(height: 16.h),

          // ─── 9. Security Deposit ──────────────────────────────────
          _buildCard([
            _numberedTitle('9. Security Deposit'),
            _paragraph(
              'Hosts may require a security deposit based on the length of stay.\n\n'
              'Refunds are issued after inspection, subject to deductions for damages.',
            ),
          ]),
          SizedBox(height: 16.h),

          // ─── 10. Platform Fees ────────────────────────────────────
          _buildCard([
            _numberedTitle('10. Platform Fees'),
            _bulletList([
              'Host Commission: Currently, hosts pay 3% commission on bookings made through the platform, until further notice.',
              'Guest Commission: Currently, guests pay 10% commission on bookings made through the platform, until further notice.',
              'Currency: All transactions and fees are calculated in Egyptian Pounds (EGP) unless otherwise specified.',
            ]),
          ]),
          SizedBox(height: 16.h),

          // ─── 11. Prices ───────────────────────────────────────────
          _buildCard([
            _numberedTitle('11. Prices'),
            _bulletList([
              'Users agree to pay the full cost of services, including any applicable taxes.',
              'Displayed prices may be rounded; the final charge is based on the original price.',
              'Obvious misprints (e.g., a listing for 1 EGP) are not binding, and quickin-eg.com may cancel bookings with a refund of amounts paid.',
              'Crossed-out prices indicate the original price before discounts.',
            ]),
          ]),
          SizedBox(height: 16.h),

          // ─── 12. Privacy & Cookies ────────────────────────────────
          _buildCard([
            _numberedTitle('12. Privacy & Cookies'),
            _paragraph('Purpose of Data Collection: quickin-eg.com collects information to optimize service experience, including:'),
            _bulletList([
              'Full name, travel companions, payment info, and contact details.',
              'Additional details about upcoming trips, such as expected arrival times.',
              'Device Data: Information may be collected from your phone, tablet, computer, or other devices.',
              'Automatic Data Collection: Some data may be collected automatically.',
              'Sharing with Providers: Personal data is shared with service providers to complete bookings.',
              'Third-Party Collaboration: Data may also be shared with financial institutions, advertisers, and quickin-eg.com affiliates as needed.',
              'Legal Requirements: Data may be shared with government authorities if required by law.',
            ]),
          ]),
          SizedBox(height: 16.h),

          // ─── 13-16 Data Security, Liability, Insurance ────────────
          _buildCard([
            _numberedTitle('13. Data Security Measures'),
            _paragraph(
              'quickin-eg.com implements measures to prevent unauthorized access or misuse of personal data.\n\n'
              'The service is intended for individuals aged 16 and older, unless otherwise stated.\n\n'
              'Data of children is processed only with parental consent or when provided directly by parents/guardians.',
            ),
          ]),
          SizedBox(height: 16.h),

          _buildCard([
            _numberedTitle('14. Host & Client Liability'),
            _sectionTitle('Host / Owner Responsibilities'),
            _bulletList([
              'Comply with ownership and rental rights.',
              'Maintain the property in good condition.',
              'Provide insurance coverage where applicable.',
              'Ensure prompt communication regarding bookings and guest inquiries.',
            ]),
            SizedBox(height: 8.h),
            _sectionTitle('Client / Tenant Responsibilities'),
            _bulletList([
              'Use the platform and rented property responsibly.',
              'Report damages and maintain property condition.',
              'Follow all platform policies, including booking and payment rules.',
            ]),
          ]),
          SizedBox(height: 16.h),

          _buildCard([
            _numberedTitle('15. Insurance'),
            _paragraph(
              'Hosts are responsible for maintaining any required insurance.\n\n'
              'Clients may also be required to have insurance coverage as per the host\'s terms.\n\n'
              'Any disputes regarding insurance claims should be resolved between the client and host; quickin-eg.com is not liable for third-party insurance issues.',
            ),
          ]),
          SizedBox(height: 16.h),

          _buildCard([
            _numberedTitle('16. Limitation of Liability / Disclaimer'),
            _paragraph(
              'quickin-eg.com acts as an intermediary platform; it is not a party to the contract between hosts and clients.\n\n'
              'The platform is not responsible for errors, interruptions, incomplete information, or misrepresentation by service providers.\n\n'
              'All transactions, bookings, and disputes are primarily between the user and the host.\n\n'
              'quickin-eg.com is not liable for damages arising from the use of services, except as required by law.',
            ),
          ]),
          SizedBox(height: 16.h),

          // ─── 17-21 ────────────────────────────────────────────────
          _buildCard([
            _numberedTitle('17. Intellectual Property'),
            _paragraph(
              'All content on the platform, including logos, trademarks, text, and software, is the property of Quick In.\n\n'
              'Users may not copy, reproduce, distribute, or use any platform content for commercial purposes without explicit permission.\n\n'
              'User-generated content (photos, reviews, etc.) remains the property of the user, but quickin-eg.com has the right to display and use it on the platform.',
            ),
          ]),
          SizedBox(height: 16.h),

          _buildCard([
            _numberedTitle('18. Dispute Resolution'),
            _bulletList([
              'Direct Communication: Users and hosts should attempt to resolve disputes directly via platform communication channels.',
              'Platform Mediation: quickin-eg.com may act as a mediator in disputes but is not a party to the contract between user and host.',
              'Legal Action: Legal disputes may be escalated to courts in Egypt as per governing law.',
              'Financial Disputes: Any disagreements regarding payments, refunds, or fees must be reported promptly.',
            ]),
          ]),
          SizedBox(height: 16.h),

          _buildCard([
            _numberedTitle('19. Governing Law and Jurisdiction'),
            _paragraph(
              'These Terms are governed by the laws of the Arab Republic of Egypt.\n\n'
              'Any legal disputes arising from the use of the platform will be subject to the jurisdiction of competent Egyptian courts.',
            ),
          ]),
          SizedBox(height: 16.h),

          _buildCard([
            _numberedTitle('20. Special Conditions'),
            _bulletList([
              'Security Deposits: Hosts may require a deposit; conditions for its refund are determined by the host based on inspection.',
              'Platform Fees: All financial terms must be respected by both users and hosts.',
              'Booking Conditions: Specific terms for bookings, cancellations, and deposits apply as per each host\'s listing.',
            ]),
          ]),
          SizedBox(height: 16.h),

          _buildCard([
            _numberedTitle('21. Agreement Acceptance'),
            _paragraph(
              'By signing up, activating an account, or using quickin-eg.com, users accept these Terms and Conditions.\n\n'
              'Users acknowledge reading, understanding, and agreeing to all clauses, including amendments and updates.\n\n'
              'Users must review the platform periodically to remain aware of any changes.',
            ),
          ]),
          SizedBox(height: 32.h),

          const CustomFooter(),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  // ─── Helper Widgets ─────────────────────────────────────────────────
  static Widget _buildCard(List<Widget> children) {
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
        children: children,
      ),
    );
  }

  static Widget _sectionTitle(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryBurgundy,
        ),
      ),
    );
  }

  static Widget _numberedTitle(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.inkBlack,
        ),
      ),
    );
  }

  static Widget _paragraph(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        color: AppColors.greyText,
        height: 1.6,
      ),
    );
  }

  static Widget _bulletList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
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
          )
          .toList(),
    );
  }
}
