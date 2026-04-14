import 'package:dartz/dartz.dart';
import 'package:freelancer/features/guest_bookings/data/models/guest_booking_models.dart';

abstract class GuestBookingsRepository {
  // 1. Check Availability (RPC)
  Future<Either<String, bool>> checkAvailability({
    required String listingId,
    required String checkIn,
    required String checkOut,
  });

  // 2. Get Current Commission Rate (GET)
  Future<Either<String, Map<String, dynamic>>> getCurrentCommissionRate();

  // 3. Create Booking (POST)
  Future<Either<String, GuestBookingDetailedModel>> createBooking(Map<String, dynamic> bookingData);

  // 4. List My Bookings (GET)
  Future<Either<String, List<GuestBookingDetailedModel>>> getMyBookings(String userId);

  // 5. Cancel Booking (PATCH)
  Future<Either<String, void>> cancelBooking(String bookingId, String userId);
}
