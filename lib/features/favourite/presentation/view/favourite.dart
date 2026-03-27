import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/features/favourite/logic/cubit/fav_cubit.dart';
import 'package:freelancer/features/search/presentation/view/search_details.dart';
import 'package:freelancer/features/search/presentation/widget/property_listing_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    // بنحدث البيانات أول ما نفتح الصفحة عشان لو فيه حاجة اتشالت أو انضافت
    context.read<FavCubit>().loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Wishlists",
          style: TextStyle(
            color: Colors.black,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: BlocBuilder<FavCubit, FavState>(
        builder: (context, state) {
          if (state is FavLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF710E1F)),
            );
          }

          if (state is FavLoaded) {
            if (state.favorites.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              itemCount: state.favorites.length,
              itemBuilder: (context, index) {
                // بنفترض إن الموديل بتاعك اسمه ListingModel
                final item = state.favorites[index];

                return PropertyListingCard(
                  listing: item,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchDetails(listing: item),
                      ),
                    );
                  },
                );
              },
            );
          }

          if (state is FavError) {
            return Center(child: Text(state.message));
          }

          return _buildEmptyState();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80.r, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            "No favorites yet",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              "Tap the heart icon on any property to save it here for later.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}
