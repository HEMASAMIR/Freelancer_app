import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/app_router/routes.dart';
import 'package:freelancer/core/di/service_locator.dart';
import 'package:freelancer/core/utils/widgets/custom_app_bar.dart';
import 'package:freelancer/core/utils/widgets/custom_empty_widget.dart';
import 'package:freelancer/core/utils/widgets/custom_error_widget.dart';
import 'package:freelancer/core/utils/widgets/search_loading_shimmer.dart';
import 'package:freelancer/features/favourite/logic/cubit/fav_cubit.dart';
import 'package:freelancer/features/home/presentation/widget/custom_footer.dart';
import 'package:freelancer/features/search/logic/search_cubit/cubit/search_cubit.dart';
import 'package:freelancer/features/search/logic/search_cubit/cubit/search_state.dart';
import 'package:freelancer/features/search/data/search_model/search_params_model.dart';
import 'package:freelancer/features/search/presentation/widget/property_listing_card.dart';
// استدعاء البانر بتاعك
import 'package:freelancer/features/home/presentation/widget/best_offers_banner.dart';
import 'package:freelancer/features/home/presentation/widget/custom_drawer.dart';

class SearchResultScreen extends StatefulWidget {
  final SearchParamsModel params;
  const SearchResultScreen({super.key, required this.params});

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  late FavCubit _favCubit;
  late SearchCubit _searchCubit;

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

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // --- 1. البانر فوق خالص لوحده ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
                    child: const BestOffersBanner(),
                  ),
                ),

                // --- 2. نتائج البحث ---
                if (state is SearchSuccess) ...[
                  if (state.listings.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CustomEmptyWidget(
                          message: "No properties found",
                        ),
                      ),
                    )
                  else ...[
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return PropertyListingCard(
                            listing: state.listings[index],
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.details,
                                arguments: state.listings[index],
                              );
                            },
                          );
                        }, childCount: state.listings.length),
                      ),
                    ),
                    const SliverToBoxAdapter(child: CustomFooter()),
                    SliverToBoxAdapter(child: SizedBox(height: 30.h)),
                  ],
                ] else if (state is SearchError) ...[
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: CustomErrorWidget(
                      message: state.message,
                      onRetry: () =>
                          _searchCubit.getListings(params: widget.params),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
