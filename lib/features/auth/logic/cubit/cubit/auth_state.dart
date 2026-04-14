import 'package:equatable/equatable.dart';
import 'package:freelancer/features/auth/data/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthGoogleLoading extends AuthState {
  const AuthGoogleLoading();
}

class GoogleAuthState extends AuthState {
  const GoogleAuthState();
}

class AuthSuccess extends AuthState {
  final UserModel user;
  const AuthSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

// ✅ حالة الفشل (بتاخد رسالة الخطأ)
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// ✅ حالة تسجيل الخروج بنجاح
class AuthSignedOut extends AuthState {
  const AuthSignedOut();
}

// ✅ زود الـ state ده
class AuthAdminSuccess extends AuthState {
  final UserModel user;
  const AuthAdminSuccess(this.user);

  @override
  List<Object?> get props => [user];
}
