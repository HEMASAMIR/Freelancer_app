import 'package:equatable/equatable.dart';
import '../../data/models/wishlist_models.dart';

abstract class WishlistsState extends Equatable {
  const WishlistsState();

  @override
  List<Object?> get props => [];
}

class WishlistsInitial extends WishlistsState {}

class WishlistsLoading extends WishlistsState {}

class WishlistsLoaded extends WishlistsState {
  final List<WishlistModel> wishlists;
  const WishlistsLoaded(this.wishlists);

  @override
  List<Object?> get props => [wishlists];
}

class WishlistsSuccess extends WishlistsState {
  final String message;
  const WishlistsSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class WishlistsError extends WishlistsState {
  final String message;
  const WishlistsError(this.message);

  @override
  List<Object?> get props => [message];
}
