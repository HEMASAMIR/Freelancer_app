import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freelancer/features/auth/data/repos/auth_repo.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_cubit.dart';
import 'identity_verification_state.dart';

class IdentityVerificationCubit extends Cubit<IdentityVerificationState> {
  final AuthRepo _authRepo;
  final AuthCubit _authCubit; // To trigger a refresh of the user metadata

  IdentityVerificationCubit(this._authRepo, this._authCubit) : super(IdentityVerificationInitial());

  Future<void> submitDocuments() async {
    emit(IdentityVerificationSubmitting());
    
    // Simulate some photo processing/uploading delay
    await Future.delayed(const Duration(seconds: 2));

    final result = await _authRepo.updateMetadata({
      'identity_status': 'pending',
      'is_identity_verified': false,
    });

    result.fold(
      (error) => emit(IdentityVerificationError(error.message)),
      (user) {
        // Refresh AuthCubit state with the updated user
        _authCubit.getUserInfo();
        emit(IdentityVerificationPending());
      },
    );
  }

  void checkStatus() {
    final user = _authRepo.getCurrentUser();
    if (user != null) {
      final status = user.userMetadata['identity_status'] as String?;
      if (status == 'pending') {
        emit(IdentityVerificationPending());
      } else if (status == 'verified') {
        emit(IdentityVerificationSuccess());
      } else {
        emit(IdentityVerificationInitial());
      }
    }
  }
}
