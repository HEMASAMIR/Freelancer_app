import 'package:equatable/equatable.dart';
import 'package:freelancer/features/auth/data/models/user_model.dart';

abstract class AuthCubitState extends Equatable {
  const AuthCubitState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthCubitState {
  const AuthInitial();
}

class AuthLoading extends AuthCubitState {
  const AuthLoading();
}

class AuthGoogleLoading extends AuthCubitState {
  const AuthGoogleLoading();
}

class GoogleAuthCubitState extends AuthCubitState {
  const GoogleAuthCubitState();
}

class AuthSuccess extends AuthCubitState {
  final UserModel user;
  const AuthSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

// ✅ حالة الفشل (بتاخد رسالة الخطأ)
class AuthError extends AuthCubitState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// ✅ حالة تسجيل الخروج بنجاح
class AuthSignedOut extends AuthCubitState {
  const AuthSignedOut();
}

// ✅ زود الـ state ده
class AuthAdminSuccess extends AuthCubitState {
  final UserModel user;
  const AuthAdminSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthPasswordRecovery extends AuthCubitState {
  final UserModel user;
  const AuthPasswordRecovery(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthRecoverSuccess extends AuthCubitState {
  const AuthRecoverSuccess();
}

class AuthUpdatePasswordSuccess extends AuthCubitState {
  const AuthUpdatePasswordSuccess();
}

class AuthMfaEnrolled extends AuthCubitState {
  final Map<String, dynamic> factorData;
  const AuthMfaEnrolled(this.factorData);

  @override
  List<Object?> get props => [factorData];
}

class AuthMfaVerified extends AuthCubitState {
  const AuthMfaVerified();
}

class AuthTokenRefreshed extends AuthCubitState {
  const AuthTokenRefreshed();
}

// ─── Magic Link States ───────────────────────────────────────────────────────

/// Emitted while sending the magic link email or verifying the OTP.
class AuthMagicLinkLoading extends AuthCubitState {
  const AuthMagicLinkLoading();
}

/// Emitted after the magic link email is successfully dispatched.
/// [email] is kept so the OTP screen can display / pre-fill it.
class AuthMagicLinkSent extends AuthCubitState {
  final String email;
  const AuthMagicLinkSent(this.email);

  @override
  List<Object?> get props => [email];
}
