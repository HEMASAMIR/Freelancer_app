import 'package:equatable/equatable.dart';
import '../../data/models/account_models.dart';

abstract class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object?> get props => [];
}

class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {}

class AccountProfileLoaded extends AccountState {
  final AccountProfileModel profile;
  const AccountProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class AccountSuccess extends AccountState {
  final String message;
  const AccountSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AccountError extends AccountState {
  final String message;
  const AccountError(this.message);

  @override
  List<Object?> get props => [message];
}
