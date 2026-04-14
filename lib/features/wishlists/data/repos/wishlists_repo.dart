import 'package:dartz/dartz.dart';
import '../models/wishlist_models.dart';

abstract class WishlistsRepository {
  // 1. List My Wishlists
  Future<Either<String, List<WishlistModel>>> getWishlists(String userId);

  // 2. Create Wishlist
  Future<Either<String, WishlistModel>> createWishlist(String userId, String name);

  // 3. Add Listing to Wishlist
  Future<Either<String, void>> addToListingWishlist(String wishlistId, String listingId);

  // 4. Remove Listing from Wishlist
  Future<Either<String, void>> removeFromWishlist(String wishlistId, String listingId);
}
