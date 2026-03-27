import 'package:freelancer/features/search/data/search_model/listing_model.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

// --- حالات البحث (Search States) ---
class SearchLoading extends SearchState {}

class SearchSuccess extends SearchState {
  final List<ListingModel> listings;
  SearchSuccess({required this.listings});
}

class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}

// --- حالات التفاصيل (Details States) ---
class ListingDetailsLoading extends SearchState {}

class ListingDetailsSuccess extends SearchState {
  final ListingModel listing;
  ListingDetailsSuccess({required this.listing});
}

class ListingDetailsError extends SearchState {
  final String message;
  ListingDetailsError(this.message);
}
