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
  Future<Either<String, List<StateModel>>> getStates({required String countryIso2});
  
  // 4c. Location: Get Cities
  Future<Either<String, List<CityModel>>> getCities({required String stateIso2});
  
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

  // 10. Get all amenities grouped by category
  Future<Either<String, List<AmenityModel>>> getAmenities();

  // 11. Get amenities linked to a specific listing
  Future<Either<String, List<String>>> getListingAmenities(String listingId);

  // 12. Save listing amenities (bulk upsert)
  Future<Either<String, void>> upsertListingAmenities({
    required String listingId,
    required List<String> amenityIds,
  });

  // 13. Submit a custom condition for admin approval
  Future<Either<String, void>> submitCustomCondition({
    required String listingId,
    required String nameEn,
    required String nameAr,
    String? descEn,
    String? descAr,
  });
}
