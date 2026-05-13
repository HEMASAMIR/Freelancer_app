import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/shared_helper/app_color.dart';
import 'package:freelancer/core/utils/widgets/elegant_toast.dart';

class ListingsSortHeader extends StatelessWidget {
  final int totalListings;
  final String selectedSort;
  final ValueChanged<String?> onSortChanged;
  final List<String> sortOptions;

  const ListingsSortHeader({
    super.key,
    required this.totalListings,
    required this.selectedSort,
    required this.onSortChanged,
    required this.sortOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The count
          Text(
            'Showing $totalListings of $totalListings listings',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 12.h),
          // The animated sort button (Full width for elegance)
          PopupMenuButton<String>(
            onSelected: (newValue) {
              if (newValue != selectedSort) {
                onSortChanged(newValue);
                ElegantToast.show(context, 'Listings sorted by $newValue');
              }
            },
            offset: const Offset(0, 64), // Increased offset to add space below the button
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            color: Colors.white,
            elevation: 8,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.sort_rounded, size: 18.sp, color: AppColors.primaryRed),
                      SizedBox(width: 8.w),
                      Text(
                        'Sort by: $selectedSort',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.keyboard_arrow_down_rounded, size: 20.sp, color: Colors.grey[500]),
                ],
              ),
            ),
            itemBuilder: (context) => sortOptions.map((opt) {
              final isSelected = opt == selectedSort;
              return PopupMenuItem<String>(
                value: opt,
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: isSelected ? AppColors.primaryRed : Colors.grey[400],
                      size: 20.sp,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      opt,
                      style: TextStyle(
                        color: isSelected ? AppColors.primaryRed : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }
}
