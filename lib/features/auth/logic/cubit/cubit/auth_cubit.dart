import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freelancer/core/error/failures_errors.dart';
import 'package:freelancer/features/auth/data/repos/auth_repo.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo _authRepo;

  AuthCubit({required AuthRepo authRepo})
    : _authRepo = authRepo,
      super(const AuthInitial()) {
    _checkCurrentUser();
  }

  // ✅ تحقق لو في يوزر مسجل دخول
  void _checkCurrentUser() {
    final user = _authRepo.getCurrentUser();
    if (user != null) {
      emit(AuthSuccess(user));
    }
  }

  // ✅ تسجيل الدخول بالإيميل
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
      (failure) => emit(AuthError(_mapFailureMessage(failure))),
      (user) => emit(AuthSuccess(user)),
    );
  }

  // ✅ إنشاء حساب
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
      (failure) => emit(AuthError(_mapFailureMessage(failure))),
      (user) => emit(AuthSuccess(user)),
    );
  }

  // ✅ تسجيل الدخول بـ Google
  Future<void> signInWithGoogle() async {
    emit(const AuthGoogleLoading());

    final result = await _authRepo.signInWithGoogle();

    result.fold(
      (failure) => emit(AuthError(_mapFailureMessage(failure))),
      (user) => emit(AuthSuccess(user)),
    );
  }

  // ✅ تسجيل الخروج
  Future<void> signOut() async {
    emit(const AuthLoading());

    final result = await _authRepo.signOut();

    result.fold(
      (failure) => emit(AuthError(_mapFailureMessage(failure))),
      (_) => emit(const AuthSignedOut()),
    );
  }

  // ✅ تحويل الـ failure لرسالة عربية
  String _mapFailureMessage(AuthFailure failure) => failure.message;
}
