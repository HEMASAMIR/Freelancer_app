import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/features/admin/logic/host_listings_cubit.dart';
import 'package:freelancer/features/admin/logic/host_listings_state.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_cubit.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_state.dart';
import 'package:freelancer/features/search/data/search_model/listing_model.dart';
import 'package:freelancer/features/search/presentation/widget/property_listing_card.dart';

class HostListingsView extends StatefulWidget {
  final Function(ListingModel) onShowDetails;
  const HostListingsView({super.key, required this.onShowDetails});

  @override
  State<HostListingsView> createState() => _HostListingsViewState();
}

class _HostListingsViewState extends State<HostListingsView> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAdminSuccess) {
      context.read<HostListingsCubit>().getHostListings(
        authState.user.id,
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
                itemBuilder: (context, index) => PropertyListingCard(
                  listing: state.listings[index],
                  onTap: () => widget.onShowDetails(state.listings[index]),
                ),
              );
            }
            if (state is HostListingsError) {
              return Center(child: Text(state.message));
            }
            return _buildEmptyState();
          },
        ),
      ],
    ));
  }

  Widget _buildFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerGrey.withValues(alpha: 0.5)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Newest first', style: TextStyle(fontWeight: FontWeight.w600)),
          SizedBox(width: 8),
          Icon(Icons.keyboard_arrow_down, size: 20),
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
}
