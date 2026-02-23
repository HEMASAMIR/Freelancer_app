import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:freelancer/core/error/failures_errors.dart';
import 'package:freelancer/features/auth/data/repos/auth_repo.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepoImpl implements AuthRepo {
  final SupabaseClient _supabase;

  AuthRepoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<AuthFailure, User>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) return left(const UserNotFoundFailure());
      return right(response.user!);
    } on AuthException catch (e) {
      return left(_mapAuthException(e));
    } catch (_) {
      return left(const NetworkFailure());
    }
  }

  @override
  Future<Either<AuthFailure, User>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );
      if (response.user == null) {
        return left(const UnknownFailure("فشل إنشاء الحساب"));
      }
      return right(response.user!);
    } on AuthException catch (e) {
      return left(_mapAuthException(e));
    } catch (_) {
      return left(const NetworkFailure());
    }
  }

  @override
  Future<Either<AuthFailure, User>> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'io.supabase.quickin://login-callback/',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      await Future.delayed(const Duration(seconds: 2));

      final user = _supabase.auth.currentUser;
      if (user == null) return left(const GoogleSignInFailure());
      return right(user);
    } on AuthException catch (e) {
      return left(_mapAuthException(e));
    } catch (e) {
      debugPrint("❌ Google Sign In Error: $e");
      return left(const GoogleSignInFailure());
    }
  }

  @override
  Future<Either<AuthFailure, Unit>> signOut() async {
    try {
      await _supabase.auth.signOut();
      return right(unit);
    } catch (_) {
      return left(const UnknownFailure("فشل تسجيل الخروج"));
    }
  }

  @override
  User? getCurrentUser() => _supabase.auth.currentUser;

  AuthFailure _mapAuthException(AuthException e) {
    debugPrint("❌ AuthException: ${e.message}");
    switch (e.message) {
      case 'Invalid login credentials':
        return const WrongPasswordFailure();
      case 'User already registered':
        return const EmailAlreadyInUseFailure();
      case 'Unable to validate email address: invalid format':
        return const InvalidEmailFailure();
      default:
        return UnknownFailure(e.message);
    }
  }
}
