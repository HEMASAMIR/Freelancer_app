import 'package:flutter/material.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DashboardCard extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;
  final VoidCallback onTap;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: double.infinity,
        decoration: BoxDecoration(
          color: _pressed ? AppColors.backgroundCream : AppColors.cardWhite,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
          boxShadow: _pressed
              ? []
              : [
                  BoxShadow(
                    color: AppColors.ink.withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Row: title يسار + icon يمين ───────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink.withOpacity(0.7),
                  ),
                ),
                Icon(widget.icon, size: 18, color: widget.iconColor),
              ],
            ),
            const SizedBox(height: 12),

            // ── Value (رقم كبير) ──────────────────────────────────────────
            Text(
              widget.value,
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBurgundy,
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 6),

            // ── Subtitle ──────────────────────────────────────────────────
            Text(
              widget.subtitle,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.sub,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
