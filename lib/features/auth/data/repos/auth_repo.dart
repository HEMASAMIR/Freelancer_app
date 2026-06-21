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

  Future<Either<AuthFailure, Unit>> verifyRecoveryOTP({
    required String email,
    required String otp,
    required String newPassword,
  });

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

  Future<Either<AuthFailure, UserModel>> updateMetadata(
    Map<String, dynamic> metadata,
  );

  Future<Either<AuthFailure, UserModel>> getUserInfo();

  UserModel? getCurrentUser();

  Future<void> saveSessionFromOAuth(dynamic session);

  Future<void> restoreSession();

  // ─── Magic Link ───────────────────────────────────────────────────────────

  /// Sends a passwordless magic link to [email]. The user taps the link
  /// (or enters the 8-digit OTP) to sign in without a password.
  Future<Either<AuthFailure, Unit>> sendMagicLink({required String email});

  /// Verifies the OTP code that Supabase sent alongside the magic link email.
  Future<Either<AuthFailure, UserModel>> verifyMagicLinkOTP({
    required String email,
    required String otp,
  });
}
