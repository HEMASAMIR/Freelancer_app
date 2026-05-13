import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
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
        final data = response.data;
        if (data is List && data.isNotEmpty) {
          final hasConflict = data.first['has_conflict'] as bool? ?? true;
          return Right(!hasConflict);
        }
        return Right(data == true);
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
      // ✅ الـ commission rate الحالية هي اللي effective_to = null
      // (مفيش is_active column — بنفلتر على effective_to)
      final response = await dio.get(
        SupabaseKeys.commissionRatesRest,
        queryParameters: {
          'effective_to': 'is.null',
          'select': 'id,guest_rate',
          'limit': '1',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List data = response.data;
        if (data.isNotEmpty) {
          return Right(data.first);
        }
        // Fallback: جيب آخر record لو كلهم عندهم effective_to
        return _getFallbackCommissionRate();
      }
      return const Left("NO_COMMISSION_RATE");
    } on DioException catch (e) {
      return const Left("NO_COMMISSION_RATE");
    } catch (e) {
      return const Left("NO_COMMISSION_RATE");
    }
  }

  // Fallback: يجيب أحدث commission rate لو مفيش واحد بـ effective_to=null
  Future<Either<String, Map<String, dynamic>>> _getFallbackCommissionRate() async {
    try {
      final response = await dio.get(
        SupabaseKeys.commissionRatesRest,
        queryParameters: {
          'select': 'id,guest_rate',
          'order': 'created_at.desc',
          'limit': '1',
        },
      );
      if (response.statusCode == 200) {
        final List data = response.data;
        if (data.isNotEmpty) return Right(data.first);
      }
      return const Left("NO_COMMISSION_RATE");
    } catch (_) {
      return const Left("NO_COMMISSION_RATE");
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
    String? commissionRateId,
  }) async {
    try {
      // ✅ الخطوة 1: جيب الـ commission rate ID
      String? rateId = commissionRateId;
      if (rateId == null) {
        final rateResult = await getCurrentCommissionRate();
        rateId = rateResult.fold((l) => null, (r) => r['id']?.toString());
      }

      // ✅ الخطوة 2: لو مفيش commission rate خالص → بلّغ المستخدم
      // (الـ commission_rate_id NOT NULL في الـ DB ومينفعش نبعت null)
      if (rateId == null) {
        return const Left(
          "لا يمكن إتمام الحجز: يرجى التواصل مع الدعم (كود: CR-001)",
        );
      }

      final payload = <String, dynamic>{
        "listing_id": listingId,
        "user_id": userId,
        "check_in": checkIn,
        "check_out": checkOut,
        "guests": guests,
        "subtotal": subtotal,
        "status": "pending",
        "escrow_status": "none",
        "commission_rate_id": rateId,
      };

      final response = await dio.post(
        SupabaseKeys.bookingsRest,
        data: payload,
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
      final String rawMessage = e.response?.data?['message'] ?? e.message ?? "";
      
      if (rawMessage.contains("commission_rate_id") ||
          rawMessage.contains("violates not-null constraint")) {
        return const Left("خطأ في إعدادات الحجز — يرجى التواصل مع الدعم (كود: CR-001)");
      } else if (rawMessage.contains("conflict") || rawMessage.contains("overlap")) {
        return const Left("عفواً، هذه المواعيد تم حجزها بالفعل");
      } else if (rawMessage.contains("JWT") || rawMessage.contains("auth")) {
        return const Left("انتهت صلاحية الجلسة — يرجى تسجيل الدخول مجدداً");
      }
      
      return Left(rawMessage.isNotEmpty ? rawMessage : "خطأ في الاتصال بالسيرفر");
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
        queryParameters: {'id': 'eq.$bookingId'},
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
  Future<Either<String, Unit>> confirmBooking({
    required String bookingId,
    required String hostId,
  }) async {
    try {
      final response = await dio.patch(
        SupabaseKeys.bookingsRest,
        queryParameters: {'id': 'eq.$bookingId'},
        data: {"status": "confirmed"},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return Right(unit);
      }
      return const Left("فشل في تأكيد الحجز");
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
      // ✅ PostgREST embedded filter syntax — استخدام listing!inner(user_id)=eq.hostId
      final queryParams = <String, dynamic>{
        'select': '*,listing:listings!inner(id,title,listing_code,user_id),guest:profiles(id,full_name,email)',
        'listing.user_id': 'eq.$hostId',  // PostgREST embedded filter
        'order': 'created_at.desc',
      };
      if (status != null) queryParams['status'] = 'eq.$status';

      final response = await dio.get(
        SupabaseKeys.bookingsRest,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List data = response.data as List;
        // ✅ فلترة إضافية على الـ client جانب للتأكد إن الحجوزات للـ host الصح
        final filtered = data.where((e) {
          final listing = e['listing'];
          if (listing == null) return false;
          if (listing is List) return listing.any((l) => l['user_id'] == hostId);
          return listing['user_id'] == hostId;
        }).toList();
        return Right(filtered.map((e) => BookingModel.fromJson(e)).toList());
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
