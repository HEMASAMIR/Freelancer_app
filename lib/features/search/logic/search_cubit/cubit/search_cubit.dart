import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freelancer/features/search/data/repos/search_repo.dart';
import 'package:freelancer/features/search/data/search_model/search_params_model.dart';
import 'package:freelancer/features/search/logic/search_cubit/cubit/search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchRepository _searchRepository;

  SearchCubit(this._searchRepository) : super(SearchInitial());

  // 1. وظيفة البحث عن القوائم (Search)
  Future<void> getListings({required SearchParamsModel params}) async {
    emit(SearchLoading());

    print('🔍 [SearchCubit] جاري البحث بـ Params: ${params.toJson()}');

    final result = await _searchRepository.searchListings(params);

    result.fold(
      (failure) {
        print('❌ [SearchCubit] فشل البحث: $failure');
        emit(SearchError(failure));
      },
      (listings) {
        print('✅ [SearchCubit] نجاح البحث: تم إيجاد ${listings.length} عنصر');
        emit(SearchSuccess(listings: listings));
      },
    );
  }

  // 2. وظيفة جلب تفاصيل عقار محدد (Details)
  Future<void> getListingDetails({required String id}) async {
    // بنعمل Emit لحالة لودينج خاصة بالتفاصيل عشان الـ UI يعرف يفرق
    emit(ListingDetailsLoading());

    print('ℹ️ [SearchCubit] جاري جلب تفاصيل الـ ID: $id');

    final result = await _searchRepository.getListingDetails(id);

    result.fold(
      (failure) {
        print('❌ [SearchCubit] فشل جلب التفاصيل: $failure');
        emit(ListingDetailsError(failure));
      },
      (listing) {
        print('✅ [SearchCubit] تم جلب بيانات العقار بنجاح: ${listing.title}');
        emit(ListingDetailsSuccess(listing: listing));
      },
    );
  }
}
