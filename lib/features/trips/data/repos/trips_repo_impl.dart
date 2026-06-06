import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constant/constant.dart';
import '../models/trip_model.dart';
import 'trips_repo.dart';

class TripsRepositoryImpl implements TripsRepository {
  final Dio dio;

  TripsRepositoryImpl({required this.dio});

  @override
  Future<Either<String, List<TripModel>>> getUserTrips(String userId) async {
    try {
      final response = await dio.get(
        SupabaseKeys.bookingsRest,
        queryParameters: {
          'user_id': 'eq.$userId',
          't': DateTime.now().millisecondsSinceEpoch
              .toString(), // Cache Buster لمنع الكاش تماماً
          // استخدام !inner لضمان جلب الحجوزات اللي العقار بتاعها موجود فعلياً في قاعدة البيانات
          'select':
              '*,listing:listings!inner(id,title,location,is_published,listing_images(url))',
          // استخدام eq.true لضمان الفلترة الصحيحة لقيم الـ Boolean
          'listing.is_published': 'eq.true',
          'order': 'check_in.desc',
        },
        options: Options(
          headers: {
            'Cache-Control': 'no-cache, no-store, must-revalidate',
            'Pragma': 'no-cache',
            'Expires': '0',
          }, // منع الكاش تماماً على مستوى الـ Network والـ Proxy
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List data = response.data;
        return Right(data.map((e) => TripModel.fromJson(e)).toList());
      }
      return const Left("فشل في جلب البيانات من السيرفر");
    } on DioException catch (e) {
      debugPrint("❌ Dio Error fetching trips: ${e.message}");
      return Left(
        e.response?.data?['message'] ?? e.message ?? "خطأ في الاتصال",
      );
    } catch (e) {
      debugPrint("❌ Unexpected Error fetching trips: $e");
      return Left("خطأ غير متوقع: ${e.toString()}");
    }
  }
}
