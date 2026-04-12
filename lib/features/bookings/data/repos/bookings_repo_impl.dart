import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constant/constant.dart';
import '../models/booking_model.dart';
import 'bookings_repo.dart';

class BookingsRepositoryImpl implements BookingsRepository {
  final Dio dio;

  BookingsRepositoryImpl({required this.dio});

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
      return const Left("فشل في التحقق من التوافر");
    } on DioException catch (e) {
      return Left(
        e.response?.data?['message'] ?? e.message ?? "خطأ في الاتصال",
      );
    } catch (e) {
      return Left("خطأ غير متوقع: ${e.toString()}");
    }
  }

  @override
  Future<Either<String, Map<String, dynamic>>>
  getCurrentCommissionRate() async {
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
        return const Left("لا يوجد نسبة عمولة مفعلة");
      }
      return const Left("فشل في الحصول على نسبة العمولة");
    } on DioException catch (e) {
      return Left(
        e.response?.data?['message'] ?? e.message ?? "خطأ في الاتصال",
      );
    } catch (e) {
      return Left("خطأ غير متوقع: ${e.toString()}");
    }
  }

  @override
  Future<Either<String, BookingModel>> createBooking({
    required String listingId,
    required String userId,
    required String checkIn,
    required String checkOut,
    required int guests,
    required num subtotal,
    required String commissionRateId,
  }) async {
    try {
      final response = await dio.post(
        SupabaseKeys.bookingsRest,
        data: {
          "listing_id": listingId,
          "user_id": userId,
          "check_in": checkIn,
          "check_out": checkOut,
          "guests": guests,
          "subtotal": subtotal,
          "commission_rate_id": commissionRateId,
          "status": "pending",
          "escrow_status": "none",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data != null &&
            response.data is List &&
            response.data.isNotEmpty) {
          return Right(BookingModel.fromJson(response.data.first));
        }
        return Right(BookingModel(id: 'created'));
      }
      return const Left("فشل في إنشاء الحجز");
    } on DioException catch (e) {
      return Left(
        e.response?.data?['message'] ?? e.message ?? "خطأ في الاتصال",
      );
    } catch (e) {
      return Left("خطأ غير متوقع: ${e.toString()}");
    }
  }

  @override
  Future<Either<String, Unit>> cancelBooking({
    required String bookingId,
    required String userId,
  }) async {
    try {
      final response = await dio.patch(
        SupabaseKeys.bookingsRest,
        queryParameters: {'id': 'eq.$bookingId', 'user_id': 'eq.$userId'},
        data: {"status": "cancelled"},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return Right(unit);
      }
      return const Left("فشل في إلغاء الحجز");
    } on DioException catch (e) {
      return Left(
        e.response?.data?['message'] ?? e.message ?? "خطأ في الاتصال",
      );
    } catch (e) {
      return Left("خطأ غير متوقع: ${e.toString()}");
    }
  }

  @override
  Future<Either<String, List<BookingModel>>> getHostBookings({
    required String hostId,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'select': '*,listing:listings!inner(id,title,listing_code,user_id),guest:profiles(id,full_name,email)',
        'listing.user_id': 'eq.$hostId',
        'order': 'created_at.desc',
      };
      if (status != null) queryParams['status'] = 'eq.$status';

      final response = await dio.get(
        SupabaseKeys.bookingsRest,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List data = response.data;
        return Right(data.map((e) => BookingModel.fromJson(e)).toList());
      }
      return const Left("فشل في تحميل حجوزات المضيف");
    } on DioException catch (e) {
      return Left(e.message ?? "خطأ في الاتصال");
    }
  }

  @override
  Future<Either<String, List<BookingModel>>> getUserBookings({
    required String userId,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'user_id': 'eq.$userId',
        'select': '*',
        'order': 'check_in.asc',
      };
      if (status != null) queryParams['status'] = 'eq.$status';

      final response = await dio.get(
        SupabaseKeys.bookingsRest,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List data = response.data;
        return Right(data.map((e) => BookingModel.fromJson(e)).toList());
      }
      return const Left("فشل في تحميل الحجوزات");
    } on DioException catch (e) {
      return Left(e.message ?? "خطأ في الاتصال");
    }
  }
}
