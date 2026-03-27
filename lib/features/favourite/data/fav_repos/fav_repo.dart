import 'package:dartz/dartz.dart';
import 'package:freelancer/core/error/errors.dart';

abstract class FavoriteRepository {
  List<String> getFavorites();
  Future<Either<Failure, Unit>> toggle(String id);
}