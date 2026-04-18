import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:freelancer/features/favourite/data/fav_repos/fav_repo.dart';
import 'package:freelancer/features/favourite/data/models/wishlist_model.dart';
import 'package:freelancer/features/search/data/search_model/listing_model.dart';

part 'fav_state.dart';

class FavCubit extends Cubit<FavState> {
  final FavoriteRepository _repository;

  final List<ListingModel> _cachedFavModels = [];

  FavCubit(this._repository) : super(FavInitial());

  // 1. تحميل المفضلات (العامة للمقارنة السريعة)
  Future<void> loadFavorites() async {
    emit(FavLoading());
    try {
      final favoriteIds = await _repository.getFavorites();

      // Check if we need to hydrate missing listings (e.g. after app restart)
      final List<String> missingIds = favoriteIds
          .where((id) => !_cachedFavModels.any((m) => m.id.toString() == id))
          .toList();

      if (missingIds.isNotEmpty) {
        final hydratedListings = await _repository.getListingsByIds(missingIds);
        for (var l in hydratedListings) {
          if (!_cachedFavModels.any((m) => m.id == l.id)) {
            _cachedFavModels.add(l);
          }
        }
      }

      final favoritesToShow = _cachedFavModels
          .where((element) => favoriteIds.contains(element.id.toString()))
          .toList();

      // تحميل الـ Wishlists بالمرة
      final wishlists = await _repository.getWishlists();

      emit(FavLoaded(
        favorites: favoritesToShow,
        favoriteIds: favoriteIds,
        wishlists: wishlists,
      ));
    } catch (e) {
      debugPrint("Error loading favorites: $e");
      emit(const FavError("Failed to load favorites"));
    }
  }

  // تحميل محتويات الـ Wishlist المحددة
  Future<void> loadWishlistItems(String wishlistId) async {
    try {
      final itemIds = await _repository.getWishlistItems(wishlistId);

      // التأكد من تحميل بيانات العقارات (Hydration)
      final List<String> missingIds = itemIds
          .where((id) => !_cachedFavModels.any((m) => m.id.toString() == id))
          .toList();

      if (missingIds.isNotEmpty) {
        final hydratedListings = await _repository.getListingsByIds(missingIds);
        for (var l in hydratedListings) {
          if (!_cachedFavModels.any((m) => m.id == l.id)) {
            _cachedFavModels.add(l);
          }
        }
      }

      final itemsToShow = _cachedFavModels
          .where((element) => itemIds.contains(element.id.toString()))
          .toList();

      if (state is FavLoaded) {
        final currentState = state as FavLoaded;
        final newContent = Map<String, List<ListingModel>>.from(currentState.wishlistContent);
        newContent[wishlistId] = itemsToShow;
        emit(currentState.copyWith(wishlistContent: newContent));
      }
    } catch (e) {
      debugPrint("Error loading wishlist items: $e");
    }
  }

  // تحميل الـ Wishlists فقط
  Future<void> loadWishlists() async {
    // نحتفظ بالحالة السابقة إذا كانت FavLoaded عشان مانكسرش الـ UI
    final previousState = state;
    emit(FavLoading());
    try {
      final wishlists = await _repository.getWishlists();
      if (previousState is FavLoaded) {
        emit(previousState.copyWith(wishlists: wishlists));
      } else {
        emit(FavLoaded(favorites: const [], favoriteIds: const [], wishlists: wishlists));
      }
    } catch (e) {
      debugPrint("loadWishlists error: $e");
      // نرجع للحالة السابقة بدل ما نكسر الـ UI
      if (previousState is FavLoaded) {
        emit(previousState);
      } else {
        emit(FavLoaded(favorites: const [], favoriteIds: const [], wishlists: const []));
      }
    }
  }

  Future<void> createWishlist(String name, {ListingModel? listingToSave}) async {
    final result = await _repository.createWishlist(name);
    result.fold(
      (failure) => emit(const FavError("Failed to create wishlist")),
      (wishlist) async {
        if (listingToSave != null) {
          await toggleFavorite(listingToSave, wishlistId: wishlist.id);
        } else {
          loadWishlists();
        }
      },
    );
  }

  Future<void> deleteWishlist(String wishlistId) async {
    final result = await _repository.deleteWishlist(wishlistId);
    result.fold(
      (failure) => emit(const FavError("Failed to delete wishlist")),
      (_) {
        loadWishlists();
      },
    );
  }

  Future<void> toggleFavorite(ListingModel property, {String? wishlistId}) async {
    final String id = property.id.toString();

    if (!_cachedFavModels.any((element) => element.id == property.id)) {
      _cachedFavModels.add(property);
    }

    final result = await _repository.toggle(id, wishlistId: wishlistId);

    result.fold(
      (failure) => emit(const FavError("Could not update favorites")),
      (_) {
        loadFavorites();
      },
    );
  }

  bool isFavorite(String id) {
    if (state is FavLoaded) {
      return (state as FavLoaded).favoriteIds.contains(id);
    }
    return false;
  }
}
