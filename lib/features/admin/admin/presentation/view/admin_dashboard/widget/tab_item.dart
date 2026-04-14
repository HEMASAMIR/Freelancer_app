import 'package:flutter/material.dart';
import 'package:freelancer/core/constant/constant.dart';

class TabItem extends StatelessWidget {
  final String title;
  final bool isActive;
  final IconData? icon;

  const TabItem({
    super.key,
    required this.title,
    required this.isActive,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? AppColors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? AppColors.dividerGrey : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: isActive ? AppColors.ink : AppColors.sub,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? AppColors.ink : AppColors.sub,
            ),
          ),
        ],
      ),
    );
  }
}
