import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PropertyLocationRow extends StatelessWidget {
  final String? city;
  final String? country;

  const PropertyLocationRow({super.key, this.city, this.country});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.location_on_outlined, size: 16.r, color: Colors.grey),
        SizedBox(width: 4.w),
        Text(
          '${city ?? ""}, ${country ?? ""}',
          style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
        ),
      ],
    );
  }
}
