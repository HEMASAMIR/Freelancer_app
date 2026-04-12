import 'package:dartz/dartz.dart';
import '../models/trip_model.dart';

abstract class TripsRepository {
  Future<Either<String, List<TripModel>>> getUserTrips(String userId);
}
