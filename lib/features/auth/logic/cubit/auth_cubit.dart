import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freelancer/core/app_router/routes.dart';
import 'package:freelancer/features/auth/data/repos/auth_repo.dart';
import 'package:freelancer/features/auth/logic/cubit/auth_state.dart';
import 'package:freelancer/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:freelancer/core/services/admin_email_service.dart';

class AuthCubit extends Cubit<AuthCubitState> {
  final AuthRepo _authRepo;
  final AdminEmailService _adminService;
  Timer? _googleSignInTimer;

  static const _kGoogleSignInTimeout = Duration(seconds: 10);

  AuthCubit({
    required AuthRepo authRepo,
    required AdminEmailService adminService,
  }) : _authRepo = authRepo,
       _adminService = adminService,
       super(const AuthInitial()) {
    _checkCurrentUser();
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        log('🔔 Supabase Auth Change: Signed In', name: 'AuthCubit');

        // لغّي الـ timeout لأن النجاح وصل
        _cancelGoogleTimer();

        final user = UserModel.fromJson(session.user.toJson());
        await _authRepo.saveSessionFromOAuth(session);
        emit(_resolveSuccess(user));
      } else if (event == AuthChangeEvent.signedOut) {
        log('🔔 Supabase Auth Change: Signed Out', name: 'AuthCubit');
        emit(const AuthSignedOut());
      } else if (event == AuthChangeEvent.passwordRecovery && session != null) {
        log('🔔 Supabase Auth Change: Password Recovery', name: 'AuthCubit');
        final user = UserModel.fromJson(session.user.toJson());
        await _authRepo.saveSessionFromOAuth(session);
        emit(AuthPasswordRecovery(user));
      }
    });
  }

  // ─────────────────────────────────────────────
  //  Getters
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

  Future<void> _checkCurrentUser() async {
    final user = _authRepo.getCurrentUser();
    if (user != null) {
      emit(_resolveSuccess(user));
      return;
    }
    final result = await _authRepo.refreshToken();
    result.fold((_) {}, (_) async {
      final refreshedUser = _authRepo.getCurrentUser();
      if (refreshedUser != null) emit(_resolveSuccess(refreshedUser));
    });
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

    // Timeout guard: لو الـ WebView علقت أو المستخدم عملها dismiss
    _googleSignInTimer = Timer(_kGoogleSignInTimeout, () {
      if (state is AuthGoogleLoading) {
        log('⏱ Google Sign-In timeout', name: 'AuthCubit');
        emit(const AuthError('انتهت مدة تسجيل الدخول، حاول مجدداً'));
      }
    });

    final result = await _authRepo.signInWithGoogle();

    result.fold(
      (failure) {
        _cancelGoogleTimer();
        log(
          '❌ Google Sign-In failed: ${failure.message}',
          name: 'AuthCubit',
          error: failure,
        );
        emit(AuthError(failure.message));
      },
      (user) {
        if (user.id == 'pending_oauth') {
          // الـ Listener في _listenToAuthChanges هيكمّل بعد اختيار الأكونت
          // الـ Timer شغّال في الخلفية كـ safety net
          log('⏳ Waiting for account picker...', name: 'AuthCubit');
          return;
        }
        _cancelGoogleTimer();
        log(
          '✅ Google Sign-In success | uid: ${user.id} | email: ${user.email}',
          name: 'AuthCubit',
        );
        emit(_resolveSuccess(user));
      },
    );
  }

  void _cancelGoogleTimer() {
    _googleSignInTimer?.cancel();
    _googleSignInTimer = null;
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

  Future<void> verifyRecoveryOTP({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    emit(const AuthLoading());
    final result = await _authRepo.verifyRecoveryOTP(
      email: email,
      otp: otp,
      newPassword: newPassword,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthUpdatePasswordSuccess()),
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
    if (user != null) emit(_resolveSuccess(user));
  }

  // ─────────────────────────────────────────────
  //  Helpers
  // ─────────────────────────────────────────────

  AuthCubitState _resolveSuccess(UserModel user) {
    final email = user.email.toLowerCase().trim();
    final isAdminUser = _adminService.isAdmin(email);

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

  void navigateAfterLogin(BuildContext context) {
    if (state is AuthAdminSuccess) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.adminDashboard, (route) => false);
    } else if (state is AuthSuccess) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
    }
  }

  @override
  void emit(AuthCubitState state) {
    if (!isClosed) super.emit(state);
  }

  @override
  Future<void> close() {
    _cancelGoogleTimer();
    return super.close();
  }
}
