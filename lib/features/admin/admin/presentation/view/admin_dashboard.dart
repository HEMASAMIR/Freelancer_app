import 'package:flutter/material.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freelancer/features/admin/logic/host_listings_cubit.dart';
import 'package:freelancer/features/admin/logic/host_listings_state.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_cubit.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_state.dart';
import 'package:freelancer/features/bookings/data/models/booking_model.dart';
import 'package:freelancer/features/bookings/logic/cubit/bookings_cubit.dart';
import 'package:freelancer/features/bookings/logic/cubit/bookings_state.dart';
import 'package:freelancer/features/search/data/search_model/listing_model.dart';
import 'package:intl/intl.dart';
import 'package:freelancer/features/favourite/logic/cubit/fav_cubit.dart';
import 'package:freelancer/features/favourite/data/models/wishlist_model.dart';
import 'package:freelancer/features/admin/logic/wallet_cubit.dart';
import 'package:freelancer/features/admin/logic/wallet_state.dart';
import 'package:freelancer/features/admin/admin/presentation/view/admin_dashboard/widget/dashboard_card.dart';
import 'package:freelancer/features/search/presentation/widget/property_listing_card.dart';
import 'package:freelancer/features/search/presentation/view/search_details.dart';
import 'package:freelancer/features/home/presentation/widget/custom_drawer.dart';

class AdminOverviewScreen extends StatefulWidget {
  const AdminOverviewScreen({super.key});

  @override
  State<AdminOverviewScreen> createState() => _AdminOverviewScreenState();
}

class _AdminOverviewScreenState extends State<AdminOverviewScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _currentView = 'Trips';
  ListingModel? _selectedListing;

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
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: false,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                icon: const Icon(Icons.menu_rounded, color: AppColors.ink),
              ),
            ),

            // ── Body ──────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildContent(_currentView),
                    const SizedBox(height: 48),
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

  Widget _buildContent(String view) {
    switch (view) {
      case 'Trips':
        return const _TripsView();

      case 'Overview':
      case 'Personal Info':
      case 'Account':
        return const _AccountView();
      case 'Earnings & Balance':
        return const _EarningsBalanceView();
      case 'Bookings':
        return const _BookingRequestsView();
      case 'Wishlists':
        return const _WishlistsView();
      case 'All Listings':
      case 'My Listings':
        return _HostListingsView(onShowDetails: _showListingDetails);
      case 'Listing Details':
        return _selectedListing != null
            ? _InternalListingDetailsView(
                listing: _selectedListing!,
                onBack: () => _onViewChanged('My Listings'),
              )
            : const _TripsView();
      case 'Create New':
        return const _PlaceholderView(title: 'Create New Listing');
      default:
        return const _AccountView();
    }
  }
}

class _WishlistsView extends StatefulWidget {
  const _WishlistsView();

  @override
  State<_WishlistsView> createState() => _WishlistsViewState();
}

class _WishlistsViewState extends State<_WishlistsView> {
  @override
  void initState() {
    super.initState();
    context.read<FavCubit>().loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Wishlists',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Manage your favorite properties and saved lists.',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.sub.withOpacity(0.8),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 32),
        BlocBuilder<FavCubit, FavState>(
          builder: (context, state) {
            if (state is FavLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is FavLoaded) {
              if (state.wishlists.isEmpty) {
                return _buildEmptyState();
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                itemCount: state.wishlists.length,
                itemBuilder: (context, index) {
                  return _buildWishlistCard(state.wishlists[index]);
                },
              );
            }
            if (state is FavError) {
              return Center(child: Text(state.message));
            }
            return _buildEmptyState();
          },
        ),
      ],
    );
  }

  Widget _buildWishlistCard(WishlistModel wishlist) {
    return InkWell(
      onTap: () {
        // Here we could stay internal too, but for now let's use the existing screen
        // or just show a message.
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: AppColors.dividerGrey.withOpacity(0.5),
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.favorite,
                  color: AppColors.primaryRed,
                  size: 40,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            wishlist.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            "Saved items",
            style: TextStyle(color: AppColors.sub, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.dividerGrey.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.favorite_border, size: 48, color: AppColors.sub),
          const SizedBox(height: 24),
          const Text(
            'No wishlists yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(
            'Create a wishlist to save your favorite listings.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.sub.withOpacity(0.8),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

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
            border: Border.all(color: AppColors.dividerGrey.withOpacity(0.5)),
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
                  color: AppColors.sub.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Account View ────────────────────────────────────────────────────────────
class _AccountView extends StatefulWidget {
  const _AccountView();

  @override
  State<_AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<_AccountView> {
  String _activeTab = 'Personal Info';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Account',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Manage your profile, verification, and account settings.',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.sub.withOpacity(0.8),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 32),
        const _ProfileHeaderCard(
          name: 'Hema Samir',
          email: '01055673184hs@gmail.com',
          initials: 'HS',
          memberSince: 'March 2026',
        ),
        const SizedBox(height: 32),
        _buildTabs(),
        const SizedBox(height: 32),
        _buildTabContent(),
      ],
    );
  }

  Widget _buildTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ['Personal Info', 'Verification', 'Settings'].map((tab) {
          final isActive = _activeTab == tab;
          return GestureDetector(
            onTap: () => setState(() => _activeTab = tab),
            child: _TabItem(title: tab, isActive: isActive),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_activeTab) {
      case 'Verification':
        return const _VerificationTab();
      case 'Settings':
        return const _SettingsTab();
      case 'Personal Info':
      default:
        return const _PersonalInfoTab();
    }
  }
}

class _PersonalInfoTab extends StatelessWidget {
  const _PersonalInfoTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Update your phone number and address',
          style: TextStyle(fontSize: 14, color: AppColors.sub.withOpacity(0.7)),
        ),
        const SizedBox(height: 24),
        DashboardCard(
          icon: Icons.phone_android_outlined,
          iconColor: AppColors.iconBlue,
          title: 'Phone Number',
          value: '+20 1055673184',
          subtitle: 'Verified mobile number',
          onTap: () {},
        ),
      ],
    );
  }
}

