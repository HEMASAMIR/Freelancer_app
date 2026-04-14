import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:freelancer/core/constant/constant.dart';
import '../../../../features/search/data/search_model/listing_model.dart';
import 'host_listings_repo.dart';

class HostListingsRepositoryImpl implements HostListingsRepository {
  final Dio dio;

  HostListingsRepositoryImpl({required this.dio});

  @override
  Future<Either<String, List<ListingModel>>> getHostListings(String hostId) async {
    try {
      final response = await dio.get(
        SupabaseKeys.listingsRest,
        queryParameters: {
          'user_id': 'eq.$hostId',
          'select': 'id,title,location,price_per_night,is_published,listing_code,listing_images(url)',
          'order': 'created_at.desc',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List data = response.data;
        return Right(data.map((e) => ListingModel.fromJson(e)).toList());
      }
      return const Left("فشل في جلب عقاراتك.");
    } on DioException catch (e) {
      return Left(e.message ?? "حدث خطأ في الشبكة");
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> createListing(ListingModel listing) async {
    try {
      final response = await dio.post(
        SupabaseKeys.listingsRest,
        data: listing.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return const Right(null);
      }
      return const Left("فشل في إضافة العقار.");
    } on DioException catch (e) {
      return Left(e.message ?? "حدث خطأ في الشبكة");
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> deleteListing(String listingId) async {
    try {
      final response = await dio.delete(
        SupabaseKeys.listingsRest,
        queryParameters: {'id': 'eq.$listingId'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Right(null);
      }
      return const Left("فشل في حذف العقار.");
    } on DioException catch (e) {
      return Left(e.message ?? "حدث خطأ في الشبكة");
    } catch (e) {
      return Left(e.toString());
    }
  }
}
