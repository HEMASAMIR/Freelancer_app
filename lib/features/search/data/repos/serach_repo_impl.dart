import 'package:freelancer/features/search/data/repos/search_repo.dart';
import 'package:freelancer/features/search/data/search_model/search_params_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dartz/dartz.dart';
// تأكد من استيراد الملفات دي صح حسب مشروعك
import 'package:freelancer/core/failure/errors.dart';
import 'package:freelancer/features/search/data/search_model/search_result_model.dart';

// search_repository_impl.dart ✅
class SearchRepositoryImpl implements SearchRepository {
  final SupabaseClient _supabase;

  const SearchRepositoryImpl(this._supabase);

  @override
  Future<Either<Failure, List<SearchResultModel>>> searchListings(
    SearchParamsModel params,
  ) async {
    try {
      final response = await _supabase.rpc(
        'search_listings',
        params: params.toJson(),
      );

      if (response == null) return const Right([]);

      final results = (response as List)
          .map(
            (item) => SearchResultModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();

      return Right(results);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
