import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:freelancer/core/constant/constant.dart';
import '../../../../features/search/data/search_model/listing_model.dart';
import '../models/host_models.dart';
import 'host_repo.dart';

class HostRepositoryImpl implements HostRepository {
  final Dio dio;

  HostRepositoryImpl({required this.dio});

  @override
  Future<Either<String, List<String>>> getHostListingsIds(String userId) async {
    try {
      final response = await dio.get(
        SupabaseKeys.listingsRest,
        queryParameters: {
          'user_id': 'eq.$userId',
          'select': 'id',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List data = response.data;
        return Right(data.map((e) => e['id'].toString()).toList());
      }
      return const Left("فشل في جلب عدد العقارات.");
    } on DioException catch (e) {
      return Left(e.message ?? "حدث خطأ في الشبكة");
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<String>>> getGuestBookingsIds(String userId) async {
    try {
      final response = await dio.get(
        SupabaseKeys.bookingsRest,
        queryParameters: {
          'user_id': 'eq.$userId',
          'select': 'id',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List data = response.data;
        return Right(data.map((e) => e['id'].toString()).toList());
      }
      return const Left("فشل في جلب عدد الحجوزات.");
    } on DioException catch (e) {
      return Left(e.message ?? "حدث خطأ في الشبكة");
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<ListingModel>>> getHostListingsDetailed(String userId) async {
    try {
      final response = await dio.get(
        SupabaseKeys.listingsRest,
        queryParameters: {
          'user_id': 'eq.$userId',
          'select': 'id,title,location,price_per_night,is_published,listing_code,listing_images(url,order)',
          'order': 'created_at.desc',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List data = response.data;
        return Right(data.map((e) => ListingModel.fromJson(e)).toList());
      }
      return const Left("فشل في جلب عقاراتك المفصلة.");
    } on DioException catch (e) {
      return Left(e.message ?? "حدث خطأ في الشبكة");
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<HostBookingModel>>> getBookingsForHostListings(String userId) async {
    try {
      final response = await dio.get(
        SupabaseKeys.bookingsRest,
        queryParameters: {
          'select': '*,listing:listings!inner(id,title,listing_code,user_id),guest:profiles(id,full_name,email)',
          'listing.user_id': 'eq.$userId',
          'order': 'created_at.desc',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List data = response.data;
        return Right(data.map((e) => HostBookingModel.fromJson(e)).toList());
      }
      return const Left("فشل في جلب الحجوزات للهوست.");
    } on DioException catch (e) {
      return Left(e.message ?? "حدث خطأ في الشبكة");
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, ListingModel>> getListingForHost(String listingId, String userId) async {
    try {
      final response = await dio.get(
        SupabaseKeys.listingsRest,
        queryParameters: {
          'id': 'eq.$listingId',
          'user_id': 'eq.$userId',
          'select': '*',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List data = response.data;
        if (data.isNotEmpty) {
          return Right(ListingModel.fromJson(data.first));
        }
        return const Left("لم يتم العثور على هذا العقار.");
      }
      return const Left("فشل في فحص العقار.");
    } on DioException catch (e) {
      return Left(e.message ?? "حدث خطأ في الشبكة");
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, double>> getUserBalance(String userId) async {
    try {
      final response = await dio.post(
        SupabaseKeys.hostBalanceRpc,
        data: {'host_id': userId},
      );

      if (response.statusCode == 200) {
        return Right((response.data as num).toDouble());
      }
      return const Left("فشل في جلب رصيدك.");
    } on DioException catch (e) {
      return Left(e.message ?? "حدث خطأ في الشبكة");
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<AvailabilityModel>>> getUnavailableDates(String listingId) async {
    try {
      final response = await dio.get(
        SupabaseKeys.listingAvailabilityRest,
        queryParameters: {
          'listing_id': 'eq.$listingId',
          'is_available': 'eq.false',
          'select': 'date',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List data = response.data;
        return Right(data.map((e) => AvailabilityModel.fromJson(e)).toList());
      }
      return const Left("فشل في جلب التواريخ غير المتاحة.");
    } on DioException catch (e) {
      return Left(e.message ?? "حدث خطأ في الشبكة");
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<AvailabilityModel>>> getPriceOverrides(String listingId) async {
    try {
      final response = await dio.get(
        SupabaseKeys.listingAvailabilityRest,
        queryParameters: {
          'listing_id': 'eq.$listingId',
          'price_override': 'not.is.null',
          'select': 'date,price_override',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List data = response.data;
        return Right(data.map((e) => AvailabilityModel.fromJson(e)).toList());
      }
      return const Left("فشل في جلب أسعار الاستثناءات.");
    } on DioException catch (e) {
      return Left(e.message ?? "حدث خطأ في الشبكة");
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> updateAvailability(List<Map<String, dynamic>> availabilityData) async {
    try {
      final response = await dio.post(
        SupabaseKeys.listingAvailabilityRest,
        data: availabilityData,
      );

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        return const Right(null);
      }
      return const Left("فشل في تحديث التوافر.");
    } on DioException catch (e) {
      debugPrint("❌ Dio Error updating availability: ${e.message}");
      return Left(e.message ?? "حدث خطأ في الشبكة");
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<HostReviewModel>>> getReviewsForHost(String userId) async {
    try {
      final response = await dio.get(
        SupabaseKeys.reviewsRest,
        queryParameters: {
          'select': '*,listing:listings!inner(title),user:profiles(full_name)',
          'listing.user_id': 'eq.$userId',
          'order': 'created_at.desc',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List data = response.data;
        return Right(data.map((e) => HostReviewModel.fromJson(e)).toList());
      }
      return const Left("فشل في جلب التقييمات.");
    } on DioException catch (e) {
      return Left(e.message ?? "حدث خطأ في الشبكة");
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> updateListingSettings({
    required String listingId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await dio.patch(
        SupabaseKeys.listingsRest,
        queryParameters: {'id': 'eq.$listingId'},
        data: data,
      );
      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 201) {
        return const Right(null);
      }
      return const Left('فشل في تحديث بيانات العقار.');
    } on DioException catch (e) {
      debugPrint('❌ updateListingSettings: ${e.message}');
      return Left(e.message ?? 'حدث خطأ في الشبكة');
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> upsertPriceAdjustment({
    required String listingId,
    required String date,
    required double price,
  }) async {
    try {
      final response = await dio.post(
        '${SupabaseKeys.listingAvailabilityRest}?on_conflict=listing_id,date',
        data: {
          'listing_id': listingId,
          'date': date,
          'price_override': price,
          'is_available': true,
        },
      );
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        return const Right(null);
      }
      return const Left('فشل في حفظ سعر الاستثناء.');
    } on DioException catch (e) {
      return Left(e.message ?? 'حدث خطأ في الشبكة');
    } catch (e) {
      return Left(e.toString());
    }
  }
}
