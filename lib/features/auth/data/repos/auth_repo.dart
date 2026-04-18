import 'package:dartz/dartz.dart';
import 'package:freelancer/core/error/failures_errors.dart';
import 'package:freelancer/features/auth/data/models/user_model.dart';

abstract class AuthRepo {
  Future<Either<AuthFailure, UserModel>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<AuthFailure, UserModel>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  });

  Future<Either<AuthFailure, UserModel>> signInWithGoogle();

  Future<Either<AuthFailure, Unit>> signOut();

  Future<Either<AuthFailure, Unit>> recoverPassword({required String email});

  Future<Either<AuthFailure, Map<String, dynamic>>> enrollMFA();

  Future<Either<AuthFailure, Unit>> verifyMFA({
    required String factorId,
    required String challengeId,
    required String code,
  });

  Future<Either<AuthFailure, Unit>> updatePassword({
    required String newPassword,
  });

  Future<Either<AuthFailure, Map<String, dynamic>>> refreshToken();

  Future<Either<AuthFailure, UserModel>> updateMetadata(Map<String, dynamic> metadata);

  UserModel? getCurrentUser();
}
