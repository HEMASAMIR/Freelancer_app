import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/features/admin/data/admin_repo/admin_management_repo.dart';

class AdminManagementRepositoryImpl implements AdminManagementRepository {
  final Dio dio;

  AdminManagementRepositoryImpl({required this.dio});

  @override
  Future<Either<String, void>> updateListingStatus(String listingId, String status) async {
    try {
      // Using full URL because baseDio is pointed to /rest/v1/
      final response = await dio.post(
        '${SupabaseKeys.adminApiBaseUrl}${SupabaseKeys.adminListingsStatus}',
        data: {
          'listing_id': listingId,
          'status': status,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        return const Right(null);
      }
      return const Left("فشل في تحديث حالة العقار.");
    } on DioException catch (e) {
      return Left(e.message ?? "حدث خطأ في الشبكة");
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> processPayout(Map<String, dynamic> payoutData) async {
    try {
      final response = await dio.post(
        '${SupabaseKeys.adminApiBaseUrl}${SupabaseKeys.adminPayoutsProcess}',
        data: payoutData,
      );

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        return const Right(null);
      }
      return const Left("فشل في معالجة المدفوعات.");
    } on DioException catch (e) {
      return Left(e.message ?? "حدث خطأ في الشبكة");
    } catch (e) {
      return Left(e.toString());
    }
  }
}
