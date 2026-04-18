import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/core/error/errors.dart';
import 'package:freelancer/features/favourite/data/fav_repos/fav_repo.dart';
import 'package:freelancer/features/favourite/data/models/wishlist_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:freelancer/features/search/data/search_model/listing_model.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final SupabaseClient _supabase;
  final SharedPreferences _prefs;

  FavoriteRepositoryImpl(this._supabase, this._prefs);

  static const String _favKey = 'my_favs';

  String? _extractUserIdFromAccessToken() {
    final token = _prefs.getString('supabase_access_token');
    if (token == null || token.isEmpty) return null;

    try {
      final parts = token.split('.');
      if (parts.length < 2) return null;

      final normalized = base64Url.normalize(parts[1]);
      final payload = utf8.decode(base64Url.decode(normalized));
      final decoded = jsonDecode(payload);

      if (decoded is Map<String, dynamic>) {
        return decoded['sub']?.toString();
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  String? _currentUserId() {
    final sdkUser = _supabase.auth.currentUser;
    if (sdkUser != null) return sdkUser.id;

    final rawUser = _prefs.getString('supabase_user');
    if (rawUser == null || rawUser.isEmpty) return null;

    try {
      final decoded = jsonDecode(rawUser);
      if (decoded is Map<String, dynamic>) {
        return decoded['id']?.toString();
      }
    } catch (_) {
      // Fallback to JWT if cached user JSON is malformed.
      return _extractUserIdFromAccessToken();
    }

    // Fallback for sessions where only token is stored.
    return _extractUserIdFromAccessToken();
  }

  Dio _restDio() {
    final token = _prefs.getString('supabase_access_token');
    return Dio(
      BaseOptions(
        baseUrl: SupabaseKeys.restBaseUrl,
        headers: {
          'apikey': SupabaseKeys.supabaseAnonKey,
          'Content-Type': 'application/json',
          'Prefer': 'return=representation',
          'Authorization': token != null && token.isNotEmpty
              ? 'Bearer $token'
              : 'Bearer ${SupabaseKeys.supabaseAnonKey}',
        },
      ),
    );
  }

  String _extractErrorMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        return data['message']?.toString() ??
            data['error_description']?.toString() ??
            data['msg']?.toString() ??
            error.message ??
            'Network error';
      }
      if (data != null) {
        return data.toString();
      }
      return error.message ?? 'Network error';
    }

    // Postgrest exceptions include useful server-side details.
    final text = error.toString();
    if (text.isNotEmpty) return text;
    return 'Server error, please try again.';
  }

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

      final List<String> wishlistIds = wishlists
          .map((e) => e['id'].toString())
          .toList();

      final items = await _supabase
          .from('wishlist_items')
          .select('listing_id')
          .inFilter('wishlist_id', wishlistIds);

      final List<String> ids = items
          .map((e) => e['listing_id'].toString())
          .toList()
          .toSet()
          .toList(); // Unique IDs

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
    final userId = _currentUserId();
    if (user == null && userId == null) return [];

    try {
      if (user != null) {
        final data = await _supabase
            .from('wishlists')
            .select()
            .eq('user_id', user.id)
            .order('created_at', ascending: false);
        return data.map((e) => WishlistModel.fromJson(e)).toList();
      }

      final response = await _restDio().get(
        'wishlists',
        queryParameters: {
          'user_id': 'eq.$userId',
          'select': '*',
          'order': 'created_at.desc',
        },
      );

      final rows = response.data;
      if (rows is List) {
        return rows
            .whereType<Map<String, dynamic>>()
            .map(WishlistModel.fromJson)
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error fetching wishlists: $e");
      return [];
    }
  }

  @override
  Future<List<String>> getWishlistItems(String wishlistId) async {
    try {
      if (_supabase.auth.currentUser != null) {
        final data = await _supabase
            .from('wishlist_items')
            .select('listing_id')
            .eq('wishlist_id', wishlistId);
        return data.map((e) => e['listing_id'].toString()).toList();
      }

      final response = await _restDio().get(
        'wishlist_items',
        queryParameters: {
          'wishlist_id': 'eq.$wishlistId',
          'select': 'listing_id',
        },
      );

      final rows = response.data;
      if (rows is List) {
        return rows
            .whereType<Map<String, dynamic>>()
            .map((e) => e['listing_id'].toString())
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error fetching wishlist items: $e");
      return [];
    }
  }

  @override
  Future<Either<Failure, WishlistModel>> createWishlist(String name) async {
    final user = _supabase.auth.currentUser;
    final userId = _currentUserId();
    if (user == null && userId == null) {
      return const Left(
        ServerFailure('Session not found. Please sign in again.'),
      );
    }

    try {
      if (user != null) {
        final data = await _supabase
            .from('wishlists')
            .insert({'user_id': user.id, 'name': name})
            .select()
            .single();
        return Right(WishlistModel.fromJson(data));
      }

      final token = _prefs.getString('supabase_access_token');
      if (token == null || token.isEmpty) {
        return const Left(
          ServerFailure('Session expired. Please sign in again.'),
        );
      }

      final response = await _restDio().post(
        'wishlists',
        data: {'user_id': userId, 'name': name},
      );

      final rows = response.data;
      if (rows is List && rows.isNotEmpty) {
        final first = rows.first;
        if (first is Map<String, dynamic>) {
          return Right(WishlistModel.fromJson(first));
        }
      }

      return const Left(ServerFailure());
    } catch (e) {
      debugPrint("Error creating wishlist: $e");
      return Left(ServerFailure(_extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteWishlist(String wishlistId) async {
    final user = _supabase.auth.currentUser;
    final userId = _currentUserId();
    if (user == null && userId == null) return const Left(ServerFailure());

    try {
      if (user != null) {
        await _supabase
            .from('wishlists')
            .delete()
            .eq('id', wishlistId)
            .eq('user_id', user.id);
      } else {
        await _restDio().delete(
          'wishlists',
          queryParameters: {'id': 'eq.$wishlistId', 'user_id': 'eq.$userId'},
        );
      }
      return const Right(unit);
    } catch (e) {
      debugPrint("Error deleting wishlist: $e");
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> toggle(
    String listingId, {
    String? wishlistId,
  }) async {
    final user = _supabase.auth.currentUser;
    final userId = _currentUserId();
    if (user == null && userId == null) return const Left(ServerFailure());

    try {
      String targetWishlistId;

      if (user != null) {
        if (wishlistId != null) {
          targetWishlistId = wishlistId;
        } else {
          // لو مبعتناش ID، نستخدم الافتراضية أو ننشئها
          final wishlists = await _supabase
              .from('wishlists')
              .select()
              .eq('user_id', user.id);

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

        final existing = await _supabase
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
      } else {
        final dio = _restDio();
        if (wishlistId != null) {
          targetWishlistId = wishlistId;
        } else {
          final wishlistsResponse = await dio.get(
            'wishlists',
            queryParameters: {
              'user_id': 'eq.$userId',
              'select': 'id',
              'order': 'created_at.desc',
              'limit': 1,
            },
          );

          final rows = wishlistsResponse.data;
          if (rows is List && rows.isNotEmpty) {
            final first = rows.first;
            if (first is Map<String, dynamic> && first['id'] != null) {
              targetWishlistId = first['id'].toString();
            } else {
              return const Left(ServerFailure());
            }
          } else {
            final createdResponse = await dio.post(
              'wishlists',
              data: {'user_id': userId, 'name': 'My Favorites'},
            );
            final createdRows = createdResponse.data;
            if (createdRows is List && createdRows.isNotEmpty) {
              final first = createdRows.first;
              if (first is Map<String, dynamic> && first['id'] != null) {
                targetWishlistId = first['id'].toString();
              } else {
                return const Left(ServerFailure());
              }
            } else {
              return const Left(ServerFailure());
            }
          }
        }

        final existingResponse = await dio.get(
          'wishlist_items',
          queryParameters: {
            'wishlist_id': 'eq.$targetWishlistId',
            'listing_id': 'eq.$listingId',
            'select': '*',
            'limit': 1,
          },
        );

        final existingRows = existingResponse.data;
        final exists = existingRows is List && existingRows.isNotEmpty;

        if (exists) {
          await dio.delete(
            'wishlist_items',
            queryParameters: {
              'wishlist_id': 'eq.$targetWishlistId',
              'listing_id': 'eq.$listingId',
            },
          );
        } else {
          await dio.post(
            'wishlist_items',
            data: {'wishlist_id': targetWishlistId, 'listing_id': listingId},
          );
        }

        final cached = List<String>.from(
          _prefs.getStringList(_favKey) ?? const [],
        );
        if (exists) {
          cached.removeWhere((id) => id == listingId);
        } else if (!cached.contains(listingId)) {
          cached.add(listingId);
        }
        await _prefs.setStringList(_favKey, cached);
      }
      return const Right(unit);
    } catch (e) {
      debugPrint("Error toggling favorite: $e");
      return const Left(ServerFailure());
    }
  }

  @override
  Future<List<ListingModel>> getListingsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    try {
      final response = await _supabase
          .from('listings')
          .select('*, listing_images(*)')
          .inFilter('id', ids);

      return (response as List)
          .map((json) => ListingModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint("Error fetching listings by ids: $e");
      return [];
    }
  }
}