class _VerificationTab extends StatelessWidget {
  const _VerificationTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildStatusCard(),
        const SizedBox(height: 32),
        _buildUploadSection(
          title: 'ID Card (Back)',
          subtitle: 'Upload the back of your national ID',
          icon: Icons.credit_card_outlined,
        ),
        const SizedBox(height: 24),
        _buildUploadSection(
          title: 'Selfie Photo',
          subtitle: 'Upload a clear photo of your face',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 32),
        _buildInfoBox(),
        const SizedBox(height: 32),
        _buildSubmitButton(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildUploadSection({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.dividerGrey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.ink),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.sub.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 24),
          _buildUploadContainer(),
        ],
      ),
    );
  }

  Widget _buildUploadContainer() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.backgroundCream.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.dividerGrey.withOpacity(0.5),
          width: 1,
          style: BorderStyle
              .none, // We'll simulate dashed with decoration or custom painter
        ),
      ),
      child: Stack(
        children: [
          // Simulate dash border with a custom painter would be better, but for now:
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.dividerGrey.withOpacity(0.3)),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.upload_outlined,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Click or drag to upload',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xfff8f4f0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.ink, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Why do we need this?',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Identity verification helps keep our community safe. Your documents are securely stored and only reviewed by our verification team. This is required before you can book or list properties.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.sub.withOpacity(0.9),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: null, // Disabled until 0/3 is fulfilled
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xffb07c7c).withOpacity(0.5),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: const Color(0xffb07c7c).withOpacity(0.5),
        ),
        child: const Text(
          'Submit for Verification (0/3)',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.dividerGrey.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3EFE9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield_outlined, color: AppColors.ink),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Identity Verification',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.dividerGrey),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Not Verified',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Verify your identity to book or list properties',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.sub.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.dividerGrey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Verification Requirements',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete all steps to become fully verified',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.sub.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          _buildRequirementItem(
            'Email Verification',
            'Your email is verified',
            Icons.check_circle_outline,
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildRequirementItem(
            'Phone Verification',
            'Required to complete booking',
            Icons.radio_button_unchecked,
            AppColors.sub,
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.sub.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Settings View'));
  }
}

// ─── Host Listings View ──────────────────────────────────────────────────────
class _HostListingsView extends StatefulWidget {
  final Function(ListingModel) onShowDetails;
  const _HostListingsView({required this.onShowDetails});

  @override
  State<_HostListingsView> createState() => _HostListingsViewState();
}

