import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/features/favourite/logic/cubit/fav_cubit.dart';
import 'package:freelancer/features/favourite/data/models/wishlist_model.dart';
import 'package:freelancer/features/favourite/presentation/view/wishlist_details_screen.dart';
import 'package:freelancer/features/home/presentation/widget/custom_drawer.dart';
import 'package:freelancer/core/utils/widgets/elegant_toast.dart';
import 'package:freelancer/features/auth/logic/cubit/auth_cubit.dart';
import 'package:freelancer/features/auth/logic/cubit/auth_state.dart';
import 'package:freelancer/features/search/data/search_model/listing_model.dart';

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
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                final name = controller.text.trim();
                Navigator.pop(ctx);
                final success = await context.read<FavCubit>().createWishlist(name);
                if (success && context.mounted) {
                  // Get username for a personalized animated toast
                  final authCubit = context.read<AuthCubit>();
                  String userName = 'Guest';
                  if (authCubit.state is AuthSuccess) {
                    userName = (authCubit.state as AuthSuccess).user.userMetadata['full_name'] ?? 'Guest';
                  } else if (authCubit.state is AuthAdminSuccess) {
                    userName = (authCubit.state as AuthAdminSuccess).user.userMetadata['full_name'] ?? 'Admin';
                  }
                  
                  ElegantToast.show(
                    context, 
                    'Congratulations $userName! Wishlist "$name" created successfully. 🎉',
                    icon: Icons.favorite_rounded,
                  );
                }
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
      drawer: const SideDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F0EA),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppColors.ink),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          if (Navigator.of(context).canPop())
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.ink),
              onPressed: () => Navigator.of(context).pop(),
            ),
        ],
        title: const Text(
          'Wishlists',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header subtitle + add button ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BlocBuilder<FavCubit, FavState>(
                    builder: (context, state) {
                      final count = state is FavLoaded
                          ? state.wishlists.length
                          : 0;
                      return Text(
                        '$count list${count == 1 ? '' : 's'} available',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.sub.withValues(alpha: 0.7),
                        ),
                      );
                    },
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
                            childAspectRatio: 1.2,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: state.wishlists.length,
                      itemBuilder: (_, i) {
                        final wishlist = state.wishlists[i];
                        final listings = state.wishlistContent[wishlist.id];
                        return _WishlistCard(
                          wishlist: wishlist,
                          listings: listings,
                        );
                      },
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
                color: AppColors.sub.withValues(alpha: 0.4),
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
                  color: AppColors.sub.withValues(alpha: 0.6),
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
  final List<ListingModel>? listings;

  const _WishlistCard({
    required this.wishlist,
    this.listings,
  });

  @override
  Widget build(BuildContext context) {
    final hasImages = listings != null &&
        listings!.isNotEmpty &&
        listings!.any((l) => l.images?.isNotEmpty ?? false);

    String? coverImageUrl;
    if (hasImages) {
      final firstListingWithImage =
          listings!.firstWhere((l) => l.images?.isNotEmpty ?? false);
      coverImageUrl = firstListingWithImage.images!.first.url;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WishlistDetailsScreen(wishlist: wishlist),
          ),
        );
      },
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: const Color(0xFFF0EBE3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // Cover Image
            if (coverImageUrl != null)
              Positioned.fill(
                child: Image.network(
                  coverImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFF0EBE3),
                    child: Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
              ),

            // Gradient Overlay
            if (coverImageUrl != null)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.65),
                        Colors.black.withOpacity(0.1),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),

            // Center Heart Icon (Only if there is no cover image)
            if (coverImageUrl == null)
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

            // Delete Button
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: coverImageUrl != null
                      ? Colors.black.withOpacity(0.3)
                      : Colors.white.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: coverImageUrl != null ? Colors.white : Colors.redAccent,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        title: const Text('Delete Wishlist',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink)),
                        content: Text(
                            'Are you sure you want to delete "${wishlist.name}"? This action cannot be undone.'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel')),
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<FavCubit>()
                                  .deleteWishlist(wishlist.id);
                              Navigator.pop(ctx);
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryRed),
                            child: const Text('Delete',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            // Bottom texts
            Positioned(
              left: 16,
              bottom: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wishlist.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: coverImageUrl != null ? Colors.white : AppColors.ink,
                      shadows: coverImageUrl != null
                          ? [
                              Shadow(
                                color: Colors.black.withOpacity(0.6),
                                offset: const Offset(0, 1.5),
                                blurRadius: 4,
                              )
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${listings?.length ?? 0} saved listing${(listings?.length ?? 0) == 1 ? '' : 's'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: coverImageUrl != null
                          ? Colors.white.withOpacity(0.85)
                          : AppColors.sub,
                      shadows: coverImageUrl != null
                          ? [
                              Shadow(
                                color: Colors.black.withOpacity(0.6),
                                offset: const Offset(0, 1.5),
                                blurRadius: 4,
                              )
                            ]
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
