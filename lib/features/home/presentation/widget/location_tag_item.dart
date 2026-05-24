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
    const Color primaryRed = Color(0xFF5B0F16); // لون اللوجو المعتمد في التطبيق

    IconData? getIcon(String title) {
      switch (title) {
        case 'All':
          return Icons.explore_outlined;
        case 'Best Offers':
          return Icons.local_offer_outlined;
        case 'El Gouna':
          return Icons.pool_outlined;
        case 'Marakia':
          return Icons.beach_access_outlined;
        case 'Cairo':
          return Icons.location_city_outlined;
        default:
          return Icons.location_on_outlined;
      }
    }

    final icon = getIcon(widget.title);

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
                  ? primaryRed.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: widget.isSelected ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16.r,
                color: widget.isSelected ? Colors.white : Colors.black54,
              ),
              SizedBox(width: 8.w),
            ],
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: widget.isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
