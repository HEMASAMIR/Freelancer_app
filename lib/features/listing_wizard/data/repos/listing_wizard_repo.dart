import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../features/search/data/search_model/listing_model.dart';
import '../models/wizard_models.dart';

abstract class ListingWizardRepository {
  // 1. Fetch Property Types
  Future<Either<String, List<PropertyTypeModel>>> getPropertyTypes();
  
  // 2. Fetch Lifestyle Categories
  Future<Either<String, List<LifestyleCategoryModel>>> getLifestyleCategories();
  
  // 3. Fetch Listing Conditions
  Future<Either<String, List<ListingConditionModel>>> getListingConditions();
  
  // 4a. Location: Get Countries
  Future<Either<String, List<CountryModel>>> getCountries();
  
  // 4b. Location: Get States
  Future<Either<String, List<StateModel>>> getStates({required String countryId});
  
  // 4c. Location: Get Cities
  Future<Either<String, List<CityModel>>> getCities({required String stateId});
  
  // 5. Upload Listing Photo
  Future<Either<String, String>> uploadListingPhoto({required String userId, required File imageFile});
  
  // 6. Create Primary Listing
  Future<Either<String, ListingModel>> createPrimaryListing(Map<String, dynamic> listingData);
  
  // 7. Bulk Link Images
  Future<Either<String, void>> bulkLinkImages(List<Map<String, dynamic>> imagesData);
  
  // 8. Bulk Link Lifestyle Tags
  Future<Either<String, void>> bulkLinkLifestyleTags(List<Map<String, dynamic>> tagsData);
  
  // 9. Bulk Link Conditions
  Future<Either<String, void>> bulkLinkConditions(List<Map<String, dynamic>> conditionsData);
}
