import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:freelancer/core/constant/constant.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:freelancer/core/error/failures_errors.dart';
import 'package:freelancer/features/auth/data/repos/auth_repo.dart';
import 'package:freelancer/features/auth/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepoImpl implements AuthRepo {
  final Dio _dio;
  final SharedPreferences _prefs;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '1027935621214-l0gp46oa1gf79dv6ja7lc2t3ttcbhme.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  AuthRepoImpl({required Dio dio, required SharedPreferences prefs})
      : _dio = dio,
        _prefs = prefs;

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
      final msg = e.response?.data?['error_description'] ?? e.response?.data?['msg'] ?? e.message;
      return left(UnknownFailure(msg.toString()));
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
      if (data == null || data['user'] == null) {
        return left(const UnknownFailure('فشل إنشاء الحساب'));
      }

      // Supabase Signup with email confirmation might not return a session instantly.
      // If access_token exists, save it:
      if (data['access_token'] != null) {
        await _saveSession(data);
      }

      return right(UserModel.fromJson(data['user']));
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
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return left(const UnknownFailure('تم إلغاء عملية تسجيل الدخول'));
      }

      final GoogleSignInAuthentication auth = await googleUser.authentication;
      final String? idToken = auth.idToken;

      if (idToken == null) {
        return left(
          const UnknownFailure('فشل الحصول على بيانات Google — حاول مرة أخرى'),
        );
      }

      final response = await _dio.post(
        '${SupabaseKeys.authBaseUrl}token?grant_type=id_token',
        data: {
          'id_token': idToken,
          'provider': 'google',
        },
      );

      final data = response.data;
      if (data == null || data['user'] == null) {
        return left(const GoogleSignInFailure());
      }

      await _saveSession(data);
      return right(UserModel.fromJson(data['user']));
    } on DioException catch (e) {
      final msg = e.response?.data?['error_description'] ?? e.response?.data?['msg'] ?? e.message;
      return left(UnknownFailure(msg.toString()));
    } catch (e) {
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
  //  Sign Out
  // ─────────────────────────────────────────────

  @override
  Future<Either<AuthFailure, Unit>> signOut() async {
    try {
      // Opt: We can hit the logout endpoint if we have an active token
      final token = _prefs.getString('supabase_access_token');
      if (token != null) {
        try {
          await _dio.post('${SupabaseKeys.authBaseUrl}logout');
        } catch (_) {
          // Ignore network errs during logout, we will flush session below
        }
      }

      await _clearSession();
      await _googleSignIn.signOut();

      return right(unit);
    } catch (e) {
      return left(NetworkFailure(e.toString()));
    }
  }

  // ─────────────────────────────────────────────
  //  Recovery & MFA
  // ─────────────────────────────────────────────

  @override
  Future<Either<AuthFailure, Unit>> recoverPassword({required String email}) async {
    try {
      await _dio.post(
        '${SupabaseKeys.authBaseUrl}recover',
        data: {'email': email},
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
  Future<Either<AuthFailure, Map<String, dynamic>>> enrollMFA() async {
    try {
      final response = await _dio.post(
        '${SupabaseKeys.authBaseUrl}factors',
        data: {
          'factor_type': 'totp',
          'friendly_name': 'Authenticator App',
        },
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
        data: {
          'challenge_id': challengeId,
          'code': code,
        },
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
        return left(const UnknownFailure('No refresh token found. Please login again.'));
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
      final msg = e.response?.data?['error_description'] ?? e.response?.data?['msg'] ?? e.message;
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
      // Usually, /user endpoint returns just the user object. We update cached user context if valid.
      final userModel = UserModel.fromJson(data);
      await _prefs.setString('supabase_user', jsonEncode(data));
      return right(userModel);
    } on DioException catch (e) {
      final msg = e.response?.data?['error_description'] ?? e.response?.data?['msg'] ?? e.message;
      return left(UnknownFailure(msg.toString()));
    } catch (e) {
      return left(NetworkFailure(e.toString()));
    }
  }
  @override
  Future<Either<AuthFailure, UserModel>> updateMetadata(Map<String, dynamic> metadata) async {
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
      final msg = e.response?.data?['error_description'] ?? e.response?.data?['msg'] ?? e.message;
      return left(UnknownFailure(msg.toString()));
    } catch (e) {
      return left(NetworkFailure(e.toString()));
    }
  }
}
