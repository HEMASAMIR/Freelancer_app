import 'package:equatable/equatable.dart';

abstract class AdminManagementState extends Equatable {
  const AdminManagementState();

  @override
  List<Object?> get props => [];
}

class AdminManagementInitial extends AdminManagementState {}

class AdminManagementLoading extends AdminManagementState {}

class AdminManagementSuccess extends AdminManagementState {
  final String message;
  const AdminManagementSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminManagementError extends AdminManagementState {
  final String message;
  const AdminManagementError(this.message);

  @override
  List<Object?> get props => [message];
}
