import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:freelancer/core/constant/constant.dart';
import '../../../../features/search/data/search_model/listing_model.dart';
import 'package:freelancer/features/listing_wizard/data/models/wizard_models.dart';
import 'package:freelancer/features/listing_wizard/data/repos/listing_wizard_repo.dart';

class ListingWizardRepositoryImpl implements ListingWizardRepository {
  final Dio dio;
  final SupabaseClient supabase;

  ListingWizardRepositoryImpl({required this.dio, required this.supabase});

  @override
  Future<Either<String, List<PropertyTypeModel>>> getPropertyTypes() async {
    return _fetchList(
      endpoint: SupabaseKeys.propertyTypes,
      queryParameters: {'select': '*'},
      mapper: (json) => PropertyTypeModel.fromJson(json),
      errorMessage: 'فشل في جلب أنواع العقارات',
    );
  }

  @override
  Future<Either<String, List<LifestyleCategoryModel>>> getLifestyleCategories() async {
    return _fetchList(
      endpoint: SupabaseKeys.lifestyleCategories,
      queryParameters: {'select': '*', 'order': 'display_order'},
      mapper: (json) => LifestyleCategoryModel.fromJson(json),
      errorMessage: 'فشل في جلب فئات نمط الحياة',
    );
  }

  @override
  Future<Either<String, List<ListingConditionModel>>> getListingConditions() async {
    return _fetchList(
      endpoint: SupabaseKeys.listingConditions,
      queryParameters: {'select': 'id,name,description,translations'},
      mapper: (json) => ListingConditionModel.fromJson(json),
      errorMessage: 'فشل في جلب شروط العقار',
    );
  }

  @override
  Future<Either<String, List<CountryModel>>> getCountries() async {
    return _fetchList(
      endpoint: SupabaseKeys.countries,
      queryParameters: {'select': 'id,name,iso2,emoji,latitude,longitude', 'order': 'name.asc'},
      mapper: (json) => CountryModel.fromJson(json),
      errorMessage: 'فشل في جلب الدول',
    );
  }

  @override
  Future<Either<String, List<StateModel>>> getStates({required String countryIso2}) async {
    return _fetchList(
      endpoint: SupabaseKeys.states,
      queryParameters: {'country_iso2': 'eq.$countryIso2', 'select': '*', 'order': 'name.asc'},
      mapper: (json) => StateModel.fromJson(json),
      errorMessage: 'فشل في جلب المحافظات/الولايات',
    );
  }

  @override
  Future<Either<String, List<CityModel>>> getCities({required String stateIso2}) async {
    return _fetchList(
      endpoint: SupabaseKeys.cities,
      queryParameters: {'state_iso2': 'eq.$stateIso2', 'select': '*', 'order': 'name.asc'},
      mapper: (json) => CityModel.fromJson(json),
      errorMessage: 'فشل في جلب المدن',
    );
  }

  @override
  Future<Either<String, String>> uploadListingPhoto({required String userId, required File imageFile}) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      final path = '$userId/$fileName';
      
