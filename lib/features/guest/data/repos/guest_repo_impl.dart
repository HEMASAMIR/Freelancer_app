import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/features/guest/data/models/guest_models.dart';
import 'package:freelancer/features/guest/data/repos/guest_repo.dart';

class GuestRepositoryImpl implements GuestRepository {
  final Dio dio;

  GuestRepositoryImpl({required this.dio});

  @override
  Future<Either<String, List<GuestTripModel>>> getMyTrips(String userId) async {
    try {
      final response = await dio.get(
        SupabaseKeys.bookingsRest,
        queryParameters: {
          'user_id': 'eq.$userId',
          'select': '*,listing:listings(id,title,location,listing_images(url))',
          'order': 'created_at.desc',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List data = response.data;
        return Right(data.map((e) => GuestTripModel.fromJson(e)).toList());
      }
      return const Left("فشل في جلب رحلاتك.");
    } on DioException catch (e) {
      return Left(e.message ?? "حدث خطأ في الشبكة");
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<GuestWishlistModel>>> getMyWishlists(String userId) async {
    try {
      final response = await dio.get(
        SupabaseKeys.wishlists,
        queryParameters: {
          'user_id': 'eq.$userId',
          'select': '*,wishlist_items(listing:listings(id,title,listing_images(url)))',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List data = response.data;
        return Right(data.map((e) => GuestWishlistModel.fromJson(e)).toList());
      }
      return const Left("فشل في جلب المفضلات.");
    } on DioException catch (e) {
      return Left(e.message ?? "حدث خطأ في الشبكة");
    } catch (e) {
      return Left(e.toString());
    }
  }
}
