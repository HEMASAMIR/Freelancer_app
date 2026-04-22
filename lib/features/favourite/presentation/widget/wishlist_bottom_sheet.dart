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
  bool _isSubmitting = false;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<FavCubit>();
    if (cubit.state is! FavLoaded) {
      cubit.loadWishlists();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Padding السفلي عشان الـ TextField ميتغطاش بالكيبورد
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const Divider(),
            SizedBox(height: 10.h),
            Flexible(
              child: BlocBuilder<FavCubit, FavState>(
                builder: (context, state) {
                  if (state is FavLoading) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF710E1F),
                        ),
                      ),
                    );
                  }

                  if (state is FavLoaded) {
                    if (state.wishlists.isEmpty && !_isCreating) {
                      return _buildNoWishlists();
                    }

                    // تحديد أقصى ارتفاع للـ list عشان متغطيش الشاشة كلها لو العدد ضخم
                    return ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.5,
                      ),
                      child: _isCreating
                          ? _buildCreateForm()
                          : _buildWishlistList(state),
                    );
                  }

                  // في حالة الخطأ أو البداية
                  return _buildNoWishlists();
                },
              ),
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
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
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _buildWishlistList(FavLoaded state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCreateButton(),
        const Divider(),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: state.wishlists.length,
            itemBuilder: (context, index) {
              return _buildWishlistItem(
                state.wishlists[index],
                state.favoriteIds,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNoWishlists() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Choose a wishlist to save\n\"${widget.listing.title}\"",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
        ),
        SizedBox(height: 20.h),
        Icon(
          Icons.bookmark_border_rounded,
          size: 50.sp,
          color: Colors.grey.shade300,
        ),
        SizedBox(height: 20.h),
        _buildCreateButton(),
      ],
    );
  }

  Widget _buildWishlistItem(WishlistModel wishlist, List<String> favoriteIds) {
    final isSaved = favoriteIds.contains(widget.listing.id.toString());

    return Dismissible(
      key: Key('wishlist_${wishlist.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => _showDeleteConfirmDialog(wishlist),
      onDismissed: (_) {
        context.read<FavCubit>().deleteWishlist(wishlist.id);
        _showSnackBar('${wishlist.name} deleted', isError: true);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        margin: EdgeInsets.symmetric(vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w),
        onTap: _isSubmitting ? null : () => _handleToggleFavorite(wishlist),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSaved ? Colors.red.shade50 : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isSaved ? Icons.favorite : Icons.favorite_border,
            color: isSaved ? Colors.red : Colors.grey,
          ),
        ),
        title: Text(
          wishlist.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          isSaved ? '✓ Saved' : 'Tap to save',
          style: TextStyle(
            fontSize: 10,
            color: isSaved ? Colors.green.shade700 : Colors.grey,
          ),
        ),
        trailing: Icon(
          Icons.swipe_left_outlined,
          size: 14.sp,
          color: Colors.grey.shade300,
        ),
      ),
    );
  }

  Future<void> _handleToggleFavorite(WishlistModel wishlist) async {
    setState(() => _isSubmitting = true);
    final success = await context.read<FavCubit>().toggleFavorite(
      widget.listing,
      wishlistId: wishlist.id,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      final nowSaved = (context.read<FavCubit>().state as FavLoaded).favoriteIds
          .contains(widget.listing.id.toString());

      _showSuccessToast(
        context,
        nowSaved ? 'Saved to ${wishlist.name}' : 'Removed',
      );
      if (nowSaved) Navigator.pop(context);
    } else {
      _showErrorToast(_extractErrorMessage());
    }
  }

  Widget _buildCreateButton() {
    return InkWell(
      onTap: () => setState(() => _isCreating = true),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            const Icon(Icons.add_box_outlined, color: Colors.black),
            SizedBox(width: 10.w),
            const Text(
              "Create new wishlist",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "NAME YOUR WISHLIST",
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
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
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _createAndSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF710E1F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text("Create and save"),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _createAndSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isSubmitting = true);
    final success = await context.read<FavCubit>().createWishlist(
      name,
      listingToSave: widget.listing,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      _showSuccessToast(context, 'Saved to $name');
      Navigator.pop(context);
    } else {
      _showErrorToast(_extractErrorMessage());
    }
  }

  Future<bool?> _showDeleteConfirmDialog(WishlistModel wishlist) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Wishlist'),
        content: Text('Delete "${wishlist.name}"? This can\'t be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _extractErrorMessage() {
    final state = context.read<FavCubit>().state;
    if (state is FavError) return state.message;
    return 'Action failed. Please try again.';
  }

  void _showErrorToast(String message) {
    _showSnackBar(message, isError: true);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Colors.red.shade700
            : const Color(0xFF710E1F),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.favorite, color: Colors.white, size: 20),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
              ),
            ),
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