class _HostListingsViewState extends State<_HostListingsView> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAdminSuccess) {
      context.read<HostListingsCubit>().getHostListings(
        authState.user.email ?? '',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your listings',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your properties and keep track of reservations.',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.sub.withOpacity(0.8),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            _buildFilterDropdown(),
            const Spacer(),
            _buildAddListingButton(),
          ],
        ),
        const SizedBox(height: 32),
        BlocBuilder<HostListingsCubit, HostListingsState>(
          builder: (context, state) {
            if (state is HostListingsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HostListingsLoaded) {
              if (state.listings.isEmpty) {
                return _buildEmptyState();
              }
              return _buildListingsGrid(state.listings);
            } else if (state is HostListingsError) {
              return Center(child: Text(state.message));
            }
            return _buildEmptyState();
          },
        ),
      ],
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerGrey.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Newest first',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.keyboard_arrow_down, size: 20),
        ],
      ),
    );
  }

  Widget _buildAddListingButton() {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.add, size: 20, color: Colors.white),
      label: const Text('Add listing', style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryRed,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.dividerGrey.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.bgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.home_outlined,
              size: 40,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Start hosting today',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(
            'Share your space and earn extra income. List\nyour property and connect with travelers from\naround the world.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.sub.withOpacity(0.8),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 20, color: Colors.white),
            label: const Text(
              'Create your first listing',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListingsGrid(List<ListingModel> listings) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisSpacing: 16,
        mainAxisExtent: 220.h,
      ),
      itemCount: listings.length,
      itemBuilder: (context, index) => PropertyListingCard(
        listing: listings[index],
        onTap: () => widget.onShowDetails(listings[index]),
      ),
    );
  }
}

// ─── Trips View ──────────────────────────────────────────────────────────────
class _TripsView extends StatefulWidget {
  const _TripsView();

  @override
  State<_TripsView> createState() => _TripsViewState();
}

class _TripsViewState extends State<_TripsView> {
  String _selectedFilter = 'Upcoming';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthSuccess || authState is AuthAdminSuccess) {
      final userId = authState is AuthSuccess
          ? authState.user.id
          : (authState as AuthAdminSuccess).user.id;
      context.read<BookingsCubit>().getUserBookings(userId: userId);
    }
  }

  List<BookingModel> _filterBookings(List<BookingModel> bookings) {
    List<BookingModel> filtered;
    switch (_selectedFilter) {
      case 'Pending':
        filtered = bookings.where((b) => b.status == 'pending').toList();
        break;
      case 'History':
        filtered = bookings
            .where((b) => b.status == 'cancelled' || b.status == 'completed')
            .toList();
        break;
      case 'Upcoming':
      default:
        filtered = bookings
            .where((b) => b.status == 'confirmed' || b.status == 'upcoming')
            .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (b) =>
                (b.id ?? '').toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                (b.listingId ?? '').toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trips',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your booking requests and reservations.',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.sub.withOpacity(0.8),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 32),

        // Search Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF3EFE9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: const InputDecoration(
              hintText: 'Find by reservation code...',
              hintStyle: TextStyle(fontSize: 14, color: AppColors.sub),
              border: InputBorder.none,
              icon: Icon(Icons.search, size: 20, color: AppColors.ink),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['Pending', 'Upcoming', 'History'].map((filter) {
              final isActive = _selectedFilter == filter;
              return GestureDetector(
                onTap: () => setState(() => _selectedFilter = filter),
                child: _TabItem(
                  title: filter,
                  isActive: isActive,
                  icon: filter == 'Pending'
                      ? Icons.access_time
                      : filter == 'Upcoming'
                      ? Icons.check_circle_outline
                      : Icons.history,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 32),

        // Content
        BlocBuilder<BookingsCubit, BookingsState>(
          builder: (context, state) {
            if (state is BookingsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is BookingsError) {
              return Center(child: Text(state.message));
            }
            if (state is BookingsListLoaded) {
              final filtered = _filterBookings(state.bookings);
              if (filtered.isEmpty) {
                return _buildEmptyState();
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (_, i) => _TripCard(booking: filtered[i]),
              );
            }
            return _buildEmptyState();
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.dividerGrey.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            size: 48,
            color: AppColors.sub,
          ),
          const SizedBox(height: 16),
          Text(
            'No ${_selectedFilter.toLowerCase()} trips',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Time to plan your next adventure',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.sub.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBurgundy,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Start searching'),
          ),
        ],
      ),
    );
  }
}

// ─── Profile Header Card ──────────────────────────────────────────────────────
class _ProfileHeaderCard extends StatelessWidget {
  final String name;
  final String email;
  final String initials;
  final String memberSince;

