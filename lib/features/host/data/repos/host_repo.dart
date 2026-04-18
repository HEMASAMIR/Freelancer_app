import 'package:dartz/dartz.dart';
import '../../../../features/search/data/search_model/listing_model.dart';
import '../models/host_models.dart';

abstract class HostRepository {
  // 1. Get host's listings count/ids
  Future<Either<String, List<String>>> getHostListingsIds(String userId);

  // 2. Get guest's bookings count/ids (for the host to track their guest activity if needed)
  Future<Either<String, List<String>>> getGuestBookingsIds(String userId);

  // 3. Get host listings details
  Future<Either<String, List<ListingModel>>> getHostListingsDetailed(String userId);

  // 4. Get bookings for host's listings
  Future<Either<String, List<HostBookingModel>>> getBookingsForHostListings(String userId);

  // 5. Get/Check specific listing for host
  Future<Either<String, ListingModel>> getListingForHost(String listingId, String userId);

  // 6. Get user balance
  Future<Either<String, double>> getUserBalance(String userId);

  // 7. Get unavailable dates
  Future<Either<String, List<AvailabilityModel>>> getUnavailableDates(String listingId);

  // 8. Get price overrides
  Future<Either<String, List<AvailabilityModel>>> getPriceOverrides(String listingId);

  // 9. Update/Manage availability
  Future<Either<String, void>> updateAvailability(List<Map<String, dynamic>> availabilityData);

  // 10. Get reviews for host's listings
  Future<Either<String, List<HostReviewModel>>> getReviewsForHost(String userId);

  // 11. Update listing settings
  Future<Either<String, void>> updateListingSettings({
    required String listingId,
    required Map<String, dynamic> data,
  });

  // 12. Upsert price adjustment (availability with price_override)
  Future<Either<String, void>> upsertPriceAdjustment({
    required String listingId,
    required String date,
    required double price,
  });
}
