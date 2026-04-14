import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'package:freelancer/core/error/errors.dart';
import 'package:freelancer/features/favourite/data/fav_repos/fav_repo.dart';
import 'package:freelancer/features/favourite/data/models/wishlist_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



class FavoriteRepositoryImpl implements FavoriteRepository {
  final SupabaseClient _supabase;
  final SharedPreferences _prefs;

  FavoriteRepositoryImpl(this._supabase, this._prefs);

  static const String _favKey = 'my_favs';

  @override
  Future<List<String>> getFavorites() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return _prefs.getStringList(_favKey) ?? [];
    }

    try {
      // نجيب كل الـ items من كل الـ wishlists بتاعة اليوزر
      final wishlists = await _supabase
          .from('wishlists')
          .select('id')
          .eq('user_id', user.id);

      if (wishlists.isEmpty) return [];

      final List<String> wishlistIds =
          wishlists.map((e) => e['id'].toString()).toList();

      final items = await _supabase
          .from('wishlist_items')
          .select('listing_id')
          .inFilter('wishlist_id', wishlistIds);

      final List<String> ids =
          items.map((e) => e['listing_id'].toString()).toList().toSet().toList(); // Unique IDs

      await _prefs.setStringList(_favKey, ids);
      return ids;
    } catch (e) {
      debugPrint("Error fetching all favorites: $e");
      return _prefs.getStringList(_favKey) ?? [];
    }
  }

  @override
  Future<List<WishlistModel>> getWishlists() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final data = await _supabase
          .from('wishlists')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return data.map((e) => WishlistModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error fetching wishlists: $e");
      return [];
    }
  }

  @override
  Future<List<String>> getWishlistItems(String wishlistId) async {
    try {
      final data = await _supabase
          .from('wishlist_items')
          .select('listing_id')
          .eq('wishlist_id', wishlistId);

      return data.map((e) => e['listing_id'].toString()).toList();
    } catch (e) {
      debugPrint("Error fetching wishlist items: $e");
      return [];
    }
  }

  @override
  Future<Either<Failure, WishlistModel>> createWishlist(String name) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return const Left(ServerFailure());

    try {
      final data = await _supabase
          .from('wishlists')
          .insert({'user_id': user.id, 'name': name})
          .select()
          .single();

      return Right(WishlistModel.fromJson(data));
    } catch (e) {
      debugPrint("Error creating wishlist: $e");
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> toggle(String listingId, {String? wishlistId}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return const Left(ServerFailure());

    try {
      String targetWishlistId;
      
      if (wishlistId != null) {
        targetWishlistId = wishlistId;
      } else {
        // لو مبعتناش ID، نستخدم الافتراضية أو ننشئها
        final wishlists = await _supabase.from('wishlists').select().eq(
          'user_id',
          user.id,
        );

        if (wishlists.isEmpty) {
          final newWishlist = await _supabase
              .from('wishlists')
              .insert({'user_id': user.id, 'name': 'My Favorites'})
              .select()
              .single();
          targetWishlistId = newWishlist['id'];
        } else {
          targetWishlistId = wishlists.first['id'];
        }
      }

      final existing =
          await _supabase
              .from('wishlist_items')
              .select()
              .eq('wishlist_id', targetWishlistId)
              .eq('listing_id', listingId)
              .maybeSingle();

      if (existing != null) {
        await _supabase
            .from('wishlist_items')
            .delete()
            .eq('wishlist_id', targetWishlistId)
            .eq('listing_id', listingId);
      } else {
        await _supabase.from('wishlist_items').insert({
          'wishlist_id': targetWishlistId,
          'listing_id': listingId,
        });
      }

      await getFavorites(); // نحدث الكاش الشامل
      return const Right(unit);
    } catch (e) {
      debugPrint("Error toggling favorite: $e");
      return const Left(ServerFailure());
    }
  }
}