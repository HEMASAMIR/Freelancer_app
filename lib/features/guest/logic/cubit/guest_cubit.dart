import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repos/guest_repo.dart';
import 'guest_state.dart';

class GuestCubit extends Cubit<GuestState> {
  final GuestRepository _repository;

  GuestCubit(this._repository) : super(GuestInitial());

  Future<void> getMyTrips(String userId) async {
    emit(GuestLoading());
    final result = await _repository.getMyTrips(userId);
    result.fold(
      (error) => emit(GuestError(error)),
      (trips) => emit(GuestTripsLoaded(trips)),
    );
  }

  Future<void> getMyWishlists(String userId) async {
    emit(GuestLoading());
    final result = await _repository.getMyWishlists(userId);
    result.fold(
      (error) => emit(GuestError(error)),
      (wishlists) => emit(GuestWishlistsLoaded(wishlists)),
    );
  }
}
