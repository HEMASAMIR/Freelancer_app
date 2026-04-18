import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

abstract class IdentityVerificationState extends Equatable {
  const IdentityVerificationState();

  @override
  List<Object?> get props => [];
}

class IdentityVerificationInitial extends IdentityVerificationState {}

class IdentityVerificationSubmitting extends IdentityVerificationState {}

class IdentityVerificationPending extends IdentityVerificationState {}

class IdentityVerificationSuccess extends IdentityVerificationState {}

class IdentityVerificationError extends IdentityVerificationState {
  final String message;
  const IdentityVerificationError(this.message);

  @override
  List<Object?> get props => [message];
}
