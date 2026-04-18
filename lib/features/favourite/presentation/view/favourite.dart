import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/features/favourite/logic/cubit/fav_cubit.dart';
import 'package:freelancer/features/favourite/data/models/wishlist_model.dart';
import 'package:freelancer/features/favourite/presentation/view/wishlist_details_screen.dart';
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Wishlists",
              style: TextStyle(
                color: Colors.black,
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            BlocBuilder<FavCubit, FavState>(
              builder: (context, state) {
                if (state is FavLoaded) {
                  final count = state.wishlists.length;
                  return Text(
                    "$count list${count == 1 ? '' : 's'} available",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 100.h,
        leadingWidth: 56.w,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
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
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20.w,
                mainAxisSpacing: 24.h,
                childAspectRatio: 0.85,
              ),
              itemCount: state.wishlists.length,
              itemBuilder: (context, index) {
                return _buildWishlistCard(state.wishlists[index], state);
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

  Widget _buildWishlistCard(WishlistModel wishlist, FavState state) {
    int itemCount = 0;
    if (state is FavLoaded) {
      itemCount = state.wishlistContent[wishlist.id]?.length ?? 0;
    }

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
                color: const Color(0xFFF3EFE9), // Beige/Light grey match
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.favorite_rounded, 
                  color: Colors.white, 
                  size: 48.sp,
                  shadows: [
                    Shadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            wishlist.name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: Colors.black87),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          Text(
            "$itemCount saved listing${itemCount == 1 ? '' : 's'}", 
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13.sp),
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
