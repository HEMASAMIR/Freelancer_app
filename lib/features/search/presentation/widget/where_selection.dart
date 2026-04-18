import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WhereSection extends StatelessWidget {
  final String? selectedDestination;
  final ValueChanged<String> onSelect;
  final VoidCallback onClear;

  const WhereSection({
    super.key,
    required this.selectedDestination,
    required this.onSelect,
    required this.onClear,
  });

  static const List<Map<String, dynamic>> destinations = [
    {'name': 'Best Offers', 'icon': Icons.beach_access},
    {'name': 'Main Office', 'icon': Icons.location_city},
    {'name': 'Marakia', 'icon': Icons.place},
    {'name': 'Cairo', 'icon': Icons.place},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('where'),
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search box
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(Icons.search, size: 18.r, color: Colors.grey),
                SizedBox(width: 8.w),
                Text(
                  selectedDestination ?? "Search destinations",
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: selectedDestination != null
                        ? Colors.black
                        : Colors.grey,
                  ),
                ),
                const Spacer(),
                if (selectedDestination != null)
                  GestureDetector(
                    onTap: onClear,
                    child: Icon(Icons.close, size: 16.r, color: Colors.grey),
                  ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          Text(
            "POPULAR DESTINATIONS",
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w800,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),

          SizedBox(height: 12.h),

          ...destinations.map((dest) {
            final isSelected = selectedDestination == dest['name'];
            return GestureDetector(
              onTap: () => onSelect(dest['name'] as String),
              child: Container(
                margin: EdgeInsets.only(bottom: 4.h),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFF1F1F1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        dest['icon'] as IconData,
                        size: 16.r,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      dest['name'] as String,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        size: 16.r,
                        color: const Color(0xFF8B1A1A),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
