import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/core/di/service_locator.dart';
import 'package:freelancer/features/account/presentation/account_info.dart';
import 'package:freelancer/features/admin/admin/presentation/view/admin_dashboard/dashboard_overview.dart';
import 'package:freelancer/features/admin/admin/presentation/view/earrnings_balance.dart';
import 'package:freelancer/features/admin/admin/widget/admin_side_drawer.dart';
import 'package:freelancer/features/admin/logic/admin_management_cubit.dart';
import 'package:freelancer/features/bookings/presentation/view/booking_request.dart';
import 'package:freelancer/features/host/presentation/host_listing.dart';
import 'package:freelancer/features/listing_wizard/logic/cubit/listing_form_cubit.dart';
import 'package:freelancer/features/listing_wizard/logic/cubit/listing_wizard_cubit.dart';
import 'package:freelancer/features/listing_wizard/presentation/view/listing_wizard_screen.dart';
import 'package:freelancer/features/search/data/search_model/listing_model.dart';
import 'package:freelancer/features/trips/presentation/view/trips.dart';
import 'package:freelancer/features/host/presentation/calendar_management_view.dart';
import 'package:freelancer/features/host/presentation/host_reviews_view.dart';

class AdminOverviewScreen extends StatefulWidget {
  final String initialView;
  const AdminOverviewScreen({super.key, this.initialView = 'Dashboard'});

  @override
  State<AdminOverviewScreen> createState() => _AdminOverviewScreenState();
}

class _AdminOverviewScreenState extends State<AdminOverviewScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late String _currentView;
  ListingModel? _selectedListing;

  @override
  void initState() {
    super.initState();
    _currentView = widget.initialView;
  }

  void _onViewChanged(String view) {
    setState(() {
      _currentView = view;
      _selectedListing = null;
    });
  }


  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdminManagementCubit>(
      create: (_) => sl<AdminManagementCubit>(),
      child: Scaffold(
        key: _scaffoldKey,
        drawer: AdminSideDrawer(onItemSelected: _onViewChanged),
        backgroundColor: AppColors.backgroundCream,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: _buildAppBarTitle(_currentView),
          centerTitle: false,
          leading: Builder(
            builder: (context) {
              return UnconstrainedBox(
                child: Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    icon: const Icon(Icons.menu_rounded,
                        color: AppColors.ink),
                  ),
                ),
              );
            },
          ),
        ),

        body: SafeArea(
          child: _buildContent(_currentView),
        ),
      ),
    );
  }

  Widget _buildAppBarTitle(String view) {
    final label = _sectionTitle(view);
    return Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
    );
  }

  String _sectionTitle(String view) {
    const map = {
      'Dashboard': 'Dashboard Overview',
      'Listings': 'All Listings',
      'Amenities': 'Amenities',
      'Conditions': 'Conditions',
      'Cancellation Policies': 'Cancellation Policies',
      'Box Offers': 'Box Offers',
      'Destinations': 'Destinations',
      'Locations': 'Locations',
      'Menus': 'Menus',
      'Financials': 'Financials',
      'Payouts': 'Payouts',
      'Bookings': 'Bookings',
      'Approvals': 'Approvals',
      'Verifications': 'Verifications',
      'Reviews': 'Reviews',
      'Comments': 'Comments',
      'Fans': 'Fans',
      'Refunds': 'Refunds',
      'Site Settings': 'Site Settings',
      'Audit Logs': 'Audit Logs',
      'Commissions': 'Commissions',
      'Holding Times': 'Holding Times',
      'Staff': 'Staff Management',
      'Account': 'Account',
      'Personal Info': 'Personal Info',
      'Earnings & Balance': 'Earnings & Balance',
    };
    return map[view] ?? view;
  }

  Widget _buildContent(String view) {
    switch (view) {
      // ── Overview ─────────────────────────────────────────────
      case 'Dashboard':
        return DashboardOverviewContent(onViewChanged: _onViewChanged);

      // ── Catalog ──────────────────────────────────────────────
      case 'Listings':
        return HostListingsView(onShowDetails: (listing) {
          setState(() {
            _selectedListing = listing;
            _currentView = 'Listing Details';
          });
        });

      case 'Listing Details':
        return _selectedListing != null
            ? _InternalListingDetailsView(
                listing: _selectedListing!,
                onBack: () => _onViewChanged('Listings'),
              )
            : const TripsScreen();

      case 'Create New':
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => sl<ListingWizardCubit>()),
            BlocProvider(create: (context) => sl<ListingFormCubit>()),
          ],
          child: const ListingWizardScreen(),
        );

      // ── Finance ───────────────────────────────────────────────
      case 'Financials':
      case 'Earnings & Balance':
        return const EarningsBalanceView();

      case 'Payouts':
        return _AdminPlaceholderView(
          title: 'Payouts',
          icon: Icons.payments_outlined,
          subtitle: 'Manage host payout requests and transactions.',
        );

      // ── Report ────────────────────────────────────────────────
      case 'Bookings':
        return const BookingRequestsView();

      case 'Approvals':
        return _AdminPlaceholderView(
          title: 'Approvals',
          icon: Icons.approval_outlined,
          subtitle: 'Review and approve pending listing submissions.',
          badgeCount: null,
        );

      case 'Verifications':
        return _AdminPlaceholderView(
          title: 'Verifications',
          icon: Icons.verified_user_outlined,
          subtitle: 'Manage identity verification requests.',
        );

      case 'Reviews':
        return const HostReviewsView();

      case 'Comments':
        return _AdminPlaceholderView(
          title: 'Comments',
          icon: Icons.comment_outlined,
          subtitle: 'View and moderate user comments.',
        );

      case 'Fans':
        return _AdminPlaceholderView(
          title: 'Fans',
          icon: Icons.people_outline,
          subtitle: 'View registered users and activity.',
        );

      case 'Refunds':
        return _AdminPlaceholderView(
          title: 'Refunds',
          icon: Icons.replay_outlined,
          subtitle: 'Process and track refund requests.',
        );

      // ── System ────────────────────────────────────────────────
      case 'Site Settings':
        return _AdminPlaceholderView(
          title: 'Site Settings',
          icon: Icons.settings_outlined,
          subtitle: 'Configure global platform settings.',
        );

      case 'Audit Logs':
        return _AdminPlaceholderView(
          title: 'Audit Logs',
          icon: Icons.description_outlined,
          subtitle: 'Review system and user activity logs.',
        );

      case 'Commissions':
        return _AdminPlaceholderView(
          title: 'Commissions',
          icon: Icons.percent_outlined,
          subtitle: 'Manage platform commission rates.',
        );

      case 'Holding Times':
        return _AdminPlaceholderView(
          title: 'Holding Times',
          icon: Icons.hourglass_empty_outlined,
          subtitle: 'Configure booking hold duration settings.',
        );

      case 'Staff':
        return _AdminPlaceholderView(
          title: 'Staff Management',
          icon: Icons.manage_accounts_outlined,
          subtitle: 'Add, edit or remove admin staff members.',
        );

      // ── Catalog extras ────────────────────────────────────────
      case 'Amenities':
        return _AdminPlaceholderView(
          title: 'Amenities',
          icon: Icons.spa_outlined,
          subtitle: 'Manage available amenities for listings.',
        );

      case 'Conditions':
        return _AdminPlaceholderView(
          title: 'Conditions',
          icon: Icons.rule_folder_outlined,
          subtitle: 'Set listing conditions and house rules.',
        );

      case 'Cancellation Policies':
        return _AdminPlaceholderView(
          title: 'Cancellation Policies',
          icon: Icons.cancel_outlined,
          subtitle: 'Define cancellation policy tiers.',
        );

      case 'Box Offers':
        return _AdminPlaceholderView(
          title: 'Box Offers',
          icon: Icons.local_offer_outlined,
          subtitle: 'Create and manage promotional offers.',
        );

      case 'Destinations':
        return _AdminPlaceholderView(
          title: 'Destinations',
          icon: Icons.explore_outlined,
          subtitle: 'Manage featured destinations.',
        );

      case 'Locations':
        return _AdminPlaceholderView(
          title: 'Locations',
          icon: Icons.location_on_outlined,
          subtitle: 'Configure available listing locations.',
        );

      case 'Menus':
        return _AdminPlaceholderView(
          title: 'Menus',
          icon: Icons.menu_book_outlined,
          subtitle: 'Edit navigation and site menus.',
        );

      // ── Account ───────────────────────────────────────────────
      case 'Personal Info':
      case 'Account':
        return AccountScreen(onViewChanged: _onViewChanged);

      case 'Calendar':
        return const CalendarManagementView();

      default:
        return DashboardOverviewContent(onViewChanged: _onViewChanged);
    }
  }
}

