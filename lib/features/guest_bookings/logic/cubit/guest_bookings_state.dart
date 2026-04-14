import 'package:equatable/equatable.dart';
import '../../data/models/guest_booking_models.dart';

abstract class GuestBookingsState extends Equatable {
  const GuestBookingsState();

  @override
  List<Object?> get props => [];
}

class GuestBookingsInitial extends GuestBookingsState {}

class GuestBookingsLoading extends GuestBookingsState {}

class GuestBookingsLoaded extends GuestBookingsState {
  final List<GuestBookingDetailedModel> bookings;
  const GuestBookingsLoaded(this.bookings);

  @override
  List<Object?> get props => [bookings];
}

class GuestBookingsAvailabilityChecked extends GuestBookingsState {
  final bool isAvailable;
  const GuestBookingsAvailabilityChecked(this.isAvailable);

  @override
  List<Object?> get props => [isAvailable];
}

class GuestBookingsCommissionLoaded extends GuestBookingsState {
  final Map<String, dynamic> commissionData;
  const GuestBookingsCommissionLoaded(this.commissionData);

  @override
  List<Object?> get props => [commissionData];
}

class GuestBookingsSuccess extends GuestBookingsState {
  final String message;
  final GuestBookingDetailedModel? booking;
  const GuestBookingsSuccess(this.message, {this.booking});

  @override
  List<Object?> get props => [message, booking];
}

class GuestBookingsError extends GuestBookingsState {
  final String message;
  const GuestBookingsError(this.message);

  @override
  List<Object?> get props => [message];
}
