import 'package:dartz/dartz.dart';
import 'package:freelancer/core/error/failures_errors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepo {
  Future<Either<AuthFailure, User>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<AuthFailure, User>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  });

  Future<Either<AuthFailure, User>> signInWithGoogle();

  Future<Either<AuthFailure, Unit>> signOut();

  User? getCurrentUser();
}
