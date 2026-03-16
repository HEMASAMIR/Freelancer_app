import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freelancer/features/search/data/repos/search_repo.dart';
import 'package:freelancer/features/search/data/search_model/search_params_model.dart';
import 'package:freelancer/features/search/logic/search_cubit/cubit/search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchRepository searchRepository;

  SearchCubit(this.searchRepository) : super(SearchInitial());

  Future<void> getListings(SearchParamsModel params) async {
    debugPrint('🔍 [SearchCubit] getListings called');
    debugPrint('📦 [SearchCubit] params: ${params.toJson()}');

    emit(SearchLoading());
    debugPrint('⏳ [SearchCubit] Loading...');

    final result = await searchRepository.searchListings(params);

    result.fold(
      (failure) {
        debugPrint('❌ [SearchCubit] Error: ${failure.message}');
        emit(SearchError(failure.message));
      },
      (listings) {
        debugPrint(
          '✅ [SearchCubit] Success: ${listings.length} listings found',
        );
        if (listings.isNotEmpty) {
          debugPrint('📋 [SearchCubit] First listing: ${listings.first.title}');
        }
        emit(SearchSuccess(listings));
      },
    );
  }
}
