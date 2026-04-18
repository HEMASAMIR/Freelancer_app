import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:freelancer/features/trips/logic/cubit/trips_cubit.dart';
import 'package:freelancer/features/trips/logic/cubit/trips_state.dart';
import 'package:freelancer/features/trips/data/repos/trips_repo.dart';
import 'package:freelancer/features/trips/data/models/trip_model.dart';

class FakeTripsRepository implements TripsRepository {
  bool failMode = false;
  final List<TripModel> stubTrips = [TripModel(id: '1', status: 'upcoming')];

  @override
  Future<Either<String, List<TripModel>>> getUserTrips(String userId) async {
    if (failMode) return left('Fetch Failed');
    return right(stubTrips);
  }
}

void main() {
  late FakeTripsRepository fakeRepo;
  late TripsCubit tripsCubit;

  setUp(() {
    fakeRepo = FakeTripsRepository();
    tripsCubit = TripsCubit(fakeRepo);
  });

  tearDown(() => tripsCubit.close());

  test('initial state is TripsInitial', () {
    expect(tripsCubit.state, isA<TripsInitial>());
  });

  blocTest<TripsCubit, TripsState>(
    'emits [TripsLoading, TripsLoaded] when getUserTrips succeeds',
    build: () => tripsCubit,
    act: (cubit) => cubit.fetchUserTrips('user1'),
    expect: () => [
      isA<TripsLoading>(),
      isA<TripsLoaded>(),
    ],
  );

  blocTest<TripsCubit, TripsState>(
    'emits [TripsLoading, TripsError] when getUserTrips fails',
    build: () {
      fakeRepo.failMode = true;
      return tripsCubit;
    },
    act: (cubit) => cubit.fetchUserTrips('user1'),
    expect: () => [
      isA<TripsLoading>(),
      isA<TripsError>().having((s) => s.message, 'message', 'Fetch Failed'),
    ],
  );
}
