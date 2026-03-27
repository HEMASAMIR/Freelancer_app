import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/features/search/presentation/widget/host_section.dart';
import 'package:freelancer/features/search/presentation/widget/property_map_section.dart';
import 'package:freelancer/features/search/presentation/widget/stat_item.dart';

Widget _buildBody(dynamic l) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Property Type Tag
        if (l.propertyType?.name != null) _buildTypeTag(l.propertyType!.name!),

        SizedBox(height: 12.h),
        Text(
          l.title ?? 'Property Details',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),

        SizedBox(height: 10.h),
        _buildLocationRow(l.city, l.country),

        SizedBox(height: 25.h),
        const Divider(),
        SizedBox(height: 25.h),

        // Statistics Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StatItem(
              icon: Icons.group_outlined,
              label: 'Guests',
              value: '${l.maxGuests ?? 0}',
            ),
            StatItem(
              icon: Icons.bed_outlined,
              label: 'Bedrooms',
              value: '${l.bedrooms ?? 0}',
            ),
            StatItem(
              icon: Icons.hotel_outlined,
              label: 'Beds',
              value: '${l.beds ?? 0}',
            ),
            StatItem(
              icon: Icons.bathtub_outlined,
              label: 'Baths',
              value: '${l.bathrooms ?? 0}',
            ),
          ],
        ),

        SizedBox(height: 25.h),
        const Divider(),

        // Host Section
        if (l.host != null) ...[
          SizedBox(height: 25.h),
          HostSection(
            fullName: l.host!.fullName ?? "Owner",
            selfieUrl: l.host!.selfieUrl,
            joinedDate: "2023",
          ),
          SizedBox(height: 25.h),
          const Divider(),
        ],

        // Description Section
        if (l.description != null) ...[
          SizedBox(height: 25.h),
          Text(
            'About this place',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10.h),
          Text(
            l.description!,
            style: TextStyle(
              color: Colors.black87,
              height: 1.5,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 25.h),
          const Divider(),
        ],

        // Map Section
        SizedBox(height: 25.h),
        const PropertyMapSection(lat: 31.2357, lng: 30.0444),
        SizedBox(height: 30.h),
      ],
    ),
  );
}

// Helper Widgets داخل الملف لتقليل الزحمة
Widget _buildTypeTag(String name) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
    decoration: BoxDecoration(
      color: const Color(0xFFFDECEC),
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: Text(
      name.toUpperCase(),
      style: TextStyle(
        fontSize: 10.sp,
        color: const Color(0xFFBD1E59),
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

Widget _buildLocationRow(String? city, String? country) {
  return Row(
    children: [
      Icon(Icons.location_on_outlined, size: 16.r, color: Colors.grey),
      SizedBox(width: 4.w),
      Text(
        '$city, $country',
        style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
      ),
    ],
  );
}
