import 'package:flutter/material.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/features/favourite/logic/cubit/fav_cubit.dart';
import 'package:freelancer/features/favourite/presentation/widget/wishlist_bottom_sheet.dart';
import 'package:freelancer/features/search/data/search_model/listing_model.dart';

class PropertyListingCard extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onTap;

  const PropertyListingCard({
    super.key,
    required this.listing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<ListingImage>? images = listing.images;
    final bool hasImages = images != null && images.isNotEmpty;

    // سحب أول رابط صورة بشكل آمن
    final String imageUrl = hasImages
        ? (images.first.url ?? 'https://via.placeholder.com/400x300')
        : 'https://via.placeholder.com/400x300';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ تم حذف البانر من هنا عشان ما يتكررش في كل عنصر

            // --- 1. قسم الصورة ---
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24.r),
                  child: Image.network(
                    imageUrl,
                    height: 280.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 280.h,
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
                // زرار المفضلة
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: BlocBuilder<FavCubit, FavState>(
                    builder: (context, state) {
                      final isFav = context.read<FavCubit>().isFavorite(
                        listing.id.toString(),
                      );

                      return Container(
                        decoration: const BoxDecoration(
                          color: Colors.black26,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                                  return ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  );
                                },
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              key: ValueKey<bool>(isFav),
                              color: isFav ? Colors.redAccent : Colors.white,
                              size: 24.r,
                            ),
                          ),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (_) => BlocProvider.value(
                                value: context.read<FavCubit>(),
                                child: WishlistBottomSheet(listing: listing),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                // الـ Badge بتاع Guest Favorite
                if (listing.isGuestFavorite == true)
                  Positioned(
                    top: 12.h,
                    left: 12.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        "Guest favorite",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12.h),

            // --- 2. العنوان والتقييم ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    listing.title ?? "Cozy Stay",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBurgundy,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.star, size: 14.r, color: Colors.black),
                    SizedBox(width: 4.w),
                    Text("4.85", style: TextStyle(fontSize: 14.sp)),
                  ],
                ),
              ],
            ),

            // --- 3. الموقع ---
            Text(
              "${listing.city ?? 'Cairo'}, ${listing.country ?? 'Egypt'}",
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),

            // --- 4. التفاصيل ---
            SizedBox(height: 4.h),
            Text(
              "${listing.maxGuests ?? 0} guests · ${listing.bedrooms ?? 0} bedroom · ${listing.bathrooms ?? 0} bath",
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
            ),

            // --- 5. السعر ---
            SizedBox(height: 8.h),
            RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.black, fontSize: 15.sp),
                children: [
                  TextSpan(
                    text:
                        "${listing.currency ?? 'EGP'} ${listing.pricePerNight?.round() ?? 0} ",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: "night"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
