import 'package:dio/dio.dart';
import 'package:freelancer/features/favourite/data/fav_repos/fav_repo.dart';
import 'package:freelancer/features/favourite/data/fav_repos/fav_repo_impl.dart';
import 'package:freelancer/features/favourite/logic/cubit/fav_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Auth
import 'package:freelancer/features/auth/data/repos/auth_repo.dart';
import 'package:freelancer/features/auth/data/repos/auth_repo_impl.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_cubit.dart';

// Search
import 'package:freelancer/features/search/data/repos/search_repo.dart';
import 'package:freelancer/features/search/data/repos/serach_repo_impl.dart';
import 'package:freelancer/features/search/logic/search_cubit/cubit/search_cubit.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // ------------------------------------------------------------------
  // 1. External (المكتبات الخارجية)
  // ------------------------------------------------------------------

  // SharedPreferences (لازم getInstance الأول)
  final sharedPrefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPrefs);

  // Supabase Client
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // Dio Client
  sl.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        baseUrl: 'https://xpvrgdpsvffmttlwwfuo.supabase.co/rest/v1/',
        headers: {
          'apikey': 'sb_publishable_aCMcsxno9Z3X5O3ktGQ4VQ_IPqpp53z',
          'Authorization':
              'Bearer sb_publishable_aCMcsxno9Z3X5O3ktGQ4VQ_IPqpp53z',
          'Content-Type': 'application/json',
          'Prefer': 'return=representation',
        },
      ),
    ),
  );

  // ------------------------------------------------------------------
  // 2. Features (المميزات)
  // ------------------------------------------------------------------

  // --- Auth Feature ---
  sl.registerLazySingleton<AuthRepo>(
    () => AuthRepoImpl(supabase: sl<SupabaseClient>()),
  );
  sl.registerFactory<AuthCubit>(() => AuthCubit(authRepo: sl<AuthRepo>()));

  // --- Search Feature ---
  sl.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(dio: sl<Dio>()),
  );
  sl.registerFactory<SearchCubit>(() => SearchCubit(sl<SearchRepository>()));

  // --- Favorites Feature ---
  sl.registerLazySingleton<FavoriteRepository>(
    () => FavoriteRepositoryImpl(sl<SharedPreferences>()),
  );

  // Cubit (Factory عشان يتكريت منه نسخة جديدة مع كل صفحة لو محتاج)
  sl.registerFactory<FavCubit>(() => FavCubit(sl<FavoriteRepository>()));
}
