import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/core/di/service_locator.dart';
import 'package:freelancer/features/admin/logic/host_listings_cubit.dart';
import 'package:freelancer/features/admin/logic/host_listings_state.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_cubit.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_state.dart';
import 'package:freelancer/features/host/logic/cubit/host_cubit.dart';
import 'package:freelancer/features/host/presentation/listing_management_screen.dart';
import 'package:freelancer/features/listing_wizard/logic/cubit/listing_form_cubit.dart';
import 'package:freelancer/features/listing_wizard/logic/cubit/listing_wizard_cubit.dart';
import 'package:freelancer/features/listing_wizard/presentation/view/listing_wizard_screen.dart';
import 'package:freelancer/features/search/data/search_model/listing_model.dart';

class HostListingsView extends StatefulWidget {
  final Function(ListingModel) onShowDetails;
  const HostListingsView({super.key, required this.onShowDetails});

  @override
  State<HostListingsView> createState() => _HostListingsViewState();
}

class _HostListingsViewState extends State<HostListingsView> {
  String _selectedSort = 'Newest first';
  final List<String> _sortOptions = [
    'Newest first',
    'Oldest first',
    'Price: High to Low',
    'Price: Low to High',
  ];

  @override
  void initState() {
    super.initState();
    _fetchListings();
  }

  void _fetchListings() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAdminSuccess) {
      context.read<HostListingsCubit>().getHostListings(
        authState.user.id,
        sortOption: _selectedSort,
      );
    } else if (authState is AuthSuccess) {
      context.read<HostListingsCubit>().getHostListings(
        authState.user.id,
        sortOption: _selectedSort,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
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
              color: AppColors.sub.withValues(alpha: 0.8),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildFilterDropdown()),
              const SizedBox(width: 12),
              _buildAddListingButton(),
            ],
          ),
          const SizedBox(height: 32),
          BlocBuilder<HostListingsCubit, HostListingsState>(
            builder: (context, state) {
              if (state is HostListingsLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is HostListingsLoaded) {
                if (state.listings.isEmpty) return _buildEmptyState();
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    mainAxisSpacing: 16,
                    mainAxisExtent: 220.h,
                  ),
                  itemCount: state.listings.length,
                  itemBuilder: (context, index) {
                    final listing = state.listings[index];
                    return _HostListingCard(
                      listing: listing,
                      onViewDetails: () => widget.onShowDetails(listing),
                      onManage: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) => sl<HostCubit>(),
                            child: ListingManagementScreen(listing: listing),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
              if (state is HostListingsError) {
                return Center(child: Text(state.message));
              }
              return _buildEmptyState();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerGrey.withValues(alpha: 0.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedSort,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            size: 20,
            color: AppColors.ink,
          ),
          dropdownColor: AppColors.white,
          selectedItemBuilder: (BuildContext context) {
            return _sortOptions.map<Widget>((String item) {
              return Center(
                child: Text(
                  item,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              );
            }).toList();
          },
          onChanged: (String? newValue) {
            if (newValue != null && newValue != _selectedSort) {
              setState(() {
                _selectedSort = newValue;
              });
              _fetchListings();
            }
          },
          items: _sortOptions.map<DropdownMenuItem<String>>((String value) {
            final isSelected = _selectedSort == value;
            return DropdownMenuItem<String>(
              value: value,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primaryBurgundy
                            : AppColors.inkBlack,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check, color: AppColors.primaryBurgundy, size: 18),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _openListingWizard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => sl<ListingWizardCubit>()),
            BlocProvider(create: (_) => sl<ListingFormCubit>()),
          ],
          child: const ListingWizardScreen(),
        ),
      ),
    ).then((_) => _fetchListings()); // refresh after wizard closes
  }

  Widget _buildAddListingButton() {
    return ElevatedButton.icon(
      onPressed: _openListingWizard,
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
        border: Border.all(color: AppColors.dividerGrey.withValues(alpha: 0.3)),
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
            'Share your space and earn extra income. List your property and connect with travelers.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.sub.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _openListingWizard,
            icon: const Icon(Icons.add, size: 20, color: Colors.white),
            label: const Text(
              'Create your first listing',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
          ),
      )],
      ),
    );
  }
}

// ── Host Listing Card ──────────────────────────────────────────────────────
class _HostListingCard extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onViewDetails;
  final VoidCallback onManage;

  const _HostListingCard({
    required this.listing,
    required this.onViewDetails,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = (listing.images != null && listing.images!.isNotEmpty)
        ? listing.images!.first.url ?? ''
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dividerGrey.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image ──────────────────────────────────────────────
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 120,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.home_outlined,
                          size: 40, color: Colors.grey),
                    ),
                  )
                : Container(
                    height: 120,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.home_outlined,
                        size: 40, color: Colors.grey),
                  ),
          ),

          // ── Info ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    listing.title ?? 'Unnamed',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.inkBlack),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (listing.isPublished == true
                            ? Colors.green
                            : AppColors.primaryRed)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    listing.isPublished == true ? 'Live' : 'In Review',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: listing.isPublished == true
                          ? Colors.green
                          : AppColors.primaryRed,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 2, 14, 0),
            child: Text(
              'EGP ${listing.pricePerNight?.toStringAsFixed(0) ?? '—'} / night',
              style: const TextStyle(fontSize: 13, color: AppColors.greyText),
            ),
          ),

          // ── Buttons ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onViewDetails,
                    style: OutlinedButton.styleFrom(
                      side:
                          const BorderSide(color: AppColors.dividerGrey),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('View listing',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.inkBlack)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onManage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBurgundy,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Manage',
                        style: TextStyle(fontSize: 12, color: Colors.white)),
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
