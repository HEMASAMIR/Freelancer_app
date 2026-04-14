import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/features/wishlists/data/models/wishlist_models.dart';
import 'package:freelancer/features/wishlists/data/repos/wishlists_repo.dart';

class WishlistsRepositoryImpl implements WishlistsRepository {
  final Dio dio;

  WishlistsRepositoryImpl({required this.dio});

  @override
  Future<Either<String, List<WishlistModel>>> getWishlists(String userId) async {
    try {
      final response = await dio.get(
        SupabaseKeys.wishlists,
        queryParameters: {
          'user_id': 'eq.$userId',
          'select': '*',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List data = response.data;
        return Right(data.map((e) => WishlistModel.fromJson(e)).toList());
      }
      return const Left("فشل في جلب المفضلات.");
    } on DioException catch (e) {
      return Left(e.message ?? "حدث خطأ في الشبكة");
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, WishlistModel>> createWishlist(String userId, String name) async {
    try {
      final response = await dio.post(
        SupabaseKeys.wishlists,
        data: {
          'user_id': userId,
          'name': name,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final List data = response.data;
        return Right(WishlistModel.fromJson(data.first));
      }
      return const Left("فشل في إنشاء المفضلة.");
    } on DioException catch (e) {
      return Left(e.message ?? "حدث خطأ في الشبكة");
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> addToListingWishlist(String wishlistId, String listingId) async {
    try {
      final response = await dio.post(
        SupabaseKeys.wishlistItems,
        data: {
          'wishlist_id': wishlistId,
          'listing_id': listingId,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200 || response.statusCode == 204) {
        return const Right(null);
      }
      return const Left("فشل في إضافة العقار للمفضلة.");
    } on DioException catch (e) {
      return Left(e.message ?? "حدث خطأ في الشبكة");
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> removeFromWishlist(String wishlistId, String listingId) async {
    try {
      final response = await dio.delete(
        SupabaseKeys.wishlistItems,
        queryParameters: {
          'wishlist_id': 'eq.$wishlistId',
          'listing_id': 'eq.$listingId',
        },
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        return const Right(null);
      }
      return const Left("فشل في حذف العقار من المفضلة.");
    } on DioException catch (e) {
      return Left(e.message ?? "حدث خطأ في الشبكة");
    } catch (e) {
      return Left(e.toString());
    }
  }
}
