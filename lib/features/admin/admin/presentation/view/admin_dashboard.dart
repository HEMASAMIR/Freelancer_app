import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/features/account/presentation/account_info.dart';
import 'package:freelancer/features/admin/admin/presentation/view/admin_dashboard/widget/over_view_footer.dart';
import 'package:freelancer/features/admin/admin/presentation/view/admin_dashboard/dashboard_overview.dart';
import 'package:freelancer/features/admin/admin/presentation/view/earrnings_balance.dart';
import 'package:freelancer/features/bookings/presentation/view/booking_request.dart';

import 'package:freelancer/features/home/presentation/widget/custom_drawer.dart';
import 'package:freelancer/features/host/presentation/host_listing.dart';
import 'package:freelancer/features/search/data/search_model/listing_model.dart';
import 'package:freelancer/features/listing_wizard/presentation/view/listing_wizard_screen.dart';
import 'package:freelancer/features/listing_wizard/logic/cubit/listing_wizard_cubit.dart';
import 'package:freelancer/features/listing_wizard/logic/cubit/listing_form_cubit.dart';
import 'package:freelancer/core/di/service_locator.dart';
import 'package:freelancer/features/trips/presentation/view/trips.dart';
import 'package:freelancer/features/wishlists/presentation/view/wishlist_screen.dart';

class AdminOverviewScreen extends StatefulWidget {
  final String initialView;
  const AdminOverviewScreen({super.key, this.initialView = 'Trips'});

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

  void _showListingDetails(ListingModel listing) {
    setState(() {
      _selectedListing = listing;
      _currentView = 'Listing Details';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: SideDrawer(onItemSelected: _onViewChanged),
      backgroundColor: AppColors.backgroundCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
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
                  icon: const Icon(Icons.menu_rounded, color: AppColors.ink),
                ),
              ),
            );
          }
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildContent(_currentView)),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: OverviewFooter(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(String view) {
    switch (view) {
      case 'Trips':
        return const TripsScreen();
      case 'Overview':
        return DashboardOverviewContent(onViewChanged: _onViewChanged);
      case 'Personal Info':
      case 'Account':
        return AccountScreen(onViewChanged: _onViewChanged);
      case 'Earnings & Balance':
        return const EarningsBalanceView();
      case 'Bookings':
        return const BookingRequestsView();
      case 'Wishlists':
        return const WishlistsView();
      case 'All Listings':
      case 'My Listings':
        return HostListingsView(onShowDetails: _showListingDetails);
      case 'Listing Details':
        return _selectedListing != null
            ? _InternalListingDetailsView(
                listing: _selectedListing!,
                onBack: () => _onViewChanged('My Listings'),
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
      default:
        return const AccountScreen();
    }
  }
}

// ─── Placeholder ─────────────────────────────────────────────
class _PlaceholderView extends StatelessWidget {
  final String title;
  const _PlaceholderView({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 32),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(48),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.dividerGrey.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              const Icon(Icons.construction, size: 48, color: AppColors.sub),
              const SizedBox(height: 16),
              const Text(
                'Coming Soon',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'The $title feature is being integrated.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.sub.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Internal Listing Details ────────────────────────────────
class _InternalListingDetailsView extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onBack;

  const _InternalListingDetailsView({
    required this.listing,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back)),
            const Text(
              'Listing Details',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          listing.description ?? 'No description.',
          style: TextStyle(fontSize: 15, color: AppColors.sub, height: 1.5),
        ),
        const SizedBox(height: 32),
        _statRow(
          'Price',
          'EGP ${listing.pricePerNight?.toStringAsFixed(0)} / night',
        ),
        _statRow('Location', '${listing.city}, ${listing.country}'),
        _statRow('Status', listing.isPublished == true ? 'Published' : 'Draft'),
      ],
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value, style: TextStyle(color: AppColors.sub)),
        ],
      ),
    );
  }
}
