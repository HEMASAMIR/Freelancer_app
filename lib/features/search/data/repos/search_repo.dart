import 'package:dartz/dartz.dart';
import '../search_model/listing_model.dart';
import '../search_model/search_params_model.dart'; // تأكد من استيراد الموديل

abstract class SearchRepository {
  Future<Either<String, List<ListingModel>>> searchListings(
    SearchParamsModel params,
  );
  Future<Either<String, ListingModel>> getListingDetails(String id);
}