      await supabase.storage.from('listings').upload(
        path,
        imageFile,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      final String publicUrl = supabase.storage.from('listings').getPublicUrl(path);
      return Right(publicUrl);
    } on StorageException catch (e) {
      debugPrint("❌ Storage Error uploading listing photo: ${e.message}");
      return Left(e.message);
    } catch (e) {
      debugPrint("❌ Unexpected Error uploading listing photo: $e");
      return Left("خطأ غير متوقع: ${e.toString()}");
    }
  }

  @override
  Future<Either<String, ListingModel>> createPrimaryListing(Map<String, dynamic> listingData) async {
    try {
      final response = await dio.post(
        SupabaseKeys.listingsRest,
        data: listingData,
        queryParameters: {'select': '*'}, // To return the created item
        options: Options(headers: {'Prefer': 'return=representation'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List data = response.data;
        if (data.isNotEmpty) {
          return Right(ListingModel.fromJson(data.first));
        }
      }
      return const Left("فشل في إنشاء العقار الأساسي.");
    } on DioException catch (e) {
      return Left(e.message ?? "حدث خطأ في الشبكة");
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> bulkLinkImages(List<Map<String, dynamic>> imagesData) async {
    return _postBulk(SupabaseKeys.listingImagesRest, imagesData, "فشل في ربط الصور.");
  }

  @override
  Future<Either<String, void>> bulkLinkLifestyleTags(List<Map<String, dynamic>> tagsData) async {
    return _postBulk(SupabaseKeys.listingLifestylesRest, tagsData, "فشل في ربط فئات نمط الحياة.");
  }

  @override
  Future<Either<String, void>> bulkLinkConditions(List<Map<String, dynamic>> conditionsData) async {
    return _postBulk(SupabaseKeys.listingConditionAssignmentsRest, conditionsData, "فشل في ربط الشروط.");
  }

  // Helper method for GET requests that return lists
  Future<Either<String, List<T>>> _fetchList<T>({
    required String endpoint,
    required Map<String, dynamic> queryParameters,
    required T Function(Map<String, dynamic>) mapper,
    required String errorMessage,
  }) async {
    try {
      final response = await dio.get(
        endpoint,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List data = response.data;
        return Right(data.map((e) => mapper(e as Map<String, dynamic>)).toList());
      }
      return Left(errorMessage);
    } on DioException catch (e) {
      final errorData = e.response?.data;
      String? msg;
      String? hint;

      if (errorData is Map) {
        msg = errorData['message']?.toString();
        hint = errorData['hint']?.toString();
      }

      debugPrint("❌ Dio Error fetching $endpoint: ${msg ?? e.message}");
      if (hint != null) debugPrint("💡 Hint: $hint");

      return Left(msg ?? e.message ?? "حدث خطأ في الشبكة");
    } catch (e, stack) {
      debugPrint("❌ CRITICAL Unexpected Error fetching $endpoint: $e");
      debugPrint(stack.toString());
      return Left("خطأ غير متوقع: ${e.toString()}");
    }
  }

  // Helper method for bulk POST inserts
  Future<Either<String, void>> _postBulk(String endpoint, List<Map<String, dynamic>> data, String errorMessage) async {
    try {
      final response = await dio.post(
        endpoint,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return const Right(null);
      }
      return Left(errorMessage);
    } on DioException catch (e) {
      debugPrint("❌ Dio Error posting to $endpoint: ${e.message}");
      return Left(e.message ?? "حدث خطأ في الشبكة");
    } catch (e) {
      debugPrint("❌ Unexpected Error posting to $endpoint: $e");
      return Left("خطأ غير متوقع: ${e.toString()}");
    }
  }

  @override
  Future<Either<String, List<AmenityModel>>> getAmenities() async {
    return _fetchList(
      endpoint: SupabaseKeys.amenitiesRest,
      queryParameters: {'select': 'id,name,icon,category_id', 'order': 'category_id,name'},
      mapper: (json) => AmenityModel.fromJson(json),
      errorMessage: 'فشل في جلب المرافق',
    );
  }

  @override
  Future<Either<String, List<String>>> getListingAmenities(String listingId) async {
    try {
      final res = await dio.get(
        SupabaseKeys.listingAmenitiesRest,
        queryParameters: {
          'select': 'amenity_id',
          'listing_id': 'eq.$listingId',
        },
      );
      if (res.statusCode == 200) {
        final List data = res.data;
        return Right(data.map<String>((e) {
          return e['amenity_id'].toString();
        }).toList());
      }
      return const Right([]);
    } on DioException catch (e) {
      return Left(e.message ?? 'Network error');
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> upsertListingAmenities({
    required String listingId,
    required List<String> amenityIds,
  }) async {
    try {
      // Delete old, then insert new
      await dio.delete(
        SupabaseKeys.listingAmenitiesRest,
        queryParameters: {'listing_id': 'eq.$listingId'},
      );
      if (amenityIds.isEmpty) return const Right(null);
      final payload = amenityIds
          .map((id) => {'listing_id': listingId, 'amenity_id': id})
          .toList();
      final res = await dio.post(SupabaseKeys.listingAmenitiesRest, data: payload);
      if (res.statusCode == 200 || res.statusCode == 201 || res.statusCode == 204) {
        return const Right(null);
      }
      return const Left('فشل في حفظ المرافق');
    } on DioException catch (e) {
      return Left(e.message ?? 'Network error');
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> submitCustomCondition({
    required String listingId,
    required String nameEn,
    required String nameAr,
    String? descEn,
    String? descAr,
  }) async {
    try {
      final res = await dio.post(
        SupabaseKeys.customConditionsRest,
        data: {
          'listing_id': listingId,
          'name': nameEn,
          'name_ar': nameAr,
          'description': descEn,
          'description_ar': descAr,
          'status': 'pending',
        },
      );
      if (res.statusCode == 200 || res.statusCode == 201 || res.statusCode == 204) {
        return const Right(null);
      }
      return const Left('فشل في إرسال الشرط للمراجعة');
    } on DioException catch (e) {
      return Left(e.message ?? 'Network error');
    } catch (e) {
      return Left(e.toString());
    }
  }
}
