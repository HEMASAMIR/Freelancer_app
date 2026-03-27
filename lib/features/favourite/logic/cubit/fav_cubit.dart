import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:freelancer/features/favourite/data/fav_repos/fav_repo.dart';
import 'package:freelancer/features/search/data/search_model/listing_model.dart';

part 'fav_state.dart';

class FavCubit extends Cubit<FavState> {
  final FavoriteRepository _repository;

  final List<ListingModel> _cachedFavModels = [];

  FavCubit(this._repository) : super(FavInitial());

  // 1. تحميل المفضلات
  void loadFavorites() {
    emit(FavLoading());
    try {
      final favoriteIds = _repository.getFavorites();

      final favoritesToShow = _cachedFavModels
          .where((element) => favoriteIds.contains(element.id.toString()))
          .toList();

      emit(FavLoaded(favoritesToShow, favoriteIds));
    } catch (e) {
      emit(const FavError("Failed to load favorites"));
    }
  }

  Future<void> toggleFavorite(ListingModel property) async {
    final String id = property.id.toString();

    if (!_cachedFavModels.any((element) => element.id == property.id)) {
      _cachedFavModels.add(property);
    }

    final result = await _repository.toggle(id);

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
    return _repository.getFavorites().contains(id);
  }
}
