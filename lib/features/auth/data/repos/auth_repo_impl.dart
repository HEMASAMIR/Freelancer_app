import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:freelancer/core/error/failures_errors.dart';
import 'package:freelancer/features/auth/data/repos/auth_repo.dart';
import 'package:freelancer/features/auth/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepoImpl implements AuthRepo {
  final Dio _dio;
  final SharedPreferences _prefs;
  final SupabaseClient _supabase;

  AuthRepoImpl({
    required Dio dio,
    required SharedPreferences prefs,
    required SupabaseClient supabase,
  }) : _dio = dio,
       _prefs = prefs,
       _supabase = supabase;

  // ─────────────────────────────────────────────
  //  Helpers
  // ─────────────────────────────────────────────

  Future<void> _saveSession(Map<String, dynamic> data) async {
    final accessToken = data['access_token'];
    final refreshToken = data['refresh_token'];
    final userMap = data['user'];

    if (accessToken != null) {
      await _prefs.setString('supabase_access_token', accessToken);
    }
    if (refreshToken != null) {
      await _prefs.setString('supabase_refresh_token', refreshToken);
    }
    if (userMap != null) {
      await _prefs.setString('supabase_user', jsonEncode(userMap));
    }

    final currentSession = _supabase.auth.currentSession;
    if (refreshToken != null && currentSession?.refreshToken != refreshToken) {
      try {
        await _supabase.auth.setSession(refreshToken);
        debugPrint('✅ [AuthRepo] Synced session with native Supabase client');
      } catch (e) {
        debugPrint('❌ [AuthRepo] Failed to sync session with native Supabase client: $e');
      }
    }
  }

  Future<void> _clearSession() async {
    await _prefs.remove('supabase_access_token');
    await _prefs.remove('supabase_refresh_token');
    await _prefs.remove('supabase_user');
  }

  // ─────────────────────────────────────────────
  //  Email & Password
  // ─────────────────────────────────────────────

  @override
  Future<Either<AuthFailure, UserModel>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '${SupabaseKeys.authBaseUrl}token?grant_type=password',
        data: {'email': email, 'password': password},
      );

      final data = response.data;
      if (data == null || data['user'] == null) {
        return left(const UserNotFoundFailure());
      }

      await _saveSession(data);
      return right(UserModel.fromJson(data['user']));
    } on DioException catch (e) {
      String msg =
          e.response?.data?['error_description'] ??
          e.response?.data?['msg'] ??
          e.message ??
          'حدث خطأ غير متوقع';

      if (msg.toLowerCase().contains('invalid login credentials')) {
        msg = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      } else if (msg.toLowerCase().contains('email not confirmed')) {
        msg = 'برجاء تأكيد البريد الإلكتروني أولاً';
      }

      return left(UnknownFailure(msg));
    } catch (e) {
      return left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, UserModel>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _dio.post(
        '${SupabaseKeys.authBaseUrl}signup',
        data: {
          'email': email,
          'password': password,
          'data': {'full_name': name},
        },
      );

      final data = response.data;
      if (data == null) {
        return left(const UnknownFailure('فشل إنشاء الحساب'));
      }

      final userJson = data['user'] ?? data;
      if (userJson == null || (userJson is Map && userJson['id'] == null)) {
        return left(const UnknownFailure('فشل إنشاء الحساب'));
      }

      if (data['access_token'] != null) {
        await _saveSession(data);
      }
      return right(UserModel.fromJson(userJson as Map<String, dynamic>));
    } on DioException catch (e) {
      final msg = e.response?.data?['msg'] ?? e.message;
      return left(UnknownFailure(msg.toString()));
    } catch (e) {
      return left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, UserModel>> signInWithGoogle() async {
    try {
      // ✅ Native Google Sign-In with Supabase
      // بنستخدم الـ Native عشان البراوزر بيعمل مشكلة "Not Found" في الـ Deep Link
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: SupabaseKeys.googleWebClientId,
        clientId: SupabaseKeys.googleIosClientId.isNotEmpty
            ? SupabaseKeys.googleIosClientId
            : null,
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return left(const UnknownFailure('تم إلغاء تسجيل الدخول'));
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        return left(
          const UnknownFailure('فشل في الحصول على بيانات المصادقة من جوجل'),
        );
      }

      final AuthResponse response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final user = response.user;
      if (user == null) {
        return left(const UnknownFailure('فشل تسجيل الدخول في النظام'));
      }

      final session = response.session;
      if (session != null) {
        await saveSessionFromOAuth(session);
      }

      final userModel = UserModel.fromJson(user.toJson());
      return right(userModel);
    } catch (e) {
      debugPrint('❌ [AuthRepo] Google Native Sign-In error: $e');
      return left(NetworkFailure(e.toString()));
    }
  }

  // ─────────────────────────────────────────────
  //  Current User
  // ─────────────────────────────────────────────

  @override
  UserModel? getCurrentUser() {
    final userStr = _prefs.getString('supabase_user');
    if (userStr != null && userStr.isNotEmpty) {
      try {
        return UserModel.fromJson(jsonDecode(userStr));
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  // ─────────────────────────────────────────────
  //  OAuth Session Save
  // ─────────────────────────────────────────────

  @override
  Future<void> saveSessionFromOAuth(dynamic session) async {
    if (session is Session) {
      await _saveSession({
        'access_token': session.accessToken,
        'refresh_token': session.refreshToken,
        'user': session.user.toJson(),
      });
      debugPrint('✅ [AuthRepo] OAuth session saved to SharedPreferences');
    }
  }

  @override
  Future<void> restoreSession() async {
    final refreshToken = _prefs.getString('supabase_refresh_token');
    final currentSession = _supabase.auth.currentSession;
    if (refreshToken != null && refreshToken.isNotEmpty && currentSession?.refreshToken != refreshToken) {
      try {
        await _supabase.auth.setSession(refreshToken);
        debugPrint('✅ [AuthRepo] Restored native Supabase session on startup');
      } catch (e) {
        debugPrint('❌ [AuthRepo] Failed to restore native Supabase session on startup: $e');
      }
    }
  }

  // ─────────────────────────────────────────────
  //  Sign Out
  // ─────────────────────────────────────────────

  @override
  Future<Either<AuthFailure, Unit>> signOut() async {
    try {
      final token = _prefs.getString('supabase_access_token');
      if (token != null) {
        try {
          await _dio.post('${SupabaseKeys.authBaseUrl}logout');
        } catch (_) {}
      }

      await _clearSession();
      await _supabase.auth.signOut();

      return right(unit);
    } catch (e) {
      return left(NetworkFailure(e.toString()));
    }
  }

  // ─────────────────────────────────────────────
  //  Recovery & MFA
  // ─────────────────────────────────────────────

  @override
  Future<Either<AuthFailure, Unit>> recoverPassword({
    required String email,
  }) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.quickin://login-callback',
      );
      return right(unit);
    } on AuthException catch (e) {
      return left(UnknownFailure(e.message));
    } catch (e) {
      return left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, Unit>> verifyRecoveryOTP({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.recovery,
      );

      if (response.session != null) {
        await _dio.put(
          '${SupabaseKeys.authBaseUrl}user',
          data: {'password': newPassword},
          options: Options(
            headers: {
              'Authorization': 'Bearer ${response.session!.accessToken}',
            },
          ),
        );
        return right(unit);
      } else {
        return left(
          const UnknownFailure('كود التحقق غير صحيح أو منتهي الصلاحية'),
        );
      }
    } on AuthException catch (e) {
      return left(UnknownFailure(e.message));
    } catch (e) {
      return left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, Map<String, dynamic>>> enrollMFA() async {
    try {
      final response = await _dio.post(
        '${SupabaseKeys.authBaseUrl}factors',
        data: {'factor_type': 'totp', 'friendly_name': 'Authenticator App'},
      );
      return right(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg = e.response?.data?['msg'] ?? e.message;
      return left(UnknownFailure(msg.toString()));
    } catch (e) {
      return left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, Unit>> verifyMFA({
    required String factorId,
    required String challengeId,
    required String code,
  }) async {
    try {
      await _dio.post(
        '${SupabaseKeys.authBaseUrl}factors/$factorId/verify',
        data: {'challenge_id': challengeId, 'code': code},
      );
      return right(unit);
    } on DioException catch (e) {
      final msg = e.response?.data?['msg'] ?? e.message;
      return left(UnknownFailure(msg.toString()));
    } catch (e) {
      return left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, Unit>> updatePassword({
    required String newPassword,
  }) async {
    try {
      await _dio.put(
        '${SupabaseKeys.authBaseUrl}user',
        data: {'password': newPassword},
      );
      return right(unit);
    } on DioException catch (e) {
      final msg = e.response?.data?['msg'] ?? e.message;
      return left(UnknownFailure(msg.toString()));
    } catch (e) {
      return left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, Map<String, dynamic>>> refreshToken() async {
    try {
      final refreshToken = _prefs.getString('supabase_refresh_token');
      if (refreshToken == null) {
        return left(
          const UnknownFailure('No refresh token found. Please login again.'),
        );
      }
      final response = await _dio.post(
        '${SupabaseKeys.authBaseUrl}token?grant_type=refresh_token',
        data: {'refresh_token': refreshToken},
      );
      final data = response.data;
      if (data == null || data['access_token'] == null) {
        return left(const UnknownFailure('Failed to refresh token'));
      }
      await _saveSession(data);
      return right(data as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg =
          e.response?.data?['error_description'] ??
          e.response?.data?['msg'] ??
          e.message;
      return left(UnknownFailure(msg.toString()));
    } catch (e) {
      return left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, UserModel>> getUserInfo() async {
    try {
      final response = await _dio.get('${SupabaseKeys.authBaseUrl}user');
      final data = response.data;
      if (data == null) {
        return left(const UnknownFailure('Failed to fetch user data'));
      }
      final userModel = UserModel.fromJson(data);
      await _prefs.setString('supabase_user', jsonEncode(data));
      return right(userModel);
    } on DioException catch (e) {
      final msg =
          e.response?.data?['error_description'] ??
          e.response?.data?['msg'] ??
          e.message;
      return left(UnknownFailure(msg.toString()));
    } catch (e) {
      return left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, UserModel>> updateMetadata(
    Map<String, dynamic> metadata,
  ) async {
    try {
      final response = await _dio.put(
        '${SupabaseKeys.authBaseUrl}user',
        data: {'data': metadata},
      );
      final data = response.data;
      if (data == null) {
        return left(const UnknownFailure('فشل تحديث بيانات المستخدم'));
      }
      final userModel = UserModel.fromJson(data);
      await _prefs.setString('supabase_user', jsonEncode(data));
      return right(userModel);
    } on DioException catch (e) {
      final msg =
          e.response?.data?['error_description'] ??
          e.response?.data?['msg'] ??
          e.message;
      return left(UnknownFailure(msg.toString()));
    } catch (e) {
      return left(NetworkFailure(e.toString()));
    }
  }

  // ─────────────────────────────────────────────
  //  Magic Link
  // ─────────────────────────────────────────────

  @override
  Future<Either<AuthFailure, Unit>> sendMagicLink({
    required String email,
  }) async {
    try {
      // Supabase sends an 8-digit OTP along with the clickable magic link.
      // The user can either click the email link OR enter the OTP manually.
      // ⚠️  OTP length is 8 digits — keep UI in sync (magic_link_view.dart).
      await _supabase.auth.signInWithOtp(
        email: email,
        emailRedirectTo: 'io.supabase.quickin://login-callback',
        shouldCreateUser: true, // auto-register if the email is new
      );
      return right(unit);
    } on AuthException catch (e) {
      return left(UnknownFailure(e.message));
    } catch (e) {
      return left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, UserModel>> verifyMagicLinkOTP({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.magiclink,
      );

      final session = response.session;
      final user = response.user;

      if (session == null || user == null) {
        return left(
          const UnknownFailure('كود التحقق غير صحيح أو منتهي الصلاحية'),
        );
      }

      await saveSessionFromOAuth(session);
      debugPrint('✅ [AuthRepo] Magic Link OTP verified | uid: ${user.id}');
      return right(UserModel.fromJson(user.toJson()));
    } on AuthException catch (e) {
      return left(UnknownFailure(e.message));
    } catch (e) {
      return left(NetworkFailure(e.toString()));
    }
  }
}