  const _ProfileHeaderCard({
    required this.name,
    required this.email,
    required this.initials,
    required this.memberSince,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFF3EFE9),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8B7E6D),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.sub.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.dividerGrey),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            size: 14,
                            color: AppColors.sub,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Icon(
                    Icons.calendar_month_outlined,
                    size: 16,
                    color: AppColors.sub,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Member since',
                    style: TextStyle(fontSize: 11, color: AppColors.sub),
                  ),
                  Text(
                    memberSince,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Section Tabs ─────────────────────────────────────────────────────────────
// Note: Handled internally in _AccountViewState now

class _TabItem extends StatelessWidget {
  final String title;
  final bool isActive;
  final IconData? icon;
  const _TabItem({required this.title, required this.isActive, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? AppColors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? AppColors.dividerGrey : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: isActive ? AppColors.ink : AppColors.sub,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? AppColors.ink : AppColors.sub,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Trip Card ────────────────────────────────────────────────────────────────
class _TripCard extends StatelessWidget {
  final BookingModel booking;
  const _TripCard({required this.booking});

  Color _statusColor(String? status) {
    switch (status) {
      case 'confirmed':
      case 'upcoming':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final checkIn = booking.checkIn != null
        ? DateFormat('MMM d, yyyy').format(DateTime.parse(booking.checkIn!))
        : '-';
    final checkOut = booking.checkOut != null
        ? DateFormat('MMM d, yyyy').format(DateTime.parse(booking.checkOut!))
        : '-';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerGrey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reservation #${(booking.id ?? '').substring(0, 8)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusColor(booking.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  booking.status ?? '-',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _statusColor(booking.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: AppColors.sub,
              ),
              const SizedBox(width: 6),
              Text(
                '$checkIn → $checkOut',
                style: const TextStyle(fontSize: 13, color: AppColors.sub),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.people_outline, size: 14, color: AppColors.sub),
              const SizedBox(width: 6),
              Text(
                '${booking.guests ?? 1} guest${(booking.guests ?? 1) > 1 ? 's' : ''}',
                style: const TextStyle(fontSize: 13, color: AppColors.sub),
              ),
              const Spacer(),
              Text(
                'EGP ${booking.subtotal?.toStringAsFixed(0) ?? '-'}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Footer ───────────────────────────────────────────────────────────────────
class _OverviewFooter extends StatelessWidget {
  const _OverviewFooter();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(height: 0.5, color: AppColors.dividerGrey.withOpacity(0.5)),
        const SizedBox(height: 24),
        const Wrap(
          spacing: 8,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: [
            Text(
              '© 2026 Quickin, Inc.',
              style: TextStyle(fontSize: 11, color: AppColors.sub),
            ),
            Text(
              '·',
              style: TextStyle(fontSize: 11, color: AppColors.greyText),
            ),
            Text('Terms', style: TextStyle(fontSize: 11, color: AppColors.sub)),
            Text(
              '·',
              style: TextStyle(fontSize: 11, color: AppColors.greyText),
            ),
            Text(
              'Sitemap',
              style: TextStyle(fontSize: 11, color: AppColors.sub),
            ),
            Text(
              '·',
              style: TextStyle(fontSize: 11, color: AppColors.greyText),
            ),
            Text(
              'Privacy',
              style: TextStyle(fontSize: 11, color: AppColors.sub),
            ),
          ],
        ),
        const SizedBox(height: 12),
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
      ],
    );
  }
}

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
            ),
          ),
        const SizedBox(height: 24),
        Text(
          listing.title ?? 'No Title',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          listing.description ?? 'No description provided.',
          style: TextStyle(fontSize: 15, color: AppColors.sub, height: 1.5),
        ),
        const SizedBox(height: 32),
        _buildStatRow(
          'Price',
          'EGP ${listing.pricePerNight?.toStringAsFixed(0)} / night',
        ),
        _buildStatRow('Location', '${listing.city}, ${listing.country}'),
        _buildStatRow(
          'Status',
          listing.isPublished == true ? 'Published' : 'Draft',
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
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

class _EarningsBalanceView extends StatefulWidget {
  const _EarningsBalanceView();

  @override
  State<_EarningsBalanceView> createState() => _EarningsBalanceViewState();
}

class _EarningsBalanceViewState extends State<_EarningsBalanceView> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAdminSuccess) {
      context.read<WalletCubit>().loadWallet(authState.user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletCubit, WalletState>(
      builder: (context, state) {
        if (state is WalletLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        Map<String, dynamic> balance = {
          'available_balance': 0.0,
          'on_hold': 0.0,
          'total_inflows': 0.0,
        };

        if (state is WalletLoaded) {
          balance = state.balance;
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Wallet Balance',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'View your balance, request withdrawals, and track transactions.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.sub.withOpacity(0.8),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 32),

              _buildBalanceCard(
                title: 'Available Balance',
                amount:
                    'EGP ${balance['available_balance']?.toStringAsFixed(0)}',
                subtitle: 'Ready for withdrawal',
                color: Colors.green.shade700,
              ),
              const SizedBox(height: 16),
              _buildBalanceCard(
                title: 'On Hold',
                amount: 'EGP ${balance['on_hold']?.toStringAsFixed(0)}',
                subtitle: 'Pending check-in',
                color: Colors.orange.shade700,
              ),
              const SizedBox(height: 16),
              _buildBalanceCard(
                title: 'Total Inflows',
                amount: 'EGP ${balance['total_inflows']?.toStringAsFixed(0)}',
                subtitle: 'Lifetime total received',
                color: Colors.black,
              ),

              const SizedBox(height: 48),
              _buildSectionHeader('Transaction History'),
              Text(
                'Recent credits and debits to your account.',
                style: TextStyle(fontSize: 14, color: AppColors.sub),
              ),
              const SizedBox(height: 24),
              _buildSearchBar('Search by description...'),
              const SizedBox(height: 16),
              _buildTransactionTable(),

              const SizedBox(height: 48),
              _buildSectionHeader('Request Withdrawal'),
              Text(
                'Withdraw funds to your connected accounts.',
                style: TextStyle(fontSize: 14, color: AppColors.sub),
              ),
              const SizedBox(height: 24),
              _buildWithdrawalForm(),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBalanceCard({
    required String title,
    required String amount,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.dividerGrey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          Text(
            amount,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.sub)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSearchBar(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerGrey.withOpacity(0.5)),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
        ),
      ),
    );
  }

  Widget _buildTransactionTable() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.dividerGrey.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: AppColors.sub,
          ),
          const SizedBox(height: 16),
          const Text(
            'No results.',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            '0 row(s) total.',
            style: TextStyle(fontSize: 12, color: AppColors.sub),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalForm() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.dividerGrey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Amount (EGP)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: '0.00',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 8),
          Text(
            'Maximum: EGP 0',
            style: TextStyle(fontSize: 12, color: AppColors.sub),
          ),
          const SizedBox(height: 24),
          const Text(
            'Withdrawal Method',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: 'Vodafone Cash',
                isExpanded: true,
                items: ['Vodafone Cash'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (_) {},
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffb07c7c),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Request Payout',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingRequestsView extends StatefulWidget {
  const _BookingRequestsView();

  @override
  State<_BookingRequestsView> createState() => _BookingRequestsViewState();
}

class _BookingRequestsViewState extends State<_BookingRequestsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBookings();
  }

  void _loadBookings() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAdminSuccess) {
      context.read<BookingsCubit>().getHostBookings(hostId: authState.user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Booking Requests',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Manage booking requests for your properties',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.sub.withOpacity(0.8),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 32),
        _buildSearchBar('Find by reservation code...'),
        const SizedBox(height: 24),

        Container(
          height: 48,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            labelColor: Colors.black,
            unselectedLabelColor: AppColors.sub,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
            tabs: const [
              Tab(text: 'Pending'),
              Tab(text: 'Confirmed'),
              Tab(text: 'All'),
            ],
          ),
        ),

        const SizedBox(height: 32),
        Expanded(
          child: BlocBuilder<BookingsCubit, BookingsState>(
            builder: (context, state) {
              if (state is BookingsLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              List<BookingModel> bookings = [];
              if (state is BookingsListLoaded) {
                bookings = state.bookings;
              }

              return TabBarView(
                controller: _tabController,
                children: [
                  _buildBookingList(
                    bookings.where((b) => b.status == 'pending').toList(),
                    'No pending booking requests',
                  ),
                  _buildBookingList(
                    bookings.where((b) => b.status == 'confirmed').toList(),
                    'No confirmed bookings',
                  ),
                  _buildBookingList(bookings, 'No bookings found'),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBookingList(List<BookingModel> bookings, String emptyMessage) {
    if (bookings.isEmpty) {
      return _buildEmptyState(emptyMessage);
    }
    return ListView.builder(
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            title: Text('Booking #${booking.id?.substring(0, 8) ?? "..."}'),
            subtitle: Text(
              'Listing: ${booking.listingId} | Guests: ${booking.guests}',
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color:
                    (booking.status == 'confirmed'
                            ? Colors.green
                            : Colors.orange)
                        .withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                booking.status ?? 'unknown',
                style: TextStyle(
                  color: booking.status == 'confirmed'
                      ? Colors.green
                      : Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerGrey.withOpacity(0.5)),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.dividerGrey.withOpacity(0.3)),
            ),
            child: const Icon(
              Icons.access_time,
              size: 48,
              color: AppColors.sub,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.sub,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
