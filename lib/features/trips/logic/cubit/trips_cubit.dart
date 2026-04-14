import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repos/trips_repo.dart';
import 'trips_state.dart';

class TripsCubit extends Cubit<TripsState> {
  final TripsRepository repository;

  TripsCubit(this.repository) : super(TripsInitial());

  Future<void> fetchUserTrips(String userId) async {
    emit(TripsLoading());
    final result = await repository.getUserTrips(userId);

    result.fold(
      (error) => emit(TripsError(error)),
      (trips) => emit(TripsLoaded(trips)),
    );
  }

}
