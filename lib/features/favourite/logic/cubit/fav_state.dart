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
  final Map<String, List<ListingModel>> wishlistContent;

  const FavLoaded({
    required this.favorites,
    required this.favoriteIds,
    required this.wishlists,
    this.wishlistContent = const {},
  });

  FavLoaded copyWith({
    List<ListingModel>? favorites,
    List<String>? favoriteIds,
    List<WishlistModel>? wishlists,
    Map<String, List<ListingModel>>? wishlistContent,
  }) {
    return FavLoaded(
      favorites: favorites ?? this.favorites,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      wishlists: wishlists ?? this.wishlists,
      wishlistContent: wishlistContent ?? this.wishlistContent,
    );
  }

  @override
  List<Object?> get props => [favorites, favoriteIds, wishlists, wishlistContent];
}

final class FavError extends FavState {
  final String message;
  const FavError(this.message);

  @override
  List<Object?> get props => [message];
}
