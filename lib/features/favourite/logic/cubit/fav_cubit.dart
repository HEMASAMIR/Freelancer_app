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

      final favoritesToShow =
          _cachedFavModels
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
      emit(const FavError("Failed to load favorites"));
    }
  }

  // تحميل الـ Wishlists فقط
  Future<void> loadWishlists() async {
    try {
      final wishlists = await _repository.getWishlists();
      if (state is FavLoaded) {
        final currentState = state as FavLoaded;
        emit(currentState.copyWith(wishlists: wishlists));
      } else {
        emit(FavLoaded(favorites: [], favoriteIds: [], wishlists: wishlists));
      }
    } catch (e) {
      emit(const FavError("Failed to load wishlists"));
    }
  }

  Future<void> createWishlist(String name) async {
    final result = await _repository.createWishlist(name);
    result.fold(
      (failure) => emit(const FavError("Failed to create wishlist")),
      (wishlist) {
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
