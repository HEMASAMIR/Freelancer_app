import 'package:flutter/material.dart';
import 'package:freelancer/core/shared_helper/app_color.dart';

class SideDrawer extends StatefulWidget {
  const SideDrawer({super.key});

  @override
  State<SideDrawer> createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
  String _selected = 'Dashboard';

  void _select(String item) {
    setState(() => _selected = item);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      child: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────────
            _DrawerHeader(),
            Container(height: 1, color: AppColors.dividerGrey),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // بدون section label
                    _NavTile(
                      icon: Icons.grid_view_rounded,
                      title: 'Dashboard',
                      selected: _selected,
                      onTap: _select,
                    ),

                    const SizedBox(height: 8),
                    // Content
                    _SectionLabel('Content'),
                    _NavTile(
                      icon: Icons.home_outlined,
                      title: 'Listings',
                      selected: _selected,
                      onTap: _select,
                    ),
                    const SizedBox(height: 4),
                    _NavTile(
                      icon: Icons.explore_outlined,
                      title: 'Destinations',
                      selected: _selected,
                      onTap: _select,
                    ),
                    const SizedBox(height: 4),
                    _NavTile(
                      icon: Icons.location_on_outlined,
                      title: 'Locations',
                      selected: _selected,
                      onTap: _select,
                    ),
                    const SizedBox(height: 4),
                    _NavTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Hosts',
                      selected: _selected,
                      onTap: _select,
                    ),
                    const SizedBox(height: 4),
                    _NavTile(
                      icon: Icons.people_outline_rounded,
                      title: 'Users',
                      selected: _selected,
                      onTap: _select,
                    ),

                    const SizedBox(height: 8),
                    // Finance
                    _SectionLabel('Finance'),
                    _NavTile(
                      icon: Icons.attach_money_rounded,
                      title: 'Financials',
                      selected: _selected,
                      onTap: _select,
                    ),
                    const SizedBox(height: 4),
                    _NavTile(
                      icon: Icons.payment_outlined,
                      title: 'Payouts',
                      selected: _selected,
                      onTap: _select,
                    ),
                    const SizedBox(height: 4),
                    _NavTile(
                      icon: Icons.credit_card_outlined,
                      title: 'Payments',
                      selected: _selected,
                      onTap: _select,
                    ),

                    const SizedBox(height: 8),
                    // Support
                    _SectionLabel('Support'),
                    _NavTile(
                      icon: Icons.pending_actions_outlined,
                      title: 'Approvals',
                      selected: _selected,
                      onTap: _select,
                    ),
                    const SizedBox(height: 4),
                    _NavTile(
                      icon: Icons.verified_outlined,
                      title: 'Verifications',
                      selected: _selected,
                      onTap: _select,
                    ),
                    const SizedBox(height: 4),
                    _NavTile(
                      icon: Icons.warning_amber_outlined,
                      title: 'Disputes',
                      selected: _selected,
                      onTap: _select,
                    ),

                    const SizedBox(height: 8),
                    // System
                    _SectionLabel('System'),
                    _NavTile(
                      icon: Icons.receipt_long_outlined,
                      title: 'Audit Logs',
                      selected: _selected,
                      onTap: _select,
                    ),
                    const SizedBox(height: 4),
                    _NavTile(
                      icon: Icons.support_agent_outlined,
                      title: 'Staff',
                      selected: _selected,
                      onTap: _select,
                    ),

                    const SizedBox(height: 8),
                    // User View
                    _SectionLabel('User View'),
                    _NavTile(
                      icon: Icons.swap_horiz_rounded,
                      title: 'Switch to User Dashboard',
                      selected: _selected,
                      onTap: _select,
                    ),
                  ],
                ),
              ),
            ),

            // ── Footer ────────────────────────────────────────────────────
            _DrawerFooter(),
          ],
        ),
      ),
    );
  }
}

// ─── Nav Tile ──────────────────────────────────────────────────────────────────
class _NavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String selected;
  final void Function(String) onTap;

  const _NavTile({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = selected == title;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(title),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.selectedBg : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? AppColors.primaryRed : AppColors.sub,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.primaryRed : AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Section Label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 14, bottom: 2),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.greyText,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

// ─── Drawer Header ─────────────────────────────────────────────────────────────
class _DrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primaryRed,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'Q',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Admin Dashboard',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
              letterSpacing: -0.2,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.bgColor,
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 14,
                color: AppColors.sub,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Drawer Footer ─────────────────────────────────────────────────────────────
class _DrawerFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.dividerGrey, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryRed.withOpacity(0.12),
            child: const Text(
              'P',
              style: TextStyle(
                color: AppColors.primaryRed,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Platform Owner',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'admin.aclone@atomicmail.io',
                  style: TextStyle(fontSize: 10, color: AppColors.sub),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.logout_rounded,
              size: 16,
              color: AppColors.sub,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
        ],
      ),
    );
  }
}
