part of 'fav_cubit.dart';

sealed class FavState extends Equatable {
  const FavState();

  @override
  List<Object?> get props => [];
}

final class FavInitial extends FavState {}

final class FavLoading extends FavState {}

final class FavLoaded extends FavState {
  final List<ListingModel> favorites; // القائمة الكاملة للعرض
  final List<String>
  favoriteIds; // الـ IDs فقط عشان التشيك (الـ Getter اللي ناقصك)

  const FavLoaded(this.favorites, this.favoriteIds);

  @override
  List<Object?> get props => [favorites, favoriteIds];
}

final class FavError extends FavState {
  final String message;
  const FavError(this.message);

  @override
  List<Object?> get props => [message];
}
