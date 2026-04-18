import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repos/host_listings_repo.dart';
import '../../search/data/search_model/listing_model.dart';
import 'host_listings_state.dart';

class HostListingsCubit extends Cubit<HostListingsState> {
  final HostListingsRepository _repository;

  String? _lastHostId;
  String _lastSortOption = 'Newest first';

  HostListingsCubit({required HostListingsRepository repository})
      : _repository = repository,
        super(HostListingsInitial());

  Future<void> getHostListings(String hostId, {String sortOption = 'Newest first'}) async {
    _lastHostId = hostId;
    _lastSortOption = sortOption;
    emit(HostListingsLoading());
    final result = await _repository.getHostListings(hostId, sortOption: sortOption);
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
        if (_lastHostId != null) {
          getHostListings(_lastHostId!, sortOption: _lastSortOption);
        }
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
        if (_lastHostId != null) {
          getHostListings(_lastHostId!, sortOption: _lastSortOption);
        }
      },
    );
  }
}
