import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freelancer/core/app_router/routes.dart';
import 'package:freelancer/features/auth/data/repos/auth_repo.dart';
import 'package:freelancer/features/auth/logic/cubit/auth_state.dart';
import 'package:freelancer/features/auth/data/models/user_model.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:freelancer/core/services/admin_email_service.dart';

class AuthCubit extends Cubit<AuthCubitState> {
  final AuthRepo _authRepo;
  final AdminEmailService _adminService;
  Timer? _googleSignInTimer;

  static const _kGoogleSignInTimeout = Duration(minutes: 2);

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

      log('🔔 Supabase Auth Change: $event', name: 'AuthCubit');

      if (session != null) {
        await _authRepo.saveSessionFromOAuth(session);
      }

      if (event == AuthChangeEvent.signedIn && session != null) {
        // لغّي الـ timeout لأن النجاح وصل
        _cancelGoogleTimer();

        final user = UserModel.fromJson(session.user.toJson());
        emit(_resolveSuccess(user));
      } else if (event == AuthChangeEvent.signedOut) {
        emit(const AuthSignedOut());
      } else if (event == AuthChangeEvent.passwordRecovery && session != null) {
        final user = UserModel.fromJson(session.user.toJson());
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
    // Restore native Supabase session first
    await _authRepo.restoreSession();

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
  //  Apple Sign In
  // ─────────────────────────────────────────────

  Future<void> signInWithApple() async {
    try {
      emit(const AuthGoogleLoading()); // نستخدم حالة تحميل الـ Social
      log('🔄 Apple Sign-In started...', name: 'AuthCubit');

      final supabase = Supabase.instance.client;
      final rawNonce = supabase.auth.generateRawNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
        // ✅ WebAuthenticationOptions are required for Android. On iOS, it uses the native Bundle ID.
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId:
              'com.ejabatech.quickin.service', // ⚠️ تأكد أن هذا هو الـ Service ID Identifier وليس الـ App Bundle ID
          redirectUri: Uri.parse(
            'https://xpvrgdpsvffmttlwwfuo.supabase.co/auth/v1/callback',
          ),
        ),
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        emit(const AuthError("فشل الحصول على الـ Token من Apple"));
        return;
      }

      final givenName = credential.givenName;
      final familyName = credential.familyName;
      String? fullName;
      if (givenName != null || familyName != null) {
        fullName = '${givenName ?? ''} ${familyName ?? ''}'.trim();
      }

      await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );

      if (fullName != null && fullName.isNotEmpty) {
        try {
          await supabase.auth.updateUser(
            UserAttributes(
              data: {'full_name': fullName},
            ),
          );
          log('✅ Saved Apple user name: $fullName', name: 'AuthCubit');
        } catch (e) {
          log('⚠️ Failed to save Apple user name to metadata: $e', name: 'AuthCubit');
        }
      }
      // الـ AuthChangeListener هيتولى الباقي وينقلك للهوم
    } catch (e) {
      log('❌ Apple Sign-In error: $e', name: 'AuthCubit');
      if (e is SignInWithAppleAuthorizationException &&
          e.code == AuthorizationErrorCode.canceled) {
        emit(const AuthInitial());
      } else {
        emit(AuthError('فشل تسجيل دخول Apple: ${e.toString()}'));
      }
    }
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
        // 'pending_oauth' = Android web OAuth flow opened — stay in Loading.
        // 'empty_oauth'   = Web redirect launched — stay in Loading.
        // The _listenToAuthChanges handler will fire when the session arrives.
        if (user.id == 'pending_oauth' || user.id == 'empty_oauth') {
          log('⏳ Waiting for OAuth callback...', name: 'AuthCubit');
          return; // keep AuthGoogleLoading active
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

  // ─────────────────────────────────────────────
  //  Magic Link
  // ─────────────────────────────────────────────

  /// Dispatches a magic link email to [email].
  /// On success emits [AuthMagicLinkSent] so the UI can show the OTP input.
  Future<void> sendMagicLink({required String email}) async {
    emit(const AuthMagicLinkLoading());
    final result = await _authRepo.sendMagicLink(email: email);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthMagicLinkSent(email)),
    );
  }

  /// Verifies the OTP the user received via the magic link email.
  /// On success resolves to [AuthSuccess] or [AuthAdminSuccess].
  Future<void> verifyMagicLinkOTP({
    required String email,
    required String otp,
  }) async {
    emit(const AuthMagicLinkLoading());
    final result = await _authRepo.verifyMagicLinkOTP(email: email, otp: otp);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(_resolveSuccess(user)),
    );
  }

  bool get isMagicLinkLoading => state is AuthMagicLinkLoading;

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
