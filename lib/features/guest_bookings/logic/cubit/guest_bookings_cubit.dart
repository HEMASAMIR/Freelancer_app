import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repos/guest_bookings_repo.dart';
import 'guest_bookings_state.dart';

class GuestBookingsCubit extends Cubit<GuestBookingsState> {
  final GuestBookingsRepository _repository;

  GuestBookingsCubit(this._repository) : super(GuestBookingsInitial());

  // 1. Check Availability
  Future<void> checkAvailability({
    required String listingId,
    required String checkIn,
    required String checkOut,
  }) async {
    emit(GuestBookingsLoading());
    final result = await _repository.checkAvailability(
      listingId: listingId,
      checkIn: checkIn,
      checkOut: checkOut,
    );
    result.fold(
      (error) => emit(GuestBookingsError(error)),
      (isAvailable) => emit(GuestBookingsAvailabilityChecked(isAvailable)),
    );
  }

  // 2. Get Commission Rate
  Future<void> getCurrentCommissionRate() async {
    emit(GuestBookingsLoading());
    final result = await _repository.getCurrentCommissionRate();
    result.fold(
      (error) => emit(GuestBookingsError(error)),
      (data) => emit(GuestBookingsCommissionLoaded(data)),
    );
  }

  // 3. Create Booking
  Future<void> createBooking(Map<String, dynamic> bookingData) async {
    emit(GuestBookingsLoading());
    final result = await _repository.createBooking(bookingData);
    result.fold(
      (error) => emit(GuestBookingsError(error)),
      (booking) => emit(GuestBookingsSuccess("تم تأكيد الحجز بنجاح", booking: booking)),
    );
  }

  // 4. List My Bookings
  Future<void> getMyBookings(String userId) async {
    emit(GuestBookingsLoading());
    final result = await _repository.getMyBookings(userId);
    result.fold(
      (error) => emit(GuestBookingsError(error)),
      (bookings) => emit(GuestBookingsLoaded(bookings)),
    );
  }

  // 5. Cancel Booking
  Future<void> cancelBooking(String bookingId, String userId) async {
    emit(GuestBookingsLoading());
    final result = await _repository.cancelBooking(bookingId, userId);
    result.fold(
      (error) => emit(GuestBookingsError(error)),
      (_) {
        emit(const GuestBookingsSuccess("تم إلغاء الحجز بنجاح"));
        getMyBookings(userId);
      },
    );
  }
}
