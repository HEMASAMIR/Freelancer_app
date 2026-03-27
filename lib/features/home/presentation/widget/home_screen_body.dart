import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/di/service_locator.dart';
import 'package:freelancer/features/search/logic/search_cubit/cubit/search_cubit.dart';
import 'location_tag_item.dart';
import 'package:freelancer/features/home/presentation/widget/best_offers_banner.dart';
import 'package:freelancer/features/home/presentation/widget/custom_card.dart';
import 'package:freelancer/features/home/presentation/widget/custom_fotter.dart';
import 'package:freelancer/features/home/presentation/widget/custom_her_widget.dart';

// ✅ استيراد الملفات المطلوبة للانتقال
import 'package:freelancer/features/search/presentation/view/search_result_screen.dart';
import 'package:freelancer/features/search/data/search_model/search_params_model.dart';

class HomescreenBody extends StatefulWidget {
  const HomescreenBody({super.key});

  @override
  State<HomescreenBody> createState() => _HomescreenBodyState();
}

class _HomescreenBodyState extends State<HomescreenBody> {
  String selectedCategory = "Best Offers";

  final List<String> categories = [
    "Best Offers",
    "Marakia",
    "Main Office",
    "Cairo",
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      physics: const BouncingScrollPhysics(),
      children: [
        const BestOffersBanner(),
        const HeroWidget(),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24.h),

              // ✅ قسم التاجز (المدن) سكرول عرضي
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: categories.map((city) {
                    return Padding(
                      padding: EdgeInsets.only(right: 10.w),
                      child: LocationTagItem(
                        title: city,
                        isSelected: selectedCategory == city,
                        onTap: () {
                          // 1. تحديث شكل التاج في الصفحة الحالية
                          setState(() {
                            selectedCategory = city;
                          });

                          // 2. الانتقال لصفحة النتائج مع توفير الـ Cubit
                          if (city != "Best Offers") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlocProvider(
                                  // بنستخدم sl عشان نجيب الـ SearchCubit اللي سجلناه في الـ Service Locator
                                  create: (context) => sl<SearchCubit>(),
                                  child: SearchResultScreen(
                                    params: SearchParamsModel(
                                      location:
                                          city, // تمرير المدينة اللي ضغطت عليها
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              SizedBox(height: 24.h),

              // ✅ قائمة العقارات الافتراضية في الهوم (قبل الانتقال)
              const PropertyCard(
                title: "Featured Property",
                location: "Cairo, Egypt",
                price: "1000",
                imageUrl:
                    "https://images.unsplash.com/photo-1512917774080-9991f1c4c750?q=80&w=1000",
                rating: 4.5,
                guests: 1,
                bedrooms: 1,
                baths: 1,
              ),

              SizedBox(height: 40.h),
              const CustomFotter(),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ],
    );
  }
}
