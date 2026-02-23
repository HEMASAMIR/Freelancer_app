// lib/core/di/service_locator.dart

import 'package:freelancer/features/auth/data/repos/auth_repo.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:freelancer/features/auth/data/repos/auth_repo_impl.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_cubit.dart';

// ✅ sl اختصار ServiceLocator
final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // ✅ Supabase Client
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // ✅ Auth Repo
  sl.registerLazySingleton<AuthRepo>(
    () => AuthRepoImpl(supabase: sl<SupabaseClient>()),
  );

  // ✅ Auth Cubit - registerFactory عشان كل شاشة تاخد instance جديد
  sl.registerFactory<AuthCubit>(() => AuthCubit(authRepo: sl<AuthRepo>()));
}
