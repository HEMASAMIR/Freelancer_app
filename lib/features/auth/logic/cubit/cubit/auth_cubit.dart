import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freelancer/features/auth/data/repos/auth_repo.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

const List<String> _adminEmails = ['admin.aclone@atomicmail.io'];

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo _authRepo;

  AuthCubit({required AuthRepo authRepo})
    : _authRepo = authRepo,
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
  //  Helpers
  // ─────────────────────────────────────────────

  AuthState _resolveSuccess(User user) {
    final email = user.email?.toLowerCase().trim() ?? '';
    final isAdminUser = _adminEmails.contains(email);

    log(
      isAdminUser
          ? '👑 Admin detected | email: $email'
          : '👤 User detected | email: $email',
      name: 'AuthCubit',
    );

    return isAdminUser ? AuthAdminSuccess(user) : AuthSuccess(user);
  }

  @override
  void emit(AuthState state) {
    if (!isClosed) super.emit(state);
  }
}
