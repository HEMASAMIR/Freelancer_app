import 'package:dartz/dartz.dart';
import '../../../../features/search/data/search_model/listing_model.dart';

abstract class HostListingsRepository {
  Future<Either<String, List<ListingModel>>> getHostListings(String hostId);
  Future<Either<String, void>> createListing(ListingModel listing);
  Future<Either<String, void>> deleteListing(String listingId);
}
