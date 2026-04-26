import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PropertyMapSection extends StatelessWidget {
  final double lat;
  final double lng;

  const PropertyMapSection({super.key, required this.lat, required this.lng});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Where you’ll be',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 15.h),
        Container(
          height: 200.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(15.r),
            image: const DecorationImage(
              image: CachedNetworkImageProvider(
                'https://static-maps.yandex.ru/1.x/?lang=en_US&ll=31.2357,30.0444&z=12&l=map&size=450,450',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}
