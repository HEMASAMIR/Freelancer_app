import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/features/admin/admin/widget/me_badge.dart';
import 'package:freelancer/features/admin/admin/widget/role_avatar.dart';

class StaffRow extends StatelessWidget {
  final String name, email, role;
  final bool isMe;
  final Color greyColor;
  final int index;

  const StaffRow({
    required this.name,
    required this.email,
    required this.role,
    this.isMe = false,
    required this.greyColor,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 10 * (1 - value)),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                child: Row(
                  children: [
                    // ── عمود الاسم ──
                    Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RoleAvatar(role: role),
                          SizedBox(width: 8.w),
                          // ✅ Flexible يمنع الـ overflow
                          Flexible(
                            child: Text(
                              name,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          // ✅ MeBadge بره الـ Flexible عشان ميتقطعش
                          if (isMe) ...[SizedBox(width: 4.w), MeBadge()],
                        ],
                      ),
                    ),

                    SizedBox(width: 8.w),

                    // ── عمود الإيميل ──
                    Expanded(
                      flex: 3,
                      child: Text(
                        email,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontSize: 13.sp, color: greyColor),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
            ],
          ),
        ),
      ),
    );
  }
}
