import 'package:dartz/dartz.dart';
import '../search_model/listing_model.dart';
import '../search_model/search_params_model.dart';

abstract class SearchRepository {
  Future<Either<String, List<ListingModel>>> searchListings(
    SearchParamsModel params,
  );
  Future<Either<String, ListingModel>> getListingDetails(String id);
}
