import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LocationTagItem extends StatefulWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const LocationTagItem({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<LocationTagItem> createState() => _LocationTagItemState();
}

class _LocationTagItemState extends State<LocationTagItem> {
  @override
  Widget build(BuildContext context) {
    const Color primaryRed = Color(0xFF8B1A1A); // لون اللوجو بتاعك

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: widget.isSelected ? primaryRed : Colors.white,
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(
            color: widget.isSelected
                ? Colors.transparent
                : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.isSelected
                  ? primaryRed.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: widget.isSelected ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          widget.title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: widget.isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
