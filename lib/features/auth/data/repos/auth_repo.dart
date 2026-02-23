import 'package:dartz/dartz.dart';
import 'package:freelancer/core/error/failures_errors.dart';
import 'package:freelancer/features/auth/model/auth_model.dart';

abstract class AuthRepo {
  Future<Either<Failure, UserModel>> signUp({
    required String name,
    required String email,
    required String password,
  });
}
