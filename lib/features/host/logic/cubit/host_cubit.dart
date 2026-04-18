import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repos/host_repo.dart';
import 'host_state.dart';

class HostCubit extends Cubit<HostState> {
  final HostRepository _repository;

  HostCubit(this._repository) : super(HostInitial());

  // Get Dashboard overview (Counts and Balance)
  Future<void> getHostOverview(String userId) async {
    emit(HostLoading());
    
    try {
      final results = await Future.wait([
        _repository.getHostListingsIds(userId),
        _repository.getGuestBookingsIds(userId),
        _repository.getUserBalance(userId),
      ]);

      final listingsResult = results[0] as Either<String, List<String>>;
      final bookingsResult = results[1] as Either<String, List<String>>;
      final balanceResult = results[2] as Either<String, double>;

      listingsResult.fold(
        (error) => emit(HostError(error)),
        (listingIds) {
          bookingsResult.fold(
            (error) => emit(HostError(error)),
            (bookingIds) {
              balanceResult.fold(
                (error) => emit(HostError(error)),
                (balance) {
                  emit(HostDashboardLoaded(
                    listingIds: listingIds,
                    bookingIds: bookingIds,
                    balance: balance,
                  ));
                },
              );
            },
          );
        },
      );
    } catch (e) {
      emit(HostError(e.toString()));
    }
  }

  // Get Detailed Listings
  Future<void> getHostListings(String userId) async {
    emit(HostLoading());
    final result = await _repository.getHostListingsDetailed(userId);
    result.fold(
      (error) => emit(HostError(error)),
      (listings) => emit(HostListingsLoaded(listings)),
    );
  }

  // Get Bookings for Host's Listings
  Future<void> getHostBookings(String userId) async {
    emit(HostLoading());
    final result = await _repository.getBookingsForHostListings(userId);
    result.fold(
      (error) => emit(HostError(error)),
      (bookings) => emit(HostBookingsLoaded(bookings)),
    );
  }

  // Get Availability (Unavailable dates and Price overrides)
  Future<void> getListingAvailability(String listingId) async {
    emit(HostLoading());
    
    final unavailResult = await _repository.getUnavailableDates(listingId);
    final priceResult = await _repository.getPriceOverrides(listingId);

    unavailResult.fold(
      (error) => emit(HostError(error)),
      (unavail) {
        priceResult.fold(
          (error) => emit(HostError(error)),
          (overrides) {
            emit(HostAvailabilityLoaded(
              unavailableDates: unavail,
              priceOverrides: overrides,
            ));
          },
        );
      },
    );
  }

  // Update Availability
  Future<void> updateAvailability(List<Map<String, dynamic>> availabilityData) async {
    emit(HostLoading());
    final result = await _repository.updateAvailability(availabilityData);
    result.fold(
      (error) => emit(HostError(error)),
      (_) => emit(const HostSuccess("تم تحديث التوافر بنجاح")),
    );
  }

  // Get Reviews
  Future<void> getHostReviews(String userId) async {
    emit(HostLoading());
    final result = await _repository.getReviewsForHost(userId);
    result.fold(
      (error) => emit(HostError(error)),
      (reviews) => emit(HostReviewsLoaded(reviews)),
    );
  }

  // Update listing settings (PATCH)
  Future<void> updateListingSettings({
    required String listingId,
    required Map<String, dynamic> data,
  }) async {
    emit(HostLoading());
    final result = await _repository.updateListingSettings(
      listingId: listingId,
      data: data,
    );
    result.fold(
      (error) => emit(HostError(error)),
      (_) => emit(const HostSuccess('Listing updated successfully!')),
    );
  }

  // Upsert a single price adjustment
  Future<void> upsertPriceAdjustment({
    required String listingId,
    required String date,
    required double price,
  }) async {
    final result = await _repository.upsertPriceAdjustment(
      listingId: listingId,
      date: date,
      price: price,
    );
    result.fold(
      (error) => emit(HostError(error)),
      (_) => emit(const HostSuccess('Price adjustment saved!')),
    );
  }
}
