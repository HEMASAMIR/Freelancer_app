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

/// Holds the 4 overview stats shown on the admin dashboard
class AdminDashboardStatsLoaded extends AdminManagementState {
  final int totalListings;
  final int totalUsers;
  final int bookingsThisMonth;
  final int pendingApprovals;

  const AdminDashboardStatsLoaded({
    required this.totalListings,
    required this.totalUsers,
    required this.bookingsThisMonth,
    required this.pendingApprovals,
  });

  @override
  List<Object?> get props => [
        totalListings,
        totalUsers,
        bookingsThisMonth,
        pendingApprovals,
      ];
}
