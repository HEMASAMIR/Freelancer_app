import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:freelancer/core/failure/errors.dart';
import 'package:freelancer/features/search/data/search_model/search_params_model.dart';
import 'package:freelancer/features/search/data/search_model/search_result_model.dart';

abstract class SearchRepository {
  Future<Either<Failure, List<SearchResultModel>>> searchListings(
    SearchParamsModel params,
  );
}
