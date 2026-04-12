import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repos/host_listings_repo.dart';
import '../../search/data/search_model/listing_model.dart';
import 'host_listings_state.dart';

class HostListingsCubit extends Cubit<HostListingsState> {
  final HostListingsRepository _repository;

  HostListingsCubit({required HostListingsRepository repository})
      : _repository = repository,
        super(HostListingsInitial());

  Future<void> getHostListings(String hostId) async {
    emit(HostListingsLoading());
    final result = await _repository.getHostListings(hostId);
    result.fold(
      (error) => emit(HostListingsError(error)),
      (listings) => emit(HostListingsLoaded(listings)),
    );
  }

  Future<void> createListing(ListingModel listing) async {
    emit(HostListingsLoading());
    final result = await _repository.createListing(listing);
    result.fold(
      (error) => emit(HostListingsError(error)),
      (_) {
        emit(HostListingActionSuccess("تم إضافة العقار بنجاح"));
        getHostListings(listing.hostId ?? '');
      },
    );
  }

  Future<void> deleteListing(String listingId, String hostId) async {
    emit(HostListingsLoading());
    final result = await _repository.deleteListing(listingId);
    result.fold(
      (error) => emit(HostListingsError(error)),
      (_) {
        emit(HostListingActionSuccess("تم حذف العقار بنجاح"));
        getHostListings(hostId);
      },
    );
  }
}
