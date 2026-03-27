import 'package:dartz/dartz.dart';
import 'package:freelancer/core/error/auth_failure.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:freelancer/core/error/failures_errors.dart';
import 'package:freelancer/features/auth/data/repos/auth_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepoImpl implements AuthRepo {
  final SupabaseClient _supabase;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '1027935621214-l0gp46oa1gf79dv6ja7lc2t3ttcbhme.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  AuthRepoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  // ─────────────────────────────────────────────
  //  Email & Password
  // ─────────────────────────────────────────────

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
      return left(mapAuthException(e));
    } catch (e) {
      return left(NetworkFailure(e.toString()));
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
        return left(const UnknownFailure('فشل إنشاء الحساب'));
      }

      return right(response.user!);
    } on AuthException catch (e) {
      return left(mapAuthException(e));
    } catch (e) {
      return left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, User>> signInWithGoogle() async {
    try {
      // نتأكد إن مفيش session قديمة عالقة
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // المستخدم ألغى الـ dialog
      if (googleUser == null) {
        return left(const UnknownFailure('تم إلغاء عملية تسجيل الدخول'));
      }

      final GoogleSignInAuthentication auth = await googleUser.authentication;

      final String? idToken = auth.idToken;
      final String? accessToken = auth.accessToken;

      // idToken مطلوب إلزامياً لـ Supabase
      if (idToken == null) {
        return left(
          const UnknownFailure('فشل الحصول على بيانات Google — حاول مرة أخرى'),
        );
      }

      final AuthResponse res = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (res.user == null) return left(const GoogleSignInFailure());

      return right(res.user!);
    } on AuthException catch (e) {
      return left(UnknownFailure(e.message));
    } catch (e) {
      return left(NetworkFailure(e.toString()));
    }
  }

  // ─────────────────────────────────────────────
  //  Current User
  // ─────────────────────────────────────────────

  @override
  User? getCurrentUser() => _supabase.auth.currentUser;

  // ─────────────────────────────────────────────
  //  Sign Out
  // ─────────────────────────────────────────────

  @override
  Future<Either<AuthFailure, Unit>> signOut() async {
    try {
      // نسجّل خروج من Supabase و Google في نفس الوقت
      await Future.wait([_supabase.auth.signOut(), _googleSignIn.signOut()]);

      return right(unit);
    } on AuthException catch (e) {
      return left(UnknownFailure(e.message));
    } catch (e) {
      return left(NetworkFailure(e.toString()));
    }
  }
}
