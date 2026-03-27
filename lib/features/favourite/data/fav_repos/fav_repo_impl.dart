import 'package:dartz/dartz.dart';
import 'package:freelancer/core/error/errors.dart';
import 'package:freelancer/features/favourite/data/fav_repos/fav_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';



class FavoriteRepositoryImpl implements FavoriteRepository {
  final SharedPreferences prefs;

  FavoriteRepositoryImpl(this.prefs);

  @override
  List<String> getFavorites() {
    return prefs.getStringList('my_favs') ?? [];
  }

  @override
  Future<Either<Failure, Unit>> toggle(String id) async {
    try {
      List<String> favs = getFavorites();
      // بنعمل نسخة جديدة عشان نتجنب الـ reference issues
      List<String> updatedFavs = List.from(favs); 
      
      if (updatedFavs.contains(id)) {
        updatedFavs.remove(id);
      } else {
        updatedFavs.add(id);
      }
      
      await prefs.setStringList('my_favs', updatedFavs);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure()); 
    }
  }
}