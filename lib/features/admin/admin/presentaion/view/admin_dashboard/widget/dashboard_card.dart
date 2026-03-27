import 'package:flutter/material.dart';
import 'package:freelancer/core/shared_helper/app_color.dart';


class AdminStatCard extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;
  final VoidCallback onTap;

  const AdminStatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<AdminStatCard> createState() => _AdminStatCardState();
}

class _AdminStatCardState extends State<AdminStatCard> {
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
          color: _pressed ? AppColors.bg : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.dividerGrey, width: 1),
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
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.sub,
                  ),
                ),
                Icon(widget.icon, size: 18, color: widget.iconColor),
              ],
            ),
            const SizedBox(height: 12),

            // ── Value (رقم كبير) ──────────────────────────────────────────
            Text(
              widget.value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),

            // ── Subtitle ──────────────────────────────────────────────────
            Text(
              widget.subtitle,
              style: const TextStyle(
                fontSize: 12,
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
