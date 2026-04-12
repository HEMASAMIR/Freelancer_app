import 'package:freelancer/features/search/data/search_model/listing_model.dart';

abstract class HostListingsState {}

class HostListingsInitial extends HostListingsState {}

class HostListingsLoading extends HostListingsState {}

class HostListingsLoaded extends HostListingsState {
  final List<ListingModel> listings;
  HostListingsLoaded(this.listings);
}

class HostListingsError extends HostListingsState {
  final String message;
  HostListingsError(this.message);
}

class HostListingActionSuccess extends HostListingsState {
  final String message;
  HostListingActionSuccess(this.message);
}
