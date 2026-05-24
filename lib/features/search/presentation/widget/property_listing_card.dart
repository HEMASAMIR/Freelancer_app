import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/core/widgets/login_required_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/features/favourite/logic/cubit/fav_cubit.dart';
import 'package:freelancer/features/favourite/presentation/widget/wishlist_bottom_sheet.dart';
import 'package:freelancer/features/search/data/search_model/listing_model.dart';
import 'package:freelancer/features/auth/logic/cubit/auth_cubit.dart';
import 'package:freelancer/features/auth/logic/cubit/auth_state.dart';
import 'package:shimmer/shimmer.dart';

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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ تم حذف البانر من هنا عشان ما يتكررش في كل عنصر

            // --- 1. قسم الصورة ---
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                  child: Image.network(
                    imageUrl,
                    height: 280.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: 280.h,
                          width: double.infinity,
                          color: Colors.white,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 280.h,
                      width: double.infinity,
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
                            final AuthCubitState = context.read<AuthCubit>().state;
                            final isLoggedIn = AuthCubitState is AuthSuccess || AuthCubitState is AuthAdminSuccess;
                            if (!isLoggedIn) {
                              showLoginRequiredSheet(context);
                              return;
                            }
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
                // الـ Badge بتاع Best Offer أو Guest Favorite
                if (listing.isBestOffer == true || listing.isGuestFavorite == true)
                  Positioned(
                    top: 12.h,
                    left: 12.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: listing.isBestOffer == true
                            ? const Color(0xFF1A7A3C)  // أخضر للـ Best Offer
                            : Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (listing.isBestOffer == true)
                            Padding(
                              padding: EdgeInsets.only(right: 4.w),
                              child: Icon(Icons.local_offer_rounded, size: 12.r, color: Colors.white),
                            ),
                          Text(
                            listing.isBestOffer == true ? "Best Offer" : "Guest favorite",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: listing.isBestOffer == true ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            // --- النصوص والتفاصيل ---
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(Icons.map_outlined, size: 14.r, color: Colors.grey[500]),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          listing.displayLocation ?? '',
                          style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // --- 4. التفاصيل ---
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(Icons.group_outlined, size: 14.r, color: Colors.grey[500]),
                      SizedBox(width: 4.w),
                      Text(
                        "${listing.maxGuests ?? 0} guests",
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                      ),
                      Text("  ·  ", style: TextStyle(color: Colors.grey[300])),
                      Icon(Icons.bed_outlined, size: 14.r, color: Colors.grey[500]),
                      SizedBox(width: 4.w),
                      Text(
                        "${listing.beds ?? listing.bedrooms ?? 0} beds",
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                      ),
                      Text("  ·  ", style: TextStyle(color: Colors.grey[300])),
                      Icon(Icons.bathtub_outlined, size: 14.r, color: Colors.grey[500]),
                      SizedBox(width: 4.w),
                      Text(
                        "${listing.bathrooms ?? 0} bath",
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                      ),
                    ],
                  ),

                  // --- 5. السعر ---
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      // السعر الأصلي المشطوب لو في displayPrice
                      if (listing.displayPrice != null && listing.displayPrice! > (listing.pricePerNight ?? 0)) ...[
                        Text(
                          "${listing.currency ?? 'EGP'} ${listing.displayPrice!.round()}",
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          "${listing.currency ?? 'EGP'} ${listing.pricePerNight?.round() ?? 0} ",
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A7A3C), // أخضر
                          ),
                        ),
                      ] else
                        Text(
                          "${listing.currency ?? 'EGP'} ${listing.pricePerNight?.round() ?? 0} ",
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      Text("night", style: TextStyle(fontSize: 14.sp, color: Colors.black87)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
