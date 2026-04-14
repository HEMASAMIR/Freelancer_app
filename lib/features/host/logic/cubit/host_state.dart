import 'package:equatable/equatable.dart';
import '../../data/models/host_models.dart';
import '../../../../features/search/data/search_model/listing_model.dart';

abstract class HostState extends Equatable {
  const HostState();

  @override
  List<Object?> get props => [];
}

class HostInitial extends HostState {}

class HostLoading extends HostState {}

class HostDashboardLoaded extends HostState {
  final List<String> listingIds;
  final List<String> bookingIds;
  final double balance;

  const HostDashboardLoaded({
    required this.listingIds,
    required this.bookingIds,
    required this.balance,
  });

  @override
  List<Object?> get props => [listingIds, bookingIds, balance];
}

class HostListingsLoaded extends HostState {
  final List<ListingModel> listings;
  const HostListingsLoaded(this.listings);

  @override
  List<Object?> get props => [listings];
}

class HostBookingsLoaded extends HostState {
  final List<HostBookingModel> bookings;
  const HostBookingsLoaded(this.bookings);

  @override
  List<Object?> get props => [bookings];
}

class HostAvailabilityLoaded extends HostState {
  final List<AvailabilityModel> unavailableDates;
  final List<AvailabilityModel> priceOverrides;

  const HostAvailabilityLoaded({
    required this.unavailableDates,
    required this.priceOverrides,
  });

  @override
  List<Object?> get props => [unavailableDates, priceOverrides];
}

class HostReviewsLoaded extends HostState {
  final List<HostReviewModel> reviews;
  const HostReviewsLoaded(this.reviews);

  @override
  List<Object?> get props => [reviews];
}

class HostSuccess extends HostState {
  final String message;
  const HostSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class HostError extends HostState {
  final String message;
  const HostError(this.message);

  @override
  List<Object?> get props => [message];
}
