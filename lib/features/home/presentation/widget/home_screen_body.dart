import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/core/di/service_locator.dart';
import 'package:freelancer/features/search/data/search_model/search_params_model.dart';
import 'package:freelancer/features/search/logic/search_cubit/cubit/search_cubit.dart';
import 'package:freelancer/features/search/logic/search_cubit/cubit/search_state.dart';
import 'package:freelancer/features/search/presentation/view/search_result_screen.dart';
import 'package:freelancer/features/search/presentation/widget/property_listing_card.dart';
import 'location_tag_item.dart';
import 'package:freelancer/features/home/presentation/widget/best_offers_banner.dart';
import 'package:freelancer/features/home/presentation/widget/custom_footer.dart';
import 'package:freelancer/features/home/presentation/widget/custom_her_widget.dart';

class HomescreenBody extends StatefulWidget {
  const HomescreenBody({super.key});

  @override
  State<HomescreenBody> createState() => _HomescreenBodyState();
}

class _HomescreenBodyState extends State<HomescreenBody> {
  String _selectedCategory = 'Best Offers';

  final List<String> categories = [
    'Best Offers',
    'Marakia',
    'Main Office',
    'Cairo',
  ];

  @override
  void initState() {
    super.initState();
    // Load default listings on first open
    _fetchListings(_selectedCategory);
  }

  void _fetchListings(String cat) {
    final params = cat == 'Best Offers'
        ? SearchParamsModel(bestOffer: true)
        : SearchParamsModel(location: cat);
    context.read<SearchCubit>().getListings(params: params);
  }

  void _onCategoryTap(String city) {
    setState(() => _selectedCategory = city);
    _fetchListings(city);
  }

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

              // ── Category chips ────────────────────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: categories.map((city) {
                    return Padding(
                      padding: EdgeInsets.only(right: 10.w),
                      child: LocationTagItem(
                        title: city,
                        isSelected: _selectedCategory == city,
                        onTap: () => _onCategoryTap(city),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 24.h),

              // ── Section title ─────────────────────────────────────
              Text(
                _selectedCategory == 'Best Offers'
                    ? 'Top picks for you'
                    : 'Listings in $_selectedCategory',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkBlack,
                ),
              ),
              SizedBox(height: 16.h),

              // ── Live listings from API ─────────────────────────────
              BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  if (state is SearchLoading) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primaryBurgundy, strokeWidth: 2.5),
                      ),
                    );
                  }
                  if (state is SearchError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(state.message,
                            style: const TextStyle(color: AppColors.greyText)),
                      ),
                    );
                  }
                  if (state is SearchSuccess) {
                    if (state.listings.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.home_outlined,
                                  size: 40,
                                  color:
                                      AppColors.greyText.withValues(alpha: 0.4)),
                              const SizedBox(height: 12),
                              Text(
                                'No listings found',
                                style: TextStyle(
                                    fontSize: 15.sp, color: AppColors.greyText),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: state.listings
                          .take(5) // show first 5 on home
                          .map((listing) => PropertyListingCard(
                                listing: listing,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider(
                                      create: (_) => sl<SearchCubit>()
                                        ..getListingDetails(
                                            id: listing.id?.toString() ?? ''),
                                      child: SearchResultScreen(
                                          params: SearchParamsModel()),
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              SizedBox(height: 40.h),
              const CustomFooter(),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ],
    );
  }
}
