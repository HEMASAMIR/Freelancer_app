import 'package:dartz/dartz.dart';
import '../models/booking_model.dart';

abstract class BookingsRepository {
  Future<Either<String, bool>> checkAvailability({
    required String listingId,
    required String checkIn,
    required String checkOut,
  });

  Future<Either<String, Map<String, dynamic>>> getCurrentCommissionRate();

  Future<Either<String, BookingModel>> createBooking({
    required String listingId,
    required String userId,
    required String checkIn,
    required String checkOut,
    required int guests,
    required num subtotal,
    required String commissionRateId,
  });

  Future<Either<String, Unit>> cancelBooking({
    required String bookingId,
    required String userId,
  });

  Future<Either<String, List<BookingModel>>> getHostBookings({
    required String hostId,
    String? status,
  });

  Future<Either<String, List<BookingModel>>> getUserBookings({
    required String userId,
    String? status,
  });
}
