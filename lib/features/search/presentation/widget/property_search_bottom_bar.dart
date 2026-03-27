import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PropertySearchBottomBar extends StatelessWidget {
  final VoidCallback onClearAll;
  final VoidCallback onSearch;

  const PropertySearchBottomBar({
    super.key,
    required this.onClearAll,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          // زر مسح الكل
          TextButton(
            onPressed: onClearAll,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size(50.w, 30.h),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              "Clear all",
              style: TextStyle(
                color: Colors.black,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const Spacer(),
          // زر البحث الأساسي
          ElevatedButton.icon(
            onPressed: onSearch,
            icon: Icon(Icons.search, color: Colors.white, size: 18.r),
            label: Text(
              "Search",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE31C5F), // لون البراند
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
