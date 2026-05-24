import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/features/notifications/data/models/notification_model.dart';
import 'package:freelancer/features/notifications/logic/host_notification_cubit.dart';
import 'package:freelancer/core/utils/widgets/elegant_toast.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundCream,
      body: BlocBuilder<HostNotificationCubit, HostNotificationState>(
        builder: (context, state) {
          final notifications = state is HostNotificationLoaded
              ? state.notifications
              : <NotificationModel>[];

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(context, notifications),
              if (notifications.isEmpty)
                _buildEmptyState()
              else
                _buildList(context, notifications),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(
      BuildContext context, List<NotificationModel> notifications) {
    final unread = notifications.where((n) => !n.isRead).length;
    return SliverAppBar(
      expandedHeight: 120.h,
      pinned: true,
      backgroundColor: AppColors.backgroundCream,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: Colors.black.withOpacity(0.08),
      leading: IconButton(
        icon: Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16.sp,
            color: AppColors.inkBlack,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (notifications.isNotEmpty) ...[
          TextButton(
            onPressed: () {
              context.read<HostNotificationCubit>().markAllRead();
              ElegantToast.show(
                context,
                'All notifications marked as read',
                icon: Icons.mark_email_read_rounded,
              );
            },
            child: Text(
              'Mark all read',
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.primaryBurgundy,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.delete_sweep_outlined,
              color: AppColors.greyText,
              size: 22.sp,
            ),
            tooltip: 'Clear all',
            onPressed: () => _confirmClear(context),
          ),
        ],
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(left: 20.w, bottom: 16.h),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Notifications',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.inkBlack,
                letterSpacing: -0.5,
              ),
            ),
            if (unread > 0) ...[
              SizedBox(width: 8.w),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryBurgundy,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '$unread',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.backgroundCream,
                AppColors.backgroundCream.withOpacity(0.95),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildEmptyState() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 500.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90.w,
              height: 90.w,
              decoration: BoxDecoration(
                color: AppColors.primaryBurgundy.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 44.sp,
                color: AppColors.primaryBurgundy.withOpacity(0.5),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.inkBlack,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'When guests book your listings,\nyou\'ll see it here instantly.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.greyText,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverList _buildList(
      BuildContext context, List<NotificationModel> notifications) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final n = notifications[index];
          return _NotificationCard(
            notification: n,
            onTap: () {
              final wasUnread = !n.isRead;
              context.read<HostNotificationCubit>().markRead(n.id);
              if (wasUnread) {
                ElegantToast.show(
                  context,
                  'Notification marked as read',
                  icon: Icons.check_circle_outline_rounded,
                );
              } else {
                ElegantToast.show(
                  context,
                  'Viewing request from ${n.guestName}',
                  icon: Icons.remove_red_eye_rounded,
                );
              }
            },
          );
        },
        childCount: notifications.length,
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    final cubit = context.read<HostNotificationCubit>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          'Clear notifications?',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.inkBlack,
          ),
        ),
        content: Text(
          'All notifications will be removed from this list.',
          style:
              TextStyle(fontSize: 13.sp, color: AppColors.greyText, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(
                  color: AppColors.greyText, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () {
              cubit.clearAll();
              Navigator.pop(ctx);
              ElegantToast.show(
                context,
                'All notifications cleared',
                icon: Icons.delete_sweep_rounded,
              );
            },
            child: Text(
              'Clear all',
              style: TextStyle(
                  color: AppColors.primaryBurgundy,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Notification Card ────────────────────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  Color get _statusColor {
    switch (notification.status) {
      case 'confirmed':
        return const Color(0xFF2E7D32);
      case 'cancelled':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFFE65100);
    }
  }

  Color get _statusBg {
    switch (notification.status) {
      case 'confirmed':
        return const Color(0xFFE8F5E9);
      case 'cancelled':
        return const Color(0xFFFFEBEE);
      default:
        return const Color(0xFFFFF3E0);
    }
  }

  IconData get _statusIcon {
    switch (notification.status) {
      case 'confirmed':
        return Icons.check_circle_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.schedule_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final isUnread = !n.isRead;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: isUnread ? Colors.white : Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: isUnread
                  ? AppColors.primaryBurgundy.withOpacity(0.15)
                  : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isUnread ? 0.07 : 0.03),
                blurRadius: isUnread ? 12 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Avatar ────────────────────────────────────────
                Stack(
                  children: [
                    Container(
                      width: 50.w,
                      height: 50.w,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryBurgundy,
                            AppColors.primaryBurgundy.withOpacity(0.75),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          n.guestName.isNotEmpty
                              ? n.guestName[0].toUpperCase()
                              : 'G',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    if (isUnread)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 12.w,
                          height: 12.w,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBurgundy,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),

                SizedBox(width: 14.w),

                // ── Content ───────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'New Booking Request',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: isUnread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: AppColors.inkBlack,
                              ),
                            ),
                          ),
                          Text(
                            n.timeAgo,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.greyText,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),

                      // Guest + listing
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.greyText,
                            height: 1.4,
                          ),
                          children: [
                            TextSpan(
                              text: n.guestName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.inkBlack,
                              ),
                            ),
                            const TextSpan(text: ' wants to book '),
                            TextSpan(
                              text: n.listingTitle,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryBurgundy,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.h),

                      // Dates row
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color:
                              AppColors.backgroundCream.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Row(
                          children: [
                            _InfoChip(
                              icon: Icons.calendar_today_rounded,
                              label: _formatDate(n.checkIn),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                size: 14.sp,
                                color: AppColors.greyText,
                              ),
                            ),
                            _InfoChip(
                              icon: Icons.calendar_today_rounded,
                              label: _formatDate(n.checkOut),
                            ),
                            const Spacer(),
                            _InfoChip(
                              icon: Icons.nights_stay_outlined,
                              label: '${n.nights} nights',
                            ),
                            SizedBox(width: 10.w),
                            _InfoChip(
                              icon: Icons.person_outline_rounded,
                              label: '${n.guests} guests',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.h),

                      // Bottom row: price + status
                      Row(
                        children: [
                          // Price
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBurgundy
                                  .withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              'EGP ${NumberFormat('#,###').format(n.subtotal)}',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryBurgundy,
                              ),
                            ),
                          ),
                          const Spacer(),
                          // Status badge
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: _statusBg,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _statusIcon,
                                  size: 12.sp,
                                  color: _statusColor,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  n.statusLabel,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: _statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('MMM d').format(dt);
    } catch (_) {
      return raw;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11.sp, color: AppColors.greyText),
        SizedBox(width: 3.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: AppColors.greyText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
