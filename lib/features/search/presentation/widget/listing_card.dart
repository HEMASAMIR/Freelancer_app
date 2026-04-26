import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/features/search/data/search_model/listing_model.dart'; // تأكد من المسار الصح للموديل اللي بعته

class ListingCard extends StatelessWidget {
  final ListingModel listing;
  const ListingCard({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (_) => DetailsScreen(listingId: listing.id),
        //   ),
        // );
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── صورة العقار (عرض أول صورة من الـ List) ──────────────────
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: (listing.images != null && listing.images!.isNotEmpty)
                    ? Image.network(
                        listing.images!.first.url ??
                            '', // تأكد أن ListingImage فيها url
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),

            // ── بيانات العقار ────────────────────────────────────────
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // العنوان
                  Text(
                    listing.title ?? 'No Title',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),

                  // الموقع (City, Country)
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 13.r,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          '${listing.city ?? ''}${listing.city != null ? ', ' : ''}${listing.country ?? ''}'
                                  .isEmpty
                              ? 'Location not specified'
                              : '${listing.city ?? ''}, ${listing.country ?? ''}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  // السعر وتفاصيل الغرف
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // السعر
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  '${listing.pricePerNight?.round() ?? 0} ${listing.currency ?? 'EGP'}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: ' / night',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // عدد الغرف (اختياري لو حابب تظهره)
                      if (listing.bedrooms != null)
                        Text(
                          '${listing.bedrooms} bd',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[700],
                          ),
                        ),
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

  Widget _placeholder() => Container(
    color: Colors.grey[100],
    child: const Center(child: Icon(Icons.image_outlined, color: Colors.grey)),
  );
}
