import 'package:dartz/dartz.dart';
import 'package:freelancer/core/error/errors.dart';

import 'package:freelancer/features/favourite/data/models/wishlist_model.dart';
import 'package:freelancer/features/search/data/search_model/listing_model.dart';

abstract class FavoriteRepository {
  Future<List<String>> getFavorites(); // الـ IDs لكل المفضلات
  Future<List<WishlistModel>> getWishlists(); // كل الـ Wishlists
  Future<Either<Failure, WishlistModel>> createWishlist(String name);
  Future<Either<Failure, Unit>> toggle(String listingId, {String? wishlistId});
  Future<List<String>> getWishlistItems(String wishlistId);
  Future<Either<Failure, Unit>> deleteWishlist(String wishlistId);
  Future<List<ListingModel>> getListingsByIds(List<String> ids);
}