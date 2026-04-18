import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/app_router/routes.dart';
import 'package:freelancer/core/shared_helper/app_color.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_cubit.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_state.dart';

/// Dedicated admin-only side drawer.
/// Mirrors the sidebar shown in the screenshots with 5 collapsible sections:
/// Overview · Catalog · Finance · Report · System
/// Plus a footer with profile info + "Switch to Live Dashboard" button.
class AdminSideDrawer extends StatefulWidget {
  final Function(String) onItemSelected;

  const AdminSideDrawer({super.key, required this.onItemSelected});

  @override
  State<AdminSideDrawer> createState() => _AdminSideDrawerState();
}

class _AdminSideDrawerState extends State<AdminSideDrawer> {
  String _selected = 'Dashboard';

  // Track expansion state per section
  bool _catalogExpanded = true;
  bool _financeExpanded = false;
  bool _reportExpanded = false;
  bool _systemExpanded = false;

  void _select(String item) {
    setState(() => _selected = item);
    Navigator.of(context).pop(); // close drawer
    Future.microtask(() {
      if (!mounted) return;
      if (item == 'Switch to Live Dashboard' || item == 'Back to Site') {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        return;
      }
      if (item == 'Log out') {
        context.read<AuthCubit>().signOut();
        return;
      }
      widget.onItemSelected(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        String name = 'Admin';
        String email = '';
        String initials = 'A';

        if (state is AuthAdminSuccess) {
          final u = state.user;
          name = (u.userMetadata['full_name'] as String?) ??
              u.email.split('@')[0];
          email = u.email;
          initials = name.isNotEmpty ? name[0].toUpperCase() : 'A';
        }

        return Drawer(
          backgroundColor: const Color(0xFF1A1A2E),
          shape:
              const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8.w, vertical: 8.h),
                    children: [
                      // ── Overview ──────────────────────────────
                      _sectionLabel('Overview'),
                      _item('Dashboard', Icons.dashboard_outlined),

                      SizedBox(height: 8.h),

                      // ── Catalog ───────────────────────────────
                      _expandableSection(
                        label: 'Catalog',
                        expanded: _catalogExpanded,
                        onToggle: () => setState(
                            () => _catalogExpanded = !_catalogExpanded),
                        children: [
                          _item('Listings',
                              Icons.maps_home_work_outlined),
                          _item('Amenities', Icons.spa_outlined),
                          _item('Conditions',
                              Icons.rule_folder_outlined),
                          _item('Cancellation Policies',
                              Icons.cancel_outlined),
                          _item('Box Offers',
                              Icons.local_offer_outlined),
                          _item('Destinations',
                              Icons.explore_outlined),
                          _item('Locations',
                              Icons.location_on_outlined),
                          _item('Menus', Icons.menu_book_outlined),
                        ],
                      ),

                      SizedBox(height: 8.h),

                      // ── Finance ───────────────────────────────
                      _expandableSection(
                        label: 'Finance',
                        expanded: _financeExpanded,
                        onToggle: () => setState(
                            () => _financeExpanded = !_financeExpanded),
                        children: [
                          _item('Financials',
                              Icons.account_balance_outlined),
                          _item('Payouts',
                              Icons.payments_outlined),
                        ],
                      ),

                      SizedBox(height: 8.h),

                      // ── Report ────────────────────────────────
                      _expandableSection(
                        label: 'Report',
                        expanded: _reportExpanded,
                        onToggle: () => setState(
                            () => _reportExpanded = !_reportExpanded),
                        children: [
                          _item('Bookings',
                              Icons.calendar_today_outlined),
                          _item('Approvals',
                              Icons.approval_outlined),
                          _item('Verifications',
                              Icons.verified_user_outlined),
                          _item('Reviews',
                              Icons.rate_review_outlined),
                          _item('Comments',
                              Icons.comment_outlined),
                          _item(
                              'Fans', Icons.people_outline),
                          _item('Refunds',
                              Icons.replay_outlined),
                        ],
                      ),

                      SizedBox(height: 8.h),

                      // ── System ────────────────────────────────
                      _expandableSection(
                        label: 'System',
                        expanded: _systemExpanded,
                        onToggle: () => setState(
                            () => _systemExpanded = !_systemExpanded),
                        children: [
                          _item('Site Settings',
                              Icons.settings_outlined),
                          _item('Audit Logs',
                              Icons.description_outlined),
                          _item('Commissions',
                              Icons.percent_outlined),
                          _item('Holding Times',
                              Icons.hourglass_empty_outlined),
                          _item('Staff',
                              Icons.manage_accounts_outlined),
                        ],
                      ),

                      SizedBox(height: 8.h),

                      // ── Switch to Live Dashboard ──────────────
                      _sectionLabel('Live View'),
                      _item(
                        'Switch to Live Dashboard',
                        Icons.open_in_browser_outlined,
                        isSpecial: true,
                      ),
                    ],
                  ),
                ),

                // ── Profile Footer ──────────────────────────────
                _buildFooter(name, email, initials),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Header ────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        border: Border(
          bottom: BorderSide(
              color: Colors.white.withValues(alpha: 0.1), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: AppColors.primaryRed,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: const Icon(Icons.admin_panel_settings,
                color: Colors.white, size: 20),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin Dashboard',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              Text(
                'Control Panel',
                style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.white.withValues(alpha: 0.5)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Section Label ─────────────────────────────────────────────
  Widget _sectionLabel(String label) {
    return Padding(
      padding:
          EdgeInsets.only(left: 16.w, right: 8.w, top: 4.h, bottom: 4.h),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white.withValues(alpha: 0.4),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // ─── Expandable Section ────────────────────────────────────────
  Widget _expandableSection({
    required String label,
    required bool expanded,
    required VoidCallback onToggle,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(8.r),
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.4),
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 16.sp,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
        if (expanded) ...children,
      ],
    );
  }

  // ─── Nav Item ──────────────────────────────────────────────────
  Widget _item(String label, IconData icon, {bool isSpecial = false}) {
    final isSelected = _selected == label;
    return InkWell(
      onTap: () => _select(label),
      borderRadius: BorderRadius.circular(8.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: EdgeInsets.symmetric(vertical: 1.h),
        padding:
            EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          border: isSelected
              ? Border.all(
                  color: Colors.white.withValues(alpha: 0.15), width: 1)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 17.sp,
              color: isSelected
                  ? Colors.white
                  : isSpecial
                      ? AppColors.primaryRed.withValues(alpha: 0.85)
                      : Colors.white.withValues(alpha: 0.65),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: isSelected
                      ? Colors.white
                      : isSpecial
                          ? AppColors.primaryRed
                              .withValues(alpha: 0.85)
                          : Colors.white.withValues(alpha: 0.75),
                ),
              ),
            ),
            if (isSelected)
              Container(
                width: 4.w,
                height: 4.w,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Footer ────────────────────────────────────────────────────
  Widget _buildFooter(String name, String email, String initials) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        border: Border(
          top: BorderSide(
              color: Colors.white.withValues(alpha: 0.1), width: 1),
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 18.r,
                backgroundColor: AppColors.primaryRed,
                child: Text(
                  initials,
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              // Admin crown badge
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: const Color(0xFF1A1A2E), width: 1.5),
                  ),
                  child: Icon(Icons.star,
                      size: 7.sp, color: Colors.brown.shade700),
                ),
              ),
            ],
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 4.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4.r),
                        border: Border.all(
                            color: const Color(0xFFFFD700)
                                .withValues(alpha: 0.5),
                            width: 0.5),
                      ),
                      child: Text(
                        'Admin',
                        style: TextStyle(
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFFD700),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
              Future.microtask(() {
                if (!mounted) return;
                context.read<AuthCubit>().signOut();
              });
            },
            borderRadius: BorderRadius.circular(6.r),
            child: Padding(
              padding: EdgeInsets.all(6.w),
              child: Icon(Icons.logout_outlined,
                  size: 16.sp,
                  color: Colors.white.withValues(alpha: 0.5)),
            ),
          ),
        ],
      ),
    );
  }
}
