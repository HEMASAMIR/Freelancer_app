import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/features/favourite/logic/cubit/fav_cubit.dart';
import 'package:freelancer/features/favourite/data/models/wishlist_model.dart';
import 'package:freelancer/features/favourite/presentation/view/wishlist_details_screen.dart';
import 'package:freelancer/features/search/presentation/view/search_details.dart';
import 'package:freelancer/features/search/presentation/widget/property_listing_card.dart';
import 'package:freelancer/features/home/presentation/widget/custom_drawer.dart';

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
      drawer: const SideDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
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
            if (state.wishlists.isEmpty) {
              return _buildEmptyState();
            }

            return GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15.w,
                mainAxisSpacing: 15.h,
                childAspectRatio: 0.9,
              ),
              itemCount: state.wishlists.length,
              itemBuilder: (context, index) {
                return _buildWishlistCard(state.wishlists[index]);
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

  Widget _buildWishlistCard(WishlistModel wishlist) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider.value(
              value: context.read<FavCubit>(),
              child: WishlistDetailsScreen(wishlist: wishlist),
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Center(
                child: Icon(Icons.favorite, color: Color(0xFF710E1F), size: 40),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            wishlist.name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            "Saved items", // يمكن جلب عدد العناصر هنا لاحقاً
            style: TextStyle(color: Colors.grey, fontSize: 12.sp),
          ),
        ],
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
            "No wishlists yet",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              "Create a wishlist to save your favorite listings.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}
