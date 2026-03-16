import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WhoSection extends StatelessWidget {
  final int guestCount;
  final ValueChanged<int> onChanged;

  const WhoSection({
    super.key,
    required this.guestCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('who'),
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: [
          _GuestRow(
            title: "Adults",
            sub: "Ages 13 or above",
            count: guestCount,
            onDecrease: guestCount > 1 ? () => onChanged(guestCount - 1) : null,
            onIncrease: () => onChanged(guestCount + 1),
          ),
        ],
      ),
    );
  }
}

class _GuestRow extends StatelessWidget {
  final String title;
  final String sub;
  final int count;
  final VoidCallback? onDecrease;
  final VoidCallback onIncrease;

  const _GuestRow({
    required this.title,
    required this.sub,
    required this.count,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
            ),
            Text(
              sub,
              style: TextStyle(fontSize: 11.sp, color: Colors.grey),
            ),
          ],
        ),
        Row(
          children: [
            _CircleBtn(icon: Icons.remove, onTap: onDecrease),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: Text(
                "$count",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
              ),
            ),
            _CircleBtn(icon: Icons.add, onTap: onIncrease),
          ],
        ),
      ],
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: onTap == null ? Colors.grey.shade200 : Colors.grey.shade400,
          ),
        ),
        child: Icon(
          icon,
          size: 16.r,
          color: onTap == null ? Colors.grey.shade300 : Colors.grey,
        ),
      ),
    );
  }
}
