import 'package:dartz/dartz.dart';
import 'package:freelancer/features/search/data/repos/search_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/failure/errors.dart';
import '../search_model/search_params_model.dart';
import '../search_model/search_result_model.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SupabaseClient _supabase;

  SearchRepositoryImpl(this._supabase);

  @override
  Future<Either<Failure, List<SearchResultModel>>> searchListings(
    SearchParamsModel params,
  ) async {
    try {
      // ركز هنا: بنحول الـ "Best Offers" لـ Boolean عشان الـ RPC يفهمها
      final response = await _supabase.rpc(
        'search_listings',
        params: {
          'p_limit': params.limit,
          'p_offset': params.offset,
          'p_best_offer': params.location == "Best Offers" ? true : false,
          'p_locale': 'ar', // عشان يرجع العناوين بالعربي زي الـ JSON اللي بعته
          'p_location': params.location == "Best Offers"
              ? null
              : params.location,
          'p_guests': params.guests,
          'p_price_max': params.priceMax,
        },
      );

      final List<dynamic> data = response as List<dynamic>;

      // تحويل الـ JSON اللي راجع للموديل (اللي هبعتهولك الخطوة الجاية)
      final results = data
          .map((item) => SearchResultModel.fromJson(item))
          .toList();

      return Right(results);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure("خطأ غير متوقع: $e"));
    }
  }
}
