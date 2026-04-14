import 'package:equatable/equatable.dart';
import '../../data/models/guest_models.dart';

abstract class GuestState extends Equatable {
  const GuestState();

  @override
  List<Object?> get props => [];
}

class GuestInitial extends GuestState {}

class GuestLoading extends GuestState {}

class GuestTripsLoaded extends GuestState {
  final List<GuestTripModel> trips;
  const GuestTripsLoaded(this.trips);

  @override
  List<Object?> get props => [trips];
}

class GuestWishlistsLoaded extends GuestState {
  final List<GuestWishlistModel> wishlists;
  const GuestWishlistsLoaded(this.wishlists);

  @override
  List<Object?> get props => [wishlists];
}

class GuestError extends GuestState {
  final String message;
  const GuestError(this.message);

  @override
  List<Object?> get props => [message];
}
