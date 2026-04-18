import 'package:equatable/equatable.dart';
import '../../data/models/booking_model.dart';

abstract class BookingsState extends Equatable {
  const BookingsState();

  @override
  List<Object> get props => [];
}

class BookingsInitial extends BookingsState {}

class BookingsLoading extends BookingsState {}

class BookingsSuccess extends BookingsState {
  final BookingModel booking;

  const BookingsSuccess(this.booking);

  @override
  List<Object> get props => [booking];
}

class BookingsError extends BookingsState {
  final String message;

  const BookingsError(this.message);

  @override
  List<Object> get props => [message];
}

class BookingsCancelled extends BookingsState {}

class BookingsConfirmed extends BookingsState {}

class BookingsListLoaded extends BookingsState {
  final List<BookingModel> bookings;

  const BookingsListLoaded(this.bookings);

  @override
  List<Object> get props => [bookings];
}
