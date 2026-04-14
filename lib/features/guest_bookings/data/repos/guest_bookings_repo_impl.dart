import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/features/guest_bookings/data/models/guest_booking_models.dart';
import 'package:freelancer/features/guest_bookings/data/repos/guest_bookings_repo.dart';

class GuestBookingsRepositoryImpl implements GuestBookingsRepository {
  final Dio dio;

  GuestBookingsRepositoryImpl({required this.dio});

  @override
  Future<Either<String, bool>> checkAvailability({
    required String listingId,
    required String checkIn,
    required String checkOut,
  }) async {
    try {
      final response = await dio.post(
        SupabaseKeys.checkAvailabilityRpc,
        data: {
          "p_listing_id": listingId,
          "p_check_in": checkIn,
          "p_check_out": checkOut,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(response.data == true);
      }
      return const Left("هذا العقار غير متاح في هذه التواريخ.");
    } on DioException catch (e) {
      return Left(e.message ?? "حدث خطأ في الشبكة");
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Map<String, dynamic>>> getCurrentCommissionRate() async {
    try {
      final response = await dio.get(
        SupabaseKeys.commissionRatesRest,
        queryParameters: {
          'is_active': 'eq.true',
          'select': 'id,guest_rate',
          'limit': '1',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List data = response.data;
        if (data.isNotEmpty) {
          return Right(data.first);
        }
        return const Left("لا توجد عمولة نشطة.");
      }
      return const Left("فشل في جلب نسبة العمولة.");
    } on DioException catch (e) {
      return Left(e.message ?? "حدث خطأ في الشبكة");
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, GuestBookingDetailedModel>> createBooking(Map<String, dynamic> bookingData) async {
    try {
      final response = await dio.post(
        SupabaseKeys.bookingsRest,
        data: bookingData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final List data = response.data;
        return Right(GuestBookingDetailedModel.fromJson(data.first));
      }
      return const Left("فشل في عمل الحجز.");
    } on DioException catch (e) {
      return Left(e.message ?? "حدث خطأ في الشبكة");
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<GuestBookingDetailedModel>>> getMyBookings(String userId) async {
    try {
      final response = await dio.get(
        SupabaseKeys.bookingsRest,
        queryParameters: {
          'user_id': 'eq.$userId',
          'select': '*,listing:listings(id,title,location)',
          'order': 'check_in.desc',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List data = response.data;
        return Right(data.map((e) => GuestBookingDetailedModel.fromJson(e)).toList());
      }
      return const Left("فشل في جلب حجوزاتك.");
    } on DioException catch (e) {
      return Left(e.message ?? "حدث خطأ في الشبكة");
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> cancelBooking(String bookingId, String userId) async {
    try {
      final response = await dio.patch(
        SupabaseKeys.bookingsRest,
        queryParameters: {
          'id': 'eq.$bookingId',
          'user_id': 'eq.$userId',
        },
        data: {'status': 'cancelled'},
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        return const Right(null);
      }
      return const Left("فشل في إلغاء الحجز.");
    } on DioException catch (e) {
      return Left(e.message ?? "حدث خطأ في الشبكة");
    } catch (e) {
      return Left(e.toString());
    }
  }
}
