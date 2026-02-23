import 'package:freelancer/features/auth/model/auth_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserModel user;
  AuthSuccess({required this.user});
}

class AuthFailure extends AuthState {
  final String errMessage;
  AuthFailure({required this.errMessage});
}
