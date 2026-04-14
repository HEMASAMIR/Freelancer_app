import 'package:dio/dio.dart';
import 'package:freelancer/features/admin/data/repos/wallet_repo.dart';
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

// Listing Wizard
import 'package:freelancer/features/listing_wizard/data/repos/listing_wizard_repo.dart';
import 'package:freelancer/features/listing_wizard/data/repos/listing_wizard_repo_impl.dart';
import 'package:freelancer/features/listing_wizard/logic/cubit/listing_wizard_cubit.dart';

// Host Management
import 'package:freelancer/features/host/data/repos/host_repo.dart';
import 'package:freelancer/features/host/data/repos/host_repo_impl.dart';
import 'package:freelancer/features/host/logic/cubit/host_cubit.dart';

// Guest Management
import 'package:freelancer/features/guest/data/repos/guest_repo.dart';
import 'package:freelancer/features/guest/data/repos/guest_repo_impl.dart';
import 'package:freelancer/features/guest/logic/cubit/guest_cubit.dart';

// Guest Bookings Management
import 'package:freelancer/features/guest_bookings/data/repos/guest_bookings_repo.dart';
import 'package:freelancer/features/guest_bookings/data/repos/guest_bookings_repo_impl.dart';
import 'package:freelancer/features/guest_bookings/logic/cubit/guest_bookings_cubit.dart';

// Account Management
import 'package:freelancer/features/account/data/repos/account_repo.dart';
import 'package:freelancer/features/account/data/repos/account_repo_impl.dart';
import 'package:freelancer/features/account/logic/cubit/account_cubit.dart';

// Wishlists Management
import 'package:freelancer/features/wishlists/data/repos/wishlists_repo.dart';
import 'package:freelancer/features/wishlists/data/repos/wishlists_repo_impl.dart';
import 'package:freelancer/features/wishlists/logic/cubit/wishlists_cubit.dart';

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
import 'package:freelancer/features/admin/data/repos/wallet_repo_impl.dart';
import 'package:freelancer/features/admin/logic/wallet_cubit.dart';

// Admin Management (Specialized APIs)
import 'package:freelancer/features/admin/data/admin_repo/admin_management_repo.dart';
import 'package:freelancer/features/admin/data/admin_repo_impl/admin_management_repo_impl.dart';
import 'package:freelancer/features/admin/logic/admin_management_cubit.dart';

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
    () =>
        Dio(
            BaseOptions(
              baseUrl: SupabaseKeys.restBaseUrl,
              headers: {
                'apikey': SupabaseKeys.supabaseAnonKey,
                'Authorization': 'Bearer ${SupabaseKeys.supabaseAnonKey}',
                'Content-Type': 'application/json',
                'Prefer': 'return=representation',
              },
            ),
          )
          ..interceptors.add(
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
  sl.registerLazySingleton<AuthCubit>(
    () => AuthCubit(authRepo: sl<AuthRepo>()),
  );

  // --- Search Feature ---
  sl.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<SearchCubit>(
    () => SearchCubit(sl<SearchRepository>()),
  );

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
  sl.registerLazySingleton<BookingsCubit>(
    () => BookingsCubit(sl<BookingsRepository>()),
  );

  // --- Payment Feature ---
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(supabase: sl<SupabaseClient>()),
  );
  sl.registerLazySingleton<PaymentCubit>(
    () => PaymentCubit(sl<PaymentRepository>()),
  );

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

  // --- Listing Wizard Feature ---
  sl.registerLazySingleton<ListingWizardRepository>(
    () => ListingWizardRepositoryImpl(
      dio: sl<Dio>(),
      supabase: sl<SupabaseClient>(),
    ),
  );
  sl.registerFactory<ListingWizardCubit>(
    () => ListingWizardCubit(sl<ListingWizardRepository>()),
  );

  // --- Host Management Feature ---
  sl.registerLazySingleton<HostRepository>(
    () => HostRepositoryImpl(dio: sl<Dio>()),
  );
  sl.registerFactory<HostCubit>(() => HostCubit(sl<HostRepository>()));

  // --- Guest Management Feature ---
  sl.registerLazySingleton<GuestRepository>(
    () => GuestRepositoryImpl(dio: sl<Dio>()),
  );
  sl.registerFactory<GuestCubit>(() => GuestCubit(sl<GuestRepository>()));

  // --- Guest Bookings Feature ---
  sl.registerLazySingleton<GuestBookingsRepository>(
    () => GuestBookingsRepositoryImpl(dio: sl<Dio>()),
  );
  sl.registerFactory<GuestBookingsCubit>(
    () => GuestBookingsCubit(sl<GuestBookingsRepository>()),
  );

  // --- Account Management Feature ---
  sl.registerLazySingleton<AccountRepository>(
    () => AccountRepositoryImpl(dio: sl<Dio>()),
  );
  sl.registerFactory<AccountCubit>(() => AccountCubit(sl<AccountRepository>()));

  // --- Wishlists Management Feature ---
  sl.registerLazySingleton<WishlistsRepository>(
    () => WishlistsRepositoryImpl(dio: sl<Dio>()),
  );
  sl.registerFactory<WishlistsCubit>(
    () => WishlistsCubit(sl<WishlistsRepository>()),
  );

  // --- Admin Management (Specialized APIs) ---
  sl.registerLazySingleton<AdminManagementRepository>(
    () => AdminManagementRepositoryImpl(dio: sl<Dio>()),
  );
  sl.registerFactory<AdminManagementCubit>(
    () => AdminManagementCubit(sl<AdminManagementRepository>()),
  );
}
