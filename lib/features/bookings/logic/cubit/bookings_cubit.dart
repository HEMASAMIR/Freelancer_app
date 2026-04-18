import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repos/bookings_repo.dart';
import 'bookings_state.dart';

class BookingsCubit extends Cubit<BookingsState> {
  final BookingsRepository repository;

  BookingsCubit(this.repository) : super(BookingsInitial());

  Future<bool> checkAvailability(
    String listingId,
    String checkIn,
    String checkOut,
  ) async {
    final result = await repository.checkAvailability(
      listingId: listingId,
      checkIn: checkIn,
      checkOut: checkOut,
    );
    return result.fold((l) => false, (r) => r);
  }

  Future<Map<String, dynamic>?> getCommissionRate() async {
    final result = await repository.getCurrentCommissionRate();
    return result.fold((l) => null, (r) => r);
  }

  Future<bool> createBooking({
    required String listingId,
    required String userId,
    required String checkIn,
    required String checkOut,
    required int guests,
    required num subtotal,
    String? commissionRateId,
  }) async {
    emit(BookingsLoading());
    final result = await repository.createBooking(
      listingId: listingId,
      userId: userId,
      checkIn: checkIn,
      checkOut: checkOut,
      guests: guests,
      subtotal: subtotal,
      commissionRateId: commissionRateId,
    );
    return result.fold(
      (error) {
        emit(BookingsError(error));
        return false;
      },
      (booking) {
        emit(BookingsSuccess(booking));
        return true;
      },
    );
  }

  Future<void> cancelBooking(String bookingId, String userId) async {
    emit(BookingsLoading());
    final result = await repository.cancelBooking(
      bookingId: bookingId,
      userId: userId,
    );

    result.fold(
      (error) => emit(BookingsError(error)),
      (_) => emit(BookingsCancelled()),
    );
  }

  Future<void> confirmBooking(String bookingId, String hostId) async {
    emit(BookingsLoading());
    final result = await repository.confirmBooking(
      bookingId: bookingId,
      hostId: hostId,
    );
    result.fold(
      (error) => emit(BookingsError(error)),
      (_) => emit(BookingsConfirmed()),
    );
  }

  Future<void> getUserBookings({required String userId, String? status}) async {
    emit(BookingsLoading());
    final result = await repository.getUserBookings(
      userId: userId,
      status: status,
    );
    result.fold(
      (error) => emit(BookingsError(error)),
      (bookings) => emit(BookingsListLoaded(bookings)),
    );
  }

  Future<void> getHostBookings({required String hostId, String? status}) async {
    emit(BookingsLoading());
    final result = await repository.getHostBookings(
      hostId: hostId,
      status: status,
    );
    result.fold(
      (error) => emit(BookingsError(error)),
      (bookings) => emit(BookingsListLoaded(bookings)),
    );
  }
}
