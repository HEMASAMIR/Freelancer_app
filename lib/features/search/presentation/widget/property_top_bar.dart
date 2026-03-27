import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PropertyTopBar extends StatelessWidget {
  final bool isFavourite;
  final VoidCallback onBack;
  final VoidCallback onFavToggle;
  final VoidCallback onShare;

  const PropertyTopBar({
    super.key,
    required this.isFavourite,
    required this.onBack,
    required this.onFavToggle,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _CircleIconBtn(icon: Icons.arrow_back, onTap: onBack),
            Row(
              children: [
                _CircleIconBtn(
                  icon: isFavourite ? Icons.favorite : Icons.favorite_border,
                  iconColor: isFavourite ? Colors.red : Colors.black,
                  onTap: onFavToggle,
                ),
                SizedBox(width: 10.w),
                _CircleIconBtn(icon: Icons.share_outlined, onTap: onShare),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  const _CircleIconBtn({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 20.r,
        child: IconButton(
          onPressed: onTap,
          icon: Icon(icon, color: iconColor ?? Colors.black, size: 20.r),
        ),
      ),
    );
  }
}
