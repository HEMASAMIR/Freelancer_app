import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/features/account/data/models/account_models.dart';
import 'package:freelancer/features/account/data/repos/account_repo.dart';

class AccountRepositoryImpl implements AccountRepository {
  final Dio dio;

  AccountRepositoryImpl({required this.dio});

  @override
  Future<Either<String, AccountProfileModel>> getProfile(String userId) async {
    try {
      final response = await dio.get(
        SupabaseKeys.profilesRest,
        queryParameters: {
          'id': 'eq.$userId',
          'select': '*',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List data = response.data;
        if (data.isNotEmpty) {
          return Right(AccountProfileModel.fromJson(data.first));
        }
        return const Left("لم يتم العثور على الحساب.");
      }
      return const Left("فشل في جلب بيانات الحساب.");
    } on DioException catch (e) {
      return Left(e.message ?? "حدث خطأ في الشبكة");
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> updateProfile(String userId, Map<String, dynamic> profileData) async {
    try {
      final response = await dio.patch(
        SupabaseKeys.profilesRest,
        queryParameters: {'id': 'eq.$userId'},
        data: profileData,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Right(null);
      }
      return const Left("فشل في تحديث بيانات الحساب.");
    } on DioException catch (e) {
      return Left(e.message ?? "حدث خطأ في الشبكة");
    } catch (e) {
      return Left(e.toString());
    }
  }
}
