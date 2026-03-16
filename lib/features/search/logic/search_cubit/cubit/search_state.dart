import 'package:equatable/equatable.dart';
import 'package:freelancer/features/search/data/search_model/search_result_model.dart';

abstract class SearchState extends Equatable {
  const SearchState();
  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchSuccess extends SearchState {
  final List<SearchResultModel> listings;
  const SearchSuccess({required this.listings});

  @override
  List<Object?> get props => [listings];
}

class SearchError extends SearchState {
  final String message;
  const SearchError(this.message);

  @override
  List<Object?> get props => [message];
}
