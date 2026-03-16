import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freelancer/features/search/data/repos/search_repo.dart';
import 'package:freelancer/features/search/data/search_model/search_params_model.dart';
import 'package:freelancer/features/search/logic/search_cubit/cubit/search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchRepository _searchRepository;

  SearchCubit(this._searchRepository) : super(SearchInitial());

  // التعديل هنا: بنستقبل الـ Model كـ Named Parameter
  Future<void> getListings({required SearchParamsModel params}) async {
    emit(SearchLoading());

    print('🔍 [SearchCubit] جاري البحث بـ Params: ${params.toJson()}');

    // نداء الـ Repository بالـ params اللي مبعوتة جاهزة
    final result = await _searchRepository.searchListings(params);

    result.fold(
      (failure) {
        print('❌ [SearchCubit] فشل البحث: ${failure.message}');
        emit(SearchError(failure.message));
      },
      (listings) {
        print('✅ [SearchCubit] نجاح: تم إيجاد ${listings.length} عنصر');
        emit(SearchSuccess(listings: listings));
      },
    );
  }
}
