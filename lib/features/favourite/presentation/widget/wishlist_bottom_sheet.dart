import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/features/favourite/logic/cubit/fav_cubit.dart';
import 'package:freelancer/features/favourite/data/models/wishlist_model.dart';
import 'package:freelancer/features/search/data/search_model/listing_model.dart';

class WishlistBottomSheet extends StatefulWidget {
  final ListingModel listing;
  const WishlistBottomSheet({super.key, required this.listing});

  @override
  State<WishlistBottomSheet> createState() => _WishlistBottomSheetState();
}

class _WishlistBottomSheetState extends State<WishlistBottomSheet> {
  bool _isCreating = false;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<FavCubit>().loadWishlists();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
              Text(
                "Save to wishlist",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 40), // Balance the close button
            ],
          ),
          const Divider(),
          SizedBox(height: 10.h),
          BlocBuilder<FavCubit, FavState>(
            builder: (context, state) {
              if (state is FavLoading) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (state is FavLoaded) {
                if (state.wishlists.isEmpty && !_isCreating) {
                  return _buildNoWishlists();
                }

                return Column(
                  children: [
                    if (!_isCreating) ...[
                      ...state.wishlists.map((w) => _buildWishlistItem(w)),
                      const Divider(),
                      _buildCreateButton(),
                    ] else
                      _buildCreateForm(),
                  ],
                );
              }

              // FavInitial أو FavError - نبين الـ empty state بدل SizedBox
              return _buildNoWishlists();
            },
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildNoWishlists() {
    return Column(
      children: [
        Text(
          "Choose a wishlist to save\n\"${widget.listing.title}\"",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
        ),
        SizedBox(height: 30.h),
        Icon(Icons.bookmark_border_rounded, size: 60.sp, color: Colors.grey.shade300),
        SizedBox(height: 30.h),
        Text(
          "You don't have any wishlists yet.",
          style: TextStyle(fontSize: 14.sp),
        ),
        Text(
          "Create one below to save this listing.",
          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
        ),
        SizedBox(height: 20.h),
        _buildCreateButton(),
      ],
    );
  }

  Widget _buildWishlistItem(WishlistModel wishlist) {
    return ListTile(
      onTap: () {
        context.read<FavCubit>().toggleFavorite(
              widget.listing,
              wishlistId: wishlist.id,
            );
        _showSuccessToast(context, 'Saved to ${wishlist.name}');
        Navigator.pop(context);
      },
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.favorite, color: Colors.red),
      ),
      title: Text(wishlist.name),
      subtitle: const Text("SAVED", style: TextStyle(fontSize: 10, color: Colors.grey)),
    );
  }

  Widget _buildCreateButton() {
    return InkWell(
      onTap: () => setState(() => _isCreating = true),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          children: [
            const Icon(Icons.add_box_outlined, color: Colors.black),
            SizedBox(width: 10.w),
            const Text("Create new wishlist", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("NAME YOUR WISHLIST", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        SizedBox(height: 5.h),
        TextField(
          controller: _nameController,
          autofocus: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15),
          ),
        ),
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => setState(() => _isCreating = false),
              child: const Text("Cancel", style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.trim().isNotEmpty) {
                  final name = _nameController.text.trim();
                  context.read<FavCubit>().createWishlist(
                    name,
                    listingToSave: widget.listing,
                  );
                  _showSuccessToast(context, 'Saved to $name');
                  // إغلاق الفورم والـ BottomSheet بعد الإنشاء والحفظ
                  setState(() => _isCreating = false);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF710E1F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Create and save"),
            ),
          ],
        ),
      ],
    );
  }

  void _showSuccessToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.favorite, color: Colors.white, size: 20),
            SizedBox(width: 12.w),
            Expanded(child: Text(message, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp))),
          ],
        ),
        backgroundColor: const Color(0xFF710E1F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.only(bottom: 24.h, left: 24.w, right: 24.w),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
