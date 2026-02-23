import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PropertyCard extends StatelessWidget {
  final String title;
  final String location;
  final String price;
  final String imageUrl;
  final double rating;
  final int guests;
  final int bedrooms;
  final int baths;

  const PropertyCard({
    super.key,
    required this.title,
    required this.location,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.guests,
    required this.bedrooms,
    required this.baths,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 28.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF4EFE8),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12.r,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 الصورة
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
            child: Stack(
              children: [
                Image.network(
                  imageUrl,
                  height: 260.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),

                /// ❤️ زرار الفيفوريت
                Positioned(
                  top: 14.h,
                  right: 14.w,
                  child: Container(
                    height: 36.h,
                    width: 36.w,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite_border,
                      size: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// 🔹 المحتوى
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// العنوان + التقييم
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF222222),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16.r, color: Colors.redAccent),
                        SizedBox(width: 4.w),
                        Text(
                          rating.toString(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 6.h),

                /// الموقع
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16.r,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      location,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10.h),

                /// التفاصيل
                Row(
                  children: [
                    _info(Icons.group_outlined, "$guests guests"),
                    SizedBox(width: 14.w),
                    _info(Icons.bed_outlined, "$bedrooms bedrooms"),
                    SizedBox(width: 14.w),
                    _info(Icons.bathtub_outlined, "$baths baths"),
                  ],
                ),
              ],
            ),
          ),

          /// 🔹 السعر تحت
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(22.r),
              ),
            ),
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 16.sp,
                  color: const Color(0xFF222222),
                ),
                children: [
                  TextSpan(
                    text: "\$$price ",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: "night"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _info(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 17.r, color: Colors.grey[700]),
        SizedBox(width: 4.w),
        Text(
          text,
          style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
        ),
      ],
    );
  }
}
