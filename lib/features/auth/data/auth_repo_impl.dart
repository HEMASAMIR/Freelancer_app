import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:freelancer/core/costant/constant.dart';
import 'package:freelancer/core/error/failures_errors.dart';
import 'package:freelancer/features/auth/data/repos/auth_repo.dart';
import 'package:freelancer/features/auth/model/auth_model.dart';

class AuthRepoImpl implements AuthRepo {
  final Dio _dio;
  final String supabaseUrl = AppConstants.supabaseUrl;
  final String supabaseKey = AppConstants.supabaseAnonKey;

  AuthRepoImpl(this._dio);

  @override
  Future<Either<Failure, UserModel>> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '$supabaseUrl/auth/v1/signup',
        data: {
          'email': email,
          'password': password,
          'data': {'full_name': name},
        },
        options: Options(
          headers: {
            'apikey': supabaseKey,
            'Authorization': 'Bearer $supabaseKey',
            'Content-Type': 'application/json',
          },
        ),
      );

      // تحويل الـ Response لـ Model
      final userModel = UserModel.fromJson(response.data);
      return Right(userModel);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
