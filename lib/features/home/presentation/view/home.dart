import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/Costant/app_color.dart';
import 'package:freelancer/core/utils/custom_app_bar.dart';
import 'package:freelancer/features/home/presentation/widget/custom_card.dart';
import 'package:freelancer/features/home/presentation/widget/custom_drawer.dart';
import 'package:freelancer/features/home/presentation/widget/custom_fotter.dart';
import 'package:freelancer/features/home/presentation/widget/custom_her_widget.dart';

class Homescreen extends StatelessWidget {
  const Homescreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppColors.bgColor,
      drawer: const CustomDrawer(),
      body: SafeArea(
        // استخدمنا ListView واحدة فقط عشان تشيل كل الكروت والـ Hero مع بعض
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const CustomAppBar(),
            const HeroWidget(), // الـ Hero بتاعك في الأول
            // هنا بنحط باقي المحتوى وبنديله Padding جانبي
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),

                  // زر المدينة (Cairo)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25.r),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text("Cairo", style: TextStyle(fontSize: 14.sp)),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // --- كل الكروت بتاعتك كاملة من غير حذف أي واحد ---
                  const PropertyCard(
                    title: "Test Place",
                    location: "Cairo, Egypt",
                    price: "1000",
                    imageUrl:
                        "https://images.unsplash.com/photo-1512917774080-9991f1c4c750?q=80&w=1000",
                    rating: 4.5,
                    guests: 1,
                    bedrooms: 1,
                    baths: 1,
                  ),

                  const PropertyCard(
                    title: "Modern Downtown Loft",
                    location: "New York City, New York",
                    price: "420",
                    imageUrl:
                        "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?q=80&w=1000",
                    rating: 4.5,
                    guests: 4,
                    bedrooms: 2,
                    baths: 2,
                  ),

                  const PropertyCard(
                    title: "Cozy Mountain Cabin",
                    location: "Aspen, Colorado",
                    price: "275",
                    imageUrl:
                        "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=1000",
                    rating: 4.5,
                    guests: 6,
                    bedrooms: 3,
                    baths: 2,
                  ),

                  const PropertyCard(
                    title: "Modern Downtown Loft",
                    location: "New York City, New York",
                    price: "420",
                    imageUrl:
                        "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?q=80&w=1000",
                    rating: 4.85,
                    guests: 4,
                    bedrooms: 2,
                    baths: 2,
                  ),

                  const PropertyCard(
                    title: "Cozy Mountain Cabin",
                    location: "Aspen, Colorado",
                    price: "275",
                    imageUrl:
                        "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=1000",
                    rating: 4.9,
                    guests: 6,
                    bedrooms: 3,
                    baths: 2,
                  ),

                  const CustomFotter(),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
