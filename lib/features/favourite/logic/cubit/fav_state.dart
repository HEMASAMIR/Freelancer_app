part of 'fav_cubit.dart';

sealed class FavState extends Equatable {
  const FavState();

  @override
  List<Object?> get props => [];
}

final class FavInitial extends FavState {}

final class FavLoading extends FavState {}

final class FavLoaded extends FavState {
  final List<ListingModel> favorites;
  final List<String> favoriteIds;
  final List<WishlistModel> wishlists;

  const FavLoaded({
    
    required this.favorites,
    required this.favoriteIds,
    required this.wishlists,
  });

  FavLoaded copyWith({
    List<ListingModel>? favorites,
    List<String>? favoriteIds,
    List<WishlistModel>? wishlists,
  }) {
    return FavLoaded(
      favorites: favorites ?? this.favorites,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      wishlists: wishlists ?? this.wishlists,
    );
  }

  @override
  List<Object?> get props => [favorites, favoriteIds, wishlists];
}

final class FavError extends FavState {
  final String message;
  const FavError(this.message);

  @override
  List<Object?> get props => [message];
}
