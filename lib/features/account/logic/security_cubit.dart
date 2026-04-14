import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:freelancer/features/auth/data/repos/auth_repo.dart';

abstract class SecurityState extends Equatable {
  const SecurityState();
  @override
  List<Object?> get props => [];
}

class SecurityInitial extends SecurityState {}

class SecurityLoading extends SecurityState {}

class PasswordUpdateSuccess extends SecurityState {}

class MFASetupInitiated extends SecurityState {
  final String qrCodeUri;
  final String secret;
  final String factorId;

  const MFASetupInitiated({
    required this.qrCodeUri,
    required this.secret,
    required this.factorId,
  });

  @override
  List<Object?> get props => [qrCodeUri, secret, factorId];
}

class MFAVerifiedSuccess extends SecurityState {}

class SecurityError extends SecurityState {
  final String message;
  const SecurityError(this.message);

  @override
  List<Object?> get props => [message];
}

class SecurityCubit extends Cubit<SecurityState> {
  final AuthRepo _authRepo;

  SecurityCubit({required AuthRepo authRepo}) : _authRepo = authRepo, super(SecurityInitial());

  Future<void> updatePassword(String newPassword) async {
    emit(SecurityLoading());
    final result = await _authRepo.updatePassword(newPassword: newPassword);
    
    result.fold(
      (failure) => emit(SecurityError(failure.message)),
      (_) => emit(PasswordUpdateSuccess()),
    );
  }

  Future<void> enrollMFA() async {
    emit(SecurityLoading());
    final result = await _authRepo.enrollMFA();
    
    result.fold(
      (failure) => emit(SecurityError(failure.message)),
      (data) {
        final factorId = data['id']?.toString() ?? '';
        final totp = data['totp'] as Map<String, dynamic>? ?? {};
        final secret = totp['secret']?.toString() ?? '';
        final uri = totp['uri']?.toString() ?? '';
        
        emit(MFASetupInitiated(
          qrCodeUri: uri,
          secret: secret,
          factorId: factorId,
        ));
      },
    );
  }

  Future<void> verifyMFA({
    required String factorId,
    required String challengeId,
    required String code,
  }) async {
    emit(SecurityLoading());
    final result = await _authRepo.verifyMFA(
      factorId: factorId,
      challengeId: challengeId,
      code: code,
    );
    
    result.fold(
      (failure) => emit(SecurityError(failure.message)),
      (_) => emit(MFAVerifiedSuccess()),
    );
  }
}
