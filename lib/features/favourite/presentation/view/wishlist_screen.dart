import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/features/favourite/logic/cubit/fav_cubit.dart';
import 'package:freelancer/features/favourite/data/models/wishlist_model.dart';

class WishlistsScreen extends StatefulWidget {
  const WishlistsScreen({super.key});

  @override
  State<WishlistsScreen> createState() => _WishlistsScreenState();
}

class _WishlistsScreenState extends State<WishlistsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FavCubit>().loadWishlists();
  }

  void _showCreateDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Create Wishlist',
          style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Wishlist name',
            filled: true,
            fillColor: const Color(0xFFF5F0EA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<FavCubit>().createWishlist(controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Wishlists',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      BlocBuilder<FavCubit, FavState>(
                        builder: (context, state) {
                          final count = state is FavLoaded
                              ? state.wishlists.length
                              : 0;
                          return Text(
                            '$count list${count == 1 ? '' : 's'} available',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.sub.withOpacity(0.7),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: _showCreateDialog,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.ink,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ── Content ──
            Expanded(
              child: BlocBuilder<FavCubit, FavState>(
                builder: (context, state) {
                  if (state is FavLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is FavLoaded) {
                    if (state.wishlists.isEmpty) {
                      return _EmptyWishlists(onAdd: _showCreateDialog);
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            childAspectRatio: 1.4,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: state.wishlists.length,
                      itemBuilder: (_, i) =>
                          _WishlistCard(wishlist: state.wishlists[i]),
                    );
                  }
                  return _EmptyWishlists(onAdd: _showCreateDialog);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ──────────────────────────────────────────────────────────────
class _EmptyWishlists extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyWishlists({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite_border_rounded,
                size: 56,
                color: AppColors.sub.withOpacity(0.4),
              ),
              const SizedBox(height: 16),
              const Text(
                'No wishlists yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Save your favorite places to visit later',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.sub.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Create a wishlist',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Wishlist Card ─────────────────────────────────────────────────────────────
class _WishlistCard extends StatelessWidget {
  final WishlistModel wishlist;
  const _WishlistCard({required this.wishlist});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0EBE3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border_rounded,
                color: AppColors.sub.withOpacity(0.5),
                size: 24,
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wishlist.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const Text(
                  '0 saved listings',
                  style: TextStyle(fontSize: 13, color: AppColors.sub),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
