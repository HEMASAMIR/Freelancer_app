import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:freelancer/features/search/data/search_model/listing_model.dart';
import 'package:latlong2/latlong.dart';
import 'package:freelancer/core/app_router/routes.dart';
import 'package:freelancer/core/di/service_locator.dart';
import 'package:freelancer/core/utils/widgets/custom_app_bar.dart';
import 'package:freelancer/core/utils/widgets/custom_empty_widget.dart';
import 'package:freelancer/core/utils/widgets/custom_error_widget.dart';
import 'package:freelancer/core/utils/widgets/search_loading_shimmer.dart';
import 'package:freelancer/features/favourite/logic/cubit/fav_cubit.dart';
import 'package:freelancer/core/utils/widgets/listings_sort_header.dart';
import 'package:freelancer/features/home/presentation/widget/custom_footer.dart';
import 'package:freelancer/features/search/logic/search_cubit/cubit/search_cubit.dart';
import 'package:freelancer/features/search/logic/search_cubit/cubit/search_state.dart';
import 'package:freelancer/features/search/data/search_model/search_params_model.dart';
import 'package:freelancer/features/search/presentation/widget/property_listing_card.dart';
import 'package:freelancer/features/home/presentation/widget/best_offers_banner.dart';
import 'package:freelancer/features/home/presentation/widget/custom_drawer.dart';
import 'package:freelancer/core/shared_helper/app_color.dart';

class SearchResultScreen extends StatefulWidget {
  final SearchParamsModel params;
  const SearchResultScreen({super.key, required this.params});

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  late FavCubit _favCubit;
  late SearchCubit _searchCubit;
  bool _showMap = false;

  String _selectedSort = 'Recommended';
  final List<String> _sortOptions = [
    'Recommended',
    'Price: Low to High',
    'Price: High to Low',
    'Highest Rated',
    'Newest',
  ];

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
        // Default sort from server
        break;
    }
    return sorted;
  }

  @override
  void initState() {
    super.initState();
    _favCubit = sl<FavCubit>();
    _searchCubit = sl<SearchCubit>();
    _searchCubit.getListings(params: widget.params);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _favCubit),
        BlocProvider.value(value: _searchCubit),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: const SideDrawer(),
        appBar: const CustomAppBar(),
        body: BlocBuilder<SearchCubit, SearchState>(
          builder: (context, state) {
            if (state is SearchLoading) {
              return const SearchLoadingShimmer();
            }

            if (state is SearchError) {
              return CustomErrorWidget(
                message: state.message,
                onRetry: () => _searchCubit.getListings(params: widget.params),
              );
            }

            if (state is SearchSuccess) {
              if (state.listings.isEmpty) {
                return const Center(
                  child: CustomEmptyWidget(
                    message: "No properties found",
                  ),
                );
              }

              return Stack(
                children: [
                  if (_showMap)
                    _buildMapView(state.listings)
                  else
                    CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
                            child: const BestOffersBanner(),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: ListingsSortHeader(
                            totalListings: state.listings.length,
                            selectedSort: _selectedSort,
                            sortOptions: _sortOptions,
                            onSortChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedSort = newValue;
                                });
                              }
                            },
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate((context, index) {
                              final sortedListings = _getSortedListings(state.listings);
                              return PropertyListingCard(
                                listing: sortedListings[index],
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.details,
                                    arguments: sortedListings[index],
                                  );
                                },
                              );
                            }, childCount: state.listings.length),
                          ),
                        ),
                        const SliverToBoxAdapter(child: CustomFooter()),
                        SliverToBoxAdapter(child: SizedBox(height: 80.h)), // Space for FAB
                      ],
                    ),

                  // Floating Map/List Toggle Button
                  Positioned(
                    bottom: 20.h,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _showMap = !_showMap;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF222222), // Dark Airbnb style color
                            borderRadius: BorderRadius.circular(30.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _showMap ? 'List' : 'Map',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.sp,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Icon(
                                _showMap ? Icons.format_list_bulleted : Icons.map_outlined,
                                color: Colors.white,
                                size: 18.r,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildMapView(List listings) {
    // Determine bounds or center based on listings
    double centerLat = 30.0444;
    double centerLng = 31.2357;
    
    final validListings = listings.where((l) => l.lat != null && l.lng != null).toList();
    if (validListings.isNotEmpty) {
      centerLat = validListings.first.lat!;
      centerLng = validListings.first.lng!;
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(centerLat, centerLng),
        initialZoom: 10.0,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.freelancer.app',
        ),
        MarkerLayer(
          markers: validListings.map((listing) {
            final priceStr = listing.displayPrice != null 
                ? '${listing.currency} ${listing.displayPrice!.toInt()}' 
                : '${listing.currency} ${listing.pricePerNight?.toInt() ?? 0}';
                
            return Marker(
              point: LatLng(listing.lat!, listing.lng!),
              width: 100.w,
              height: 40.h,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.details,
                    arguments: listing,
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    priceStr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
