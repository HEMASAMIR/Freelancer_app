import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freelancer/core/di/service_locator.dart';
import 'package:freelancer/core/services/admin_email_service.dart';
import 'package:freelancer/features/auth/data/repos/auth_repo.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_cubit.dart';
import 'identity_verification_state.dart';

class IdentityVerificationCubit extends Cubit<IdentityVerificationState> {
  final AuthRepo _authRepo;
  final AuthCubit _authCubit;

  IdentityVerificationCubit(this._authRepo, this._authCubit)
      : super(IdentityVerificationInitial());

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
        _authCubit.getUserInfo();
        emit(IdentityVerificationPending());
      },
    );
  }

  void checkStatus() {
    final user = _authRepo.getCurrentUser();
    if (user == null) return;

    // ✅ الـ Admin دايماً verified — مش محتاج يعدي على verification
    final adminService = sl<AdminEmailService>();
    if (adminService.isAdmin(user.email)) {
      emit(IdentityVerificationSuccess());
      return;
    }

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
