import 'package:dio/dio.dart';
import 'package:freelancer/features/favourite/data/fav_repos/fav_repo.dart';
import 'package:freelancer/features/favourite/data/fav_repos/fav_repo_impl.dart';
import 'package:freelancer/features/favourite/logic/cubit/fav_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:freelancer/core/constant/constant.dart';

// Auth
import 'package:freelancer/features/auth/data/repos/auth_repo.dart';
import 'package:freelancer/features/auth/data/repos/auth_repo_impl.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_cubit.dart';
import 'package:dio/dio.dart';
import 'package:freelancer/features/favourite/data/fav_repos/fav_repo.dart';
import 'package:freelancer/features/favourite/data/fav_repos/fav_repo_impl.dart';
import 'package:freelancer/features/favourite/logic/cubit/fav_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:freelancer/core/constant/constant.dart';

// Auth
import 'package:freelancer/features/auth/data/repos/auth_repo.dart';
import 'package:freelancer/features/auth/data/repos/auth_repo_impl.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_cubit.dart';

// Search
import 'package:freelancer/features/search/data/repos/search_repo.dart';
import 'package:freelancer/features/search/data/repos/search_repo_impl.dart';
import 'package:freelancer/features/search/logic/search_cubit/cubit/search_cubit.dart';

// Trips
import 'package:freelancer/features/trips/data/repos/trips_repo.dart';
import 'package:freelancer/features/trips/data/repos/trips_repo_impl.dart';
import 'package:freelancer/features/trips/logic/cubit/trips_cubit.dart';

// Bookings
import 'package:freelancer/features/bookings/data/repos/bookings_repo.dart';
import 'package:freelancer/features/bookings/data/repos/bookings_repo_impl.dart';
import 'package:freelancer/features/bookings/logic/cubit/bookings_cubit.dart';

// Payment
import 'package:freelancer/features/payment/data/repos/payment_repo.dart';
import 'package:freelancer/features/payment/data/repos/payment_repo_impl.dart';
import 'package:freelancer/features/payment/logic/cubit/payment_cubit.dart';

// Admin/Host
import 'package:freelancer/features/admin/data/repos/host_listings_repo.dart';
import 'package:freelancer/features/admin/data/repos/host_listings_repo_impl.dart';
import 'package:freelancer/features/admin/logic/host_listings_cubit.dart';
import 'package:freelancer/features/admin/data/repos/wallet_repo.dart';
import 'package:freelancer/features/admin/data/repos/wallet_repo_impl.dart';
import 'package:freelancer/features/admin/logic/wallet_cubit.dart';

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
        baseUrl: SupabaseKeys.restBaseUrl,
        headers: {
          'apikey': SupabaseKeys.supabaseAnonKey,
          'Authorization': 'Bearer ${SupabaseKeys.supabaseAnonKey}',
          'Content-Type': 'application/json',
          'Prefer': 'return=representation',
        },
      ),
    )..interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
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
  sl.registerLazySingleton<AuthCubit>(() => AuthCubit(authRepo: sl<AuthRepo>()));

  // --- Search Feature ---
  sl.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<SearchCubit>(() => SearchCubit(sl<SearchRepository>()));

  // --- Favorites Feature ---
  sl.registerLazySingleton<FavoriteRepository>(
    () => FavoriteRepositoryImpl(sl<SupabaseClient>(), sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<FavCubit>(() => FavCubit(sl<FavoriteRepository>()));

  // --- Trips Feature ---
  sl.registerLazySingleton<TripsRepository>(
    () => TripsRepositoryImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<TripsCubit>(() => TripsCubit(sl<TripsRepository>()));

  // --- Bookings Feature ---
  sl.registerLazySingleton<BookingsRepository>(
    () => BookingsRepositoryImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<BookingsCubit>(() => BookingsCubit(sl<BookingsRepository>()));

  // --- Payment Feature ---
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(supabase: sl<SupabaseClient>()),
  );
  sl.registerLazySingleton<PaymentCubit>(() => PaymentCubit(sl<PaymentRepository>()));

  // --- Admin/Host Feature ---
  sl.registerLazySingleton<HostListingsRepository>(
    () => HostListingsRepositoryImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<HostListingsCubit>(
    () => HostListingsCubit(repository: sl<HostListingsRepository>()),
  );

  // --- Wallet Feature ---
  sl.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<WalletCubit>(
    () => WalletCubit(sl<WalletRepository>()),
  );
}
