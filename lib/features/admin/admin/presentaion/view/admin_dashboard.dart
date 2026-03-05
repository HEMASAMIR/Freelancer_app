import 'package:flutter/material.dart';
import 'package:freelancer/core/color/app_color.dart';
import 'package:freelancer/features/admin/admin/presentaion/view/admin_dashboard/widget/dashboard_card.dart';
import 'package:freelancer/features/home/presentation/widget/custom_drawer.dart';

class AdminOverviewScreen extends StatefulWidget {
  const AdminOverviewScreen({super.key});

  @override
  State<AdminOverviewScreen> createState() => _AdminOverviewScreenState();
}

class _AdminOverviewScreenState extends State<AdminOverviewScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: SideDrawer(),
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: false,
              backgroundColor: AppColors.bgColor,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: GestureDetector(
                onTap: () => _scaffoldKey.currentState?.openDrawer(),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.dividerGrey,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.menu_rounded,
                      size: 20,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ),
              title: const Text(
                'Dashboard',
                style: TextStyle(
                  color: AppColors.sub,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              centerTitle: false,
            ),

            // ── Body ──────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ────────────────────────────────────────────
                    const Text(
                      'Dashboard Overview',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Welcome to the admin dashboard. Here\'s what\'s happening on your platform.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.sub,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Stat Cards ────────────────────────────────────────
                    AdminStatCard(
                      icon: Icons.home_outlined,
                      iconColor: AppColors.iconGreen,
                      title: 'Total Listings',
                      value: '17',
                      subtitle: 'Active listings on the platform',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    AdminStatCard(
                      icon: Icons.people_outline_rounded,
                      iconColor: AppColors.iconBlue,
                      title: 'Total Users',
                      value: '17',
                      subtitle: 'Registered users',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    AdminStatCard(
                      icon: Icons.calendar_today_outlined,
                      iconColor: AppColors.iconRed,
                      title: 'Bookings This Month',
                      value: '5',
                      subtitle: 'New bookings in current month',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    AdminStatCard(
                      icon: Icons.pending_actions_outlined,
                      iconColor: AppColors.iconGrey,
                      title: 'Pending Approvals',
                      value: '0',
                      subtitle: 'Items awaiting approval',
                      onTap: () {},
                    ),

                    const SizedBox(height: 40),

                    // ── Footer ────────────────────────────────────────────
                    const _OverviewFooter(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Footer ───────────────────────────────────────────────────────────────────
class _OverviewFooter extends StatelessWidget {
  const _OverviewFooter();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(height: 1, color: AppColors.dividerGrey),
        const SizedBox(height: 16),
        const Wrap(
          spacing: 8,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: [
            Text(
              '© 2026 Quickin, Inc.',
              style: TextStyle(fontSize: 11, color: AppColors.sub),
            ),
            Text('·', style: TextStyle(fontSize: 11, color: AppColors.grey)),
            Text('Terms', style: TextStyle(fontSize: 11, color: AppColors.sub)),
            Text('·', style: TextStyle(fontSize: 11, color: AppColors.grey)),
            Text(
              'Sitemap',
              style: TextStyle(fontSize: 11, color: AppColors.sub),
            ),
            Text('·', style: TextStyle(fontSize: 11, color: AppColors.grey)),
            Text(
              'Privacy',
              style: TextStyle(fontSize: 11, color: AppColors.sub),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.language, size: 14, color: AppColors.sub),
            SizedBox(width: 4),
            Text(
              'Arabic',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.sub,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 12),
            Text(
              '\$ USD',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.sub,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
