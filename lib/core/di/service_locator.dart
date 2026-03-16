import 'package:freelancer/features/auth/data/repos/auth_repo.dart';
import 'package:freelancer/features/auth/data/repos/auth_repo_impl.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_cubit.dart';
import 'package:freelancer/features/search/data/repos/search_repo.dart';
import 'package:freelancer/features/search/data/repos/serach_repo_impl.dart';
import 'package:freelancer/features/search/logic/search_cubit/cubit/search_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // ── Supabase ───────────────────────────────────────────────
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // ── Auth ───────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepo>(
    () => AuthRepoImpl(supabase: sl<SupabaseClient>()),
  );
  sl.registerFactory<AuthCubit>(() => AuthCubit(authRepo: sl<AuthRepo>()));

  // ── Search ─────────────────────────────────────────────────
  sl.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(sl<SupabaseClient>()),
  );
  sl.registerFactory<SearchCubit>(() => SearchCubit(sl<SearchRepository>()));
}
