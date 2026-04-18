import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freelancer/core/app_router/routes.dart';
import 'package:freelancer/features/auth/data/repos/auth_repo.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_state.dart';
import 'package:freelancer/features/auth/data/models/user_model.dart';
import 'package:freelancer/core/services/admin_email_service.dart';

// Admin emails are now loaded from assets via AdminEmailService

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo _authRepo;
  final AdminEmailService _adminService;

  AuthCubit({
    required AuthRepo authRepo,
    required AdminEmailService adminService,
  }) : _authRepo = authRepo,
       _adminService = adminService,
       super(const AuthInitial()) {
    _checkCurrentUser();
  }

  // ─────────────────────────────────────────────
  //  Getters — استخدمهم في الـ View مباشرة
  // ─────────────────────────────────────────────

  bool get isLoading => state is AuthLoading || state is AuthGoogleLoading;
  bool get isGoogleLoading => state is AuthGoogleLoading;
  bool get isEmailLoading => state is AuthLoading;
  bool get isAuthenticated => state is AuthSuccess || state is AuthAdminSuccess;
  bool get isAdmin => state is AuthAdminSuccess;
  String get googleButtonLabel =>
      isGoogleLoading ? 'Signing in...' : 'Continue with Google';

  // ─────────────────────────────────────────────
  //  Init
  // ─────────────────────────────────────────────

  void _checkCurrentUser() {
    final user = _authRepo.getCurrentUser();
    if (user != null) emit(_resolveSuccess(user));
  }

  // ─────────────────────────────────────────────
  //  Email & Password
  // ─────────────────────────────────────────────

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());

    final result = await _authRepo.signInWithEmail(
      email: email,
      password: password,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(_resolveSuccess(user)),
    );
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    emit(const AuthLoading());

    final result = await _authRepo.signUpWithEmail(
      email: email,
      password: password,
      name: name,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(_resolveSuccess(user)),
    );
  }

  // ─────────────────────────────────────────────
  //  Google
  // ─────────────────────────────────────────────

  Future<void> signInWithGoogle() async {
    emit(const AuthGoogleLoading());
    log('🔄 Google Sign-In started...', name: 'AuthCubit');

    final result = await _authRepo.signInWithGoogle();

    result.fold(
      (failure) {
        log(
          '❌ Google Sign-In failed: ${failure.message}',
          name: 'AuthCubit',
          error: failure,
        );
        emit(AuthError(failure.message));
      },
      (user) {
        log(
          '✅ Google Sign-In success | uid: ${user.id} | email: ${user.email}',
          name: 'AuthCubit',
        );
        emit(_resolveSuccess(user));
      },
    );
  }

  // ─────────────────────────────────────────────
  //  Sign Out
  // ─────────────────────────────────────────────

  Future<void> signOut() async {
    emit(const AuthLoading());

    final result = await _authRepo.signOut();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthSignedOut()),
    );
  }

  // ─────────────────────────────────────────────
  //  Advanced Auth
  // ─────────────────────────────────────────────

  Future<void> recoverPassword({required String email}) async {
    emit(const AuthLoading());
    final result = await _authRepo.recoverPassword(email: email);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthRecoverSuccess()),
    );
  }

  Future<void> updatePassword({required String newPassword}) async {
    emit(const AuthLoading());
    final result = await _authRepo.updatePassword(newPassword: newPassword);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthUpdatePasswordSuccess()),
    );
  }

  Future<void> enrollMFA() async {
    emit(const AuthLoading());
    final result = await _authRepo.enrollMFA();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (factorData) => emit(AuthMfaEnrolled(factorData)),
    );
  }

  Future<void> verifyMFA({
    required String factorId,
    required String challengeId,
    required String code,
  }) async {
    emit(const AuthLoading());
    final result = await _authRepo.verifyMFA(
      factorId: factorId,
      challengeId: challengeId,
      code: code,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthMfaVerified()),
    );
  }

  Future<void> refreshToken() async {
    emit(const AuthLoading());
    final result = await _authRepo.refreshToken();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthTokenRefreshed()),
    );
  }

  Future<void> getUserInfo() async {
    final user = _authRepo.getCurrentUser();
    if (user != null) {
      emit(_resolveSuccess(user));
    }
  }

  // ─────────────────────────────────────────────
  //  Helpers
  // ─────────────────────────────────────────────

  AuthState _resolveSuccess(UserModel user) {
    final email = user.email.toLowerCase().trim();
    final isAdminUser = _adminService.isAdmin(email);

    // Update user role based on admin check
    final updatedUser = user.copyWith(
      role: isAdminUser ? UserRole.admin : UserRole.user,
    );

    log(
      isAdminUser
          ? '👑 Admin detected | email: $email'
          : '👤 User detected | email: $email',
      name: 'AuthCubit',
    );

    return isAdminUser
        ? AuthAdminSuccess(updatedUser)
        : AuthSuccess(updatedUser);
  }

  /// Navigate to the appropriate dashboard after a successful login.
  void navigateAfterLogin(BuildContext context) {
    if (state is AuthAdminSuccess) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.adminDashboard,
        (route) => false, // امسح كل الـ stack
      );
    } else if (state is AuthSuccess) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.home,
        (route) => false, // امسح كل الـ stack
      );
    }
  }

  @override
  void emit(AuthState state) {
    if (!isClosed) super.emit(state);
  }
}
