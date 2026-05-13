import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/core/utils/widgets/custom_app_bar.dart';
import 'package:freelancer/features/home/presentation/widget/custom_drawer.dart';
import 'package:freelancer/features/home/presentation/widget/custom_footer.dart';

class SitemapPage extends StatelessWidget {
  const SitemapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: const CustomAppBar(),
      drawer: const SideDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sitemap',
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.inkBlack,
                      letterSpacing: -1,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Navigate through our platform to find exactly what you are looking for.',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.greyText,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 48.h),
                  
                  // Top Destinations
                  _buildSectionTitle('Top Destinations'),
                  _buildLinksGrid([
                    'Cairo, Egypt',
                    'Alexandria, Egypt',
                    'Giza, Egypt',
                    'Sharm El-Sheikh',
                    'Hurghada',
                    'Luxor & Aswan',
                    'North Coast',
                    'Dahab',
                  ]),
                  
                  SizedBox(height: 40.h),
                  
                  // Property Types
                  _buildSectionTitle('Property Types'),
                  _buildLinksGrid([
                    'Apartments',
                    'Villas',
                    'Chalets',
                    'Studios',
                    'Shared Rooms',
                    'Boutique Hotels',
                    'Unique Stays',
                    'Beachfront',
                  ]),
                  
                  SizedBox(height: 40.h),

                  // Support
                  _buildSectionTitle('Support & Help'),
                  _buildLinksGrid([
                    'Help Center',
                    'Safety Center',
                    'Cancellation Options',
                    'Our COVID-19 Response',
                    'Supporting People with Disabilities',
                    'Report a Neighborhood Concern',
                  ]),

                  SizedBox(height: 40.h),

                  // Hosting
                  _buildSectionTitle('Hosting'),
                  _buildLinksGrid([
                    'Try Hosting',
                    'AirCover for Hosts',
                    'Explore Hosting Resources',
                    'Visit our Community Forum',
                    'How to Host Responsibly',
                  ]),
                  
                  SizedBox(height: 40.h),
                  
                  // About
                  _buildSectionTitle('QuickIn'),
                  _buildLinksGrid([
                    'Newsroom',
                    'Learn about new features',
                    'Letter from our founders',
                    'Careers',
                    'Investors',
                    'QuickIn Luxe',
                  ]),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: CustomFooter(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.inkBlack,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            height: 2.h,
            width: 40.w,
            color: AppColors.primaryBurgundy,
          ),
        ],
      ),
    );
  }

  Widget _buildLinksGrid(List<String> links) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 5,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: links.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            // Placeholder navigation
          },
          child: Text(
            links[index],
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.greyText,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }
}
