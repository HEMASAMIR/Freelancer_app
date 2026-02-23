import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freelancer/features/auth/data/repos/auth_repo.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;

  AuthCubit(this.authRepo) : super(AuthInitial());

  Future<void> signUpUser({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    final result = await authRepo.signUp(
      name: name,
      email: email,
      password: password,
    );

    result.fold(
      (failure) => emit(AuthFailure(errMessage: failure.errMessage)),
      (userModel) => emit(AuthSuccess(user: userModel)),
    );
  }
}