// ─── Admin Placeholder View ──────────────────────────────────────────────────
class _AdminPlaceholderView extends StatelessWidget {
  final String title;
  final IconData icon;
  final String subtitle;
  final int? badgeCount;

  const _AdminPlaceholderView({
    required this.title,
    required this.icon,
    required this.subtitle,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.ink,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: AppColors.dividerGrey.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, size: 36, color: AppColors.sub),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Coming Soon',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The $title module is being integrated.\nCheck back soon for full functionality.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.sub.withValues(alpha: 0.8),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Internal Listing Details ─────────────────────────────────────────────────
class _InternalListingDetailsView extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onBack;

  const _InternalListingDetailsView({
    required this.listing,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
              ),
              const Text(
                'Listing Details',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (listing.images?.isNotEmpty ?? false)
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(
                listing.images!.first.url!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.broken_image)),
                ),
              ),
            ),
          const SizedBox(height: 24),
          Text(
            listing.title ?? 'No Title',
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            listing.description ?? 'No description.',
            style: TextStyle(
                fontSize: 15, color: AppColors.sub, height: 1.5),
          ),
          const SizedBox(height: 32),
          _statRow('Price',
              'EGP ${listing.pricePerNight?.toStringAsFixed(0)} / night'),
          _statRow('Location', '${listing.city}, ${listing.country}'),
          _statRow('Status',
              listing.isPublished == true ? 'Published' : 'Draft'),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value, style: TextStyle(color: AppColors.sub)),
        ],
      ),
    );
  }
}
