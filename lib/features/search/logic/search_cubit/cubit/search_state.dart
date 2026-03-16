import 'package:freelancer/features/search/data/search_model/search_result_model.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchSuccess extends SearchState {
  final List<SearchResultModel> listings;
  SearchSuccess(this.listings);
}

class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}
