import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/app_router/routes.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/features/search/data/search_model/search_params_model.dart';
import 'package:freelancer/features/search/logic/search_cubit/cubit/search_cubit.dart';
import 'package:freelancer/features/search/logic/search_cubit/cubit/search_state.dart';
import 'package:freelancer/features/search/presentation/widget/property_listing_card.dart';
import 'location_tag_item.dart';
import 'package:freelancer/features/home/presentation/widget/best_offers_banner.dart';
import 'package:freelancer/features/home/presentation/widget/custom_footer.dart';
import 'package:freelancer/features/home/presentation/widget/custom_her_widget.dart';
import 'package:freelancer/core/utils/widgets/listings_sort_header.dart';
import 'package:freelancer/features/search/data/search_model/listing_model.dart';
import 'package:freelancer/core/utils/widgets/elegant_toast.dart';

class HomescreenBody extends StatefulWidget {
  const HomescreenBody({super.key});

  @override
  State<HomescreenBody> createState() => _HomescreenBodyState();
}

class _HomescreenBodyState extends State<HomescreenBody> {
  String _selectedCategory = 'All';
  String _selectedSort = 'Recommended';
  final List<String> _sortOptions = [
    'Recommended',
    'Price: Low to High',
    'Price: High to Low',
    'Highest Rated',
    'Newest',
  ];

  final List<String> categories = [
    'All',
    'Best Offers',
    'El Gouna',
    'Marakia',
    'Cairo',
  ];

  @override
  void initState() {
    super.initState();
    // Load default listings on first open
    _fetchListings(_selectedCategory);
  }

  void _fetchListings(String cat) {
    SearchParamsModel params;
    if (cat == 'All') {
      params = SearchParamsModel();
    } else if (cat == 'Best Offers') {
      params = SearchParamsModel(bestOffer: true);
    } else {
      params = SearchParamsModel(location: cat);
    }
    context.read<SearchCubit>().getListings(params: params);
  }

  void _onCategoryTap(String city) {
    setState(() => _selectedCategory = city);
    _fetchListings(city);
    
    // Show elegant animated toast
    String displayCity = city == 'All' ? 'All listings' : city;
    ElegantToast.show(context, 'Showing $displayCity', icon: Icons.location_on_rounded);
  }

  List<ListingModel> _getSortedListings(List<ListingModel> listings) {
    List<ListingModel> sorted = List.from(listings);
    switch (_selectedSort) {
      case 'Price: Low to High':
        sorted.sort((a, b) => (a.displayPrice ?? a.pricePerNight ?? 0)
            .compareTo(b.displayPrice ?? b.pricePerNight ?? 0));
        break;
      case 'Price: High to Low':
        sorted.sort((a, b) => (b.displayPrice ?? b.pricePerNight ?? 0)
            .compareTo(a.displayPrice ?? a.pricePerNight ?? 0));
        break;
      case 'Highest Rated':
        sorted.sort((a, b) {
          if (a.isGuestFavorite == b.isGuestFavorite) return 0;
          return (a.isGuestFavorite ?? false) ? -1 : 1;
        });
        break;
      case 'Newest':
        sorted.sort((a, b) => (b.createdAt ?? DateTime(2000))
            .compareTo(a.createdAt ?? DateTime(2000)));
        break;
      case 'Recommended':
      default:
        break;
    }
    return sorted;
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
                _selectedCategory == 'All'
                    ? 'All Listings'
                    : _selectedCategory == 'Best Offers'
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
                          color: AppColors.primaryBurgundy,
                          strokeWidth: 2.5,
                        ),
                      ),
                    );
                  }
                  if (state is SearchError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: AppColors.greyText),
                        ),
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
                              Icon(
                                Icons.home_outlined,
                                size: 40,
                                color: AppColors.greyText.withOpacity(0.4),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No listings found',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  color: AppColors.greyText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    final sortedListings = _getSortedListings(state.listings);
                    final displayedListings = sortedListings.take(5).toList();

                    return Column(
                      children: [
                        ListingsSortHeader(
                          totalListings: displayedListings.length,
                          selectedSort: _selectedSort,
                          sortOptions: _sortOptions,
                          onSortChanged: (val) {
                            if (val != null) setState(() => _selectedSort = val);
                          },
                        ),
                        ...displayedListings.map(
                          (listing) => PropertyListingCard(
                            listing: listing,
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.details,
                              arguments: listing,
                            ),
                          ),
                        ),
                      ],
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
