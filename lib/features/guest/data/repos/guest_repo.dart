import 'package:dartz/dartz.dart';
import '../models/guest_models.dart';

abstract class GuestRepository {
  // 1. Get My Trips (Bookings for this user)
  Future<Either<String, List<GuestTripModel>>> getMyTrips(String userId);

  // 2. Get My Wishlists
  Future<Either<String, List<GuestWishlistModel>>> getMyWishlists(String userId);
}
