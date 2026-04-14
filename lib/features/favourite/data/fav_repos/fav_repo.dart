import 'package:dartz/dartz.dart';
import 'package:freelancer/core/error/errors.dart';

import 'package:freelancer/features/favourite/data/models/wishlist_model.dart';

abstract class FavoriteRepository {
  Future<List<String>> getFavorites(); // الـ IDs لكل المفضلات
  Future<List<WishlistModel>> getWishlists(); // كل الـ Wishlists
  Future<Either<Failure, WishlistModel>> createWishlist(String name);
  Future<Either<Failure, Unit>> toggle(String listingId, {String? wishlistId});
  Future<List<String>> getWishlistItems(String wishlistId);
}