import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TopSelectionCards extends StatelessWidget {
  final String activeSection;
  final String? selectedDestination;
  final String dateRange;
  final int guestCount;
  final ValueChanged<String> onSectionTap;

  const TopSelectionCards({
    super.key,
    required this.activeSection,
    required this.selectedDestination,
    required this.dateRange,
    required this.guestCount,
    required this.onSectionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          _Tile(
            title: "Where",
            sub: selectedDestination ?? "Search destinations",
            id: 'where',
            activeSection: activeSection,
            onTap: onSectionTap,
          ),
          _Divider(),
          _Tile(
            title: "When",
            sub: dateRange,
            id: 'when',
            activeSection: activeSection,
            onTap: onSectionTap,
          ),
          _Divider(),
          _Tile(
            title: "Who",
            sub: "$guestCount guest${guestCount > 1 ? 's' : ''}",
            id: 'who',
            activeSection: activeSection,
            onTap: onSectionTap,
          ),
          _Divider(),
          _Tile(
            title: "Filters",
            sub: "Price & amenities",
            id: 'filters',
            activeSection: activeSection,
            onTap: onSectionTap,
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final String title;
  final String sub;
  final String id;
  final String activeSection;
  final ValueChanged<String> onTap;

  const _Tile({
    required this.title,
    required this.sub,
    required this.id,
    required this.activeSection,
    required this.onTap,
  });

  static const _placeholders = [
    "Search destinations",
    "Any dates",
    "Add date",
    "Price & amenities",
  ];

  @override
  Widget build(BuildContext context) {
    final isActive = activeSection == id;
    return GestureDetector(
      onTap: () => onTap(id),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFF1F1F1) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  sub,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: _placeholders.contains(sub)
                        ? Colors.grey
                        : Colors.black,
                  ),
                ),
              ],
            ),
            Icon(
              isActive ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 18.r,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: Colors.grey[200],
      indent: 20,
      endIndent: 20,
    );
  }
}
