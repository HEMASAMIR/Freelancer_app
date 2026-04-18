import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/features/favourite/logic/cubit/fav_cubit.dart';
import 'package:freelancer/features/favourite/data/models/wishlist_model.dart';
import 'package:freelancer/features/search/presentation/view/search_details.dart';
import 'package:freelancer/features/search/presentation/widget/property_listing_card.dart';

class WishlistDetailsScreen extends StatefulWidget {
  final WishlistModel wishlist;
  const WishlistDetailsScreen({super.key, required this.wishlist});

  @override
  State<WishlistDetailsScreen> createState() => _WishlistDetailsScreenState();
}

class _WishlistDetailsScreenState extends State<WishlistDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FavCubit>().loadWishlistItems(widget.wishlist.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.wishlist.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: BlocBuilder<FavCubit, FavState>(
        builder: (context, state) {
          if (state is FavLoaded) {
            final items = state.wishlistContent[widget.wishlist.id] ?? [];
            
            if (items.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
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
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back_ios, size: 12.sp, color: Colors.black),
                      SizedBox(width: 4.w),
                      Text(
                        "Back to wishlists",
                        style: TextStyle(
                          fontSize: 14.sp, 
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  widget.wishlist.name,
                  style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                SizedBox(height: 4.h),
                Text(
                  "0 listings saved",
                  style: TextStyle(fontSize: 15.sp, color: Colors.grey.shade600),
                ),
                SizedBox(height: 32.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 64.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "This wishlist is empty",
                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 12.h),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          "Discover places to stay",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF710E1F),
                            decoration: TextDecoration.underline,
                            decorationColor: const Color(0xFF710E1F),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Footer
        Padding(
          padding: EdgeInsets.only(bottom: 24.h, top: 12.h),
          child: Column(
            children: [
              Text(
                '© 2026 QuickIn, Inc. · Terms · Sitemap · Privacy',
                style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade500),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.public, size: 14.sp, color: Colors.grey.shade600),
                  SizedBox(width: 4.w),
                  Text(
                    'English (US)  EGP',
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
