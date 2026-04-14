import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/features/favourite/logic/cubit/fav_cubit.dart';
import 'package:freelancer/features/favourite/data/models/wishlist_model.dart';

class WishlistsView extends StatefulWidget {
  const WishlistsView({super.key});

  @override
  State<WishlistsView> createState() => _WishlistsViewState();
}

class _WishlistsViewState extends State<WishlistsView> {
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
              fontSize: 16, color: AppColors.sub.withOpacity(0.8), height: 1.2),
        ),
        const SizedBox(height: 32),
        BlocBuilder<FavCubit, FavState>(
          builder: (context, state) {
            if (state is FavLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is FavLoaded) {
              if (state.wishlists.isEmpty) return _buildEmptyState();
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                itemCount: state.wishlists.length,
                itemBuilder: (context, index) =>
                    _WishlistCard(wishlist: state.wishlists[index]),
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
          const Text('No wishlists yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Text(
            'Create a wishlist to save your favorite listings.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 15,
                color: AppColors.sub.withOpacity(0.8),
                height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _WishlistCard extends StatelessWidget {
  final WishlistModel wishlist;
  const _WishlistCard({required this.wishlist});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                  color: AppColors.dividerGrey.withOpacity(0.5)),
            ),
            child: const Center(
              child: Icon(Icons.favorite,
                  color: AppColors.primaryRed, size: 40),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(wishlist.name,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        Text('Saved items',
            style: TextStyle(color: AppColors.sub, fontSize: 12)),
      ],
    );
  }
}