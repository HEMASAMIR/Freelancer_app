import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freelancer/core/app_router/routes.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/core/di/service_locator.dart';
import 'package:freelancer/features/admin/admin/presentation/view/admin_dashboard.dart';
import 'package:freelancer/features/admin/admin/presentation/view/earrnings_balance.dart';
import 'package:freelancer/features/admin/admin/presentation/view/identify_screen.dart';
import 'package:freelancer/features/admin/logic/admin_management_cubit.dart';
import 'package:freelancer/features/admin/logic/wallet_cubit.dart';
import 'package:freelancer/features/host/logic/cubit/host_cubit.dart';
import 'package:freelancer/features/admin/logic/host_listings_cubit.dart';
import 'package:freelancer/features/account/logic/cubit/account_cubit.dart';
import 'package:freelancer/features/auth/logic/cubit/auth_cubit.dart';
import 'package:freelancer/features/auth/view/presentation/view/login_redirect_screen.dart';
import 'package:freelancer/features/auth/view/presentation/view/login_view.dart';
import 'package:freelancer/features/auth/view/presentation/view/sign_up_view.dart';
import 'package:freelancer/features/bookings/logic/cubit/bookings_cubit.dart';
import 'package:freelancer/features/favourite/presentation/view/favourite.dart';
import 'package:freelancer/features/favourite/presentation/view/wishlist_screen.dart';
import 'package:freelancer/features/account/presentation/account_info.dart';
import 'package:freelancer/features/account/presentation/security_screen.dart';
import 'package:freelancer/features/home/presentation/view/home.dart';
import 'package:freelancer/features/home/presentation/widget/custom_drawer.dart';
import 'package:freelancer/features/host/presentation/host_listing.dart';
import 'package:freelancer/features/identity_verification/logic/identity_verification_cubit.dart';
import 'package:freelancer/features/payment/logic/cubit/payment_cubit.dart';
import 'package:freelancer/features/search/data/search_model/search_params_model.dart';
import 'package:freelancer/features/search/logic/search_cubit/cubit/search_cubit.dart';
import 'package:freelancer/features/search/presentation/view/search_details.dart';
import 'package:freelancer/features/splash/presentation/view/splash.dart';
import 'package:freelancer/features/search/presentation/view/search_result_screen.dart';
import 'package:freelancer/features/search/data/search_model/listing_model.dart';
import 'package:freelancer/features/favourite/logic/cubit/fav_cubit.dart';
import 'package:freelancer/features/trips/presentation/view/trips.dart';
import 'package:freelancer/features/account/logic/security_cubit.dart';
import 'package:freelancer/features/bookings/presentation/view/confirm_booking_screen.dart';
import 'package:freelancer/features/notifications/presentation/notifications_screen.dart';
import 'package:freelancer/features/notifications/logic/host_notification_cubit.dart';
import 'package:freelancer/features/account/presentation/notification_preferences_screen.dart';
import 'package:freelancer/features/host/presentation/dashboard_overview.dart';
import 'package:freelancer/features/auth/view/presentation/view/magic_link_view.dart';

// ✅ الشاشتين الجديدتين

class AppRouter {
  // فاد transition كريم بدون شاشة سودا
  static Route<T> _fadeRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
    );
  }

  static Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRoutes.login:
        return PageRouteBuilder(
          opaque: false,
          pageBuilder: (_, __, ___) => BlocProvider.value(
            value: sl<AuthCubit>(),
            child: const LoginView(),
          ),
        );

      case AppRoutes.loginRedirect:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: sl<AuthCubit>()),
              BlocProvider.value(value: sl<FavCubit>()),
            ],
            child: const LoginRedirectScreen(),
          ),
        );

      case AppRoutes.signUp:
        return PageRouteBuilder(
          opaque: false,
          pageBuilder: (_, __, ___) => BlocProvider.value(
            value: sl<AuthCubit>(),
            child: const SignUpView(),
          ),
        );

      case AppRoutes.home:
        // نستخدم fade route عشان مافيش شاشة سودا بين السبلاش والهوم
        return _fadeRoute(
          MultiBlocProvider(
            providers: [
              BlocProvider.value(value: sl<AuthCubit>()),
              BlocProvider.value(value: sl<FavCubit>()..loadFavorites()),
              BlocProvider.value(value: sl<BookingsCubit>()),
            ],
            child: const HomeScreen(),
          ),
        );

      case AppRoutes.searchResult:
        final args = settings.arguments;
        return MaterialPageRoute(
          builder: (context) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: sl<AuthCubit>()),
              BlocProvider.value(value: sl<FavCubit>()..loadFavorites()),
              BlocProvider(create: (context) => sl<SearchCubit>()),
            ],
            child: SearchResultScreen(
              params: args is SearchParamsModel ? args : SearchParamsModel(),
            ),
          ),
        );

      case AppRoutes.favourites:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: sl<AuthCubit>()),
              BlocProvider.value(value: sl<FavCubit>()..loadFavorites()),
            ],
            child: const FavoritesScreen(),
          ),
        );

      case AppRoutes.security:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<SecurityCubit>(),
            child: const SecurityScreen(),
          ),
        );

      case AppRoutes.adminDashboard:
        final view = settings.arguments as String? ?? 'Dashboard';
        return _fadeRoute(
          MultiBlocProvider(
            providers: [
              BlocProvider.value(value: sl<AuthCubit>()),
              BlocProvider.value(value: sl<BookingsCubit>()),
              BlocProvider.value(value: sl<FavCubit>()),
              BlocProvider.value(value: sl<HostListingsCubit>()),
              BlocProvider.value(value: sl<HostCubit>()),
              BlocProvider.value(value: sl<WalletCubit>()),
              BlocProvider(create: (_) => sl<AdminManagementCubit>()),
            ],
            child: AdminOverviewScreen(initialView: view),
          ),
        );

      case AppRoutes.adminOverview:
        final view = settings.arguments as String? ?? 'Dashboard';
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: sl<AuthCubit>()),
              BlocProvider.value(value: sl<BookingsCubit>()),
              BlocProvider.value(value: sl<FavCubit>()),
              BlocProvider.value(value: sl<HostListingsCubit>()),
              BlocProvider.value(value: sl<HostCubit>()),
              BlocProvider.value(value: sl<WalletCubit>()),
              BlocProvider(create: (_) => sl<AdminManagementCubit>()),
            ],
            child: AdminOverviewScreen(initialView: view),
          ),
        );

      case AppRoutes.trips:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: sl<AuthCubit>()),
              BlocProvider.value(value: sl<BookingsCubit>()),
              BlocProvider.value(value: sl<PaymentCubit>()),
            ],
            child: const TripsScreen(),
          ),
        );

      case AppRoutes.wishlists:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: sl<AuthCubit>()),
              BlocProvider.value(value: sl<FavCubit>()..loadWishlists()),
            ],
            child: const WishlistsScreen(),
          ),
        );

      case AppRoutes.details:
        final listing = settings.arguments;
        if (listing is! ListingModel) return _errorRoute();
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: sl<AuthCubit>()),
              BlocProvider.value(value: sl<FavCubit>()),
              BlocProvider.value(value: sl<BookingsCubit>()),
            ],
            child: SearchDetails(listing: listing),
          ),
        );

      // ✅ شاشة Identity Verification
      case AppRoutes.identityVerification:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: sl<AuthCubit>()),
              BlocProvider(create: (_) => sl<IdentityVerificationCubit>()),
            ],
            child: const IdentityVerificationScreen(),
          ),
        );

      case AppRoutes.account:
        final _ = settings.arguments as int? ?? 0;
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: sl<AuthCubit>()),
              BlocProvider(create: (_) => sl<AccountCubit>()),
            ],
            child: AccountScreen(),
          ),
        );
      case AppRoutes.myListings:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: sl<AuthCubit>()),
              BlocProvider.value(value: sl<HostListingsCubit>()),
            ],
            child: HostListingsView(
              onShowDetails: (listing) {},
            ),
          ),
        );
      // ✅ Host Dashboard Overview Screen
      case AppRoutes.hostDashboard:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: sl<AuthCubit>()),
            ],
            child: const DashboardOverviewScreen(),
          ),
        );

      // ✅ Earnings & Balance Screen
      case AppRoutes.earningsBalance:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: sl<AuthCubit>()),
              BlocProvider.value(value: sl<WalletCubit>()),
            ],
            child: Scaffold(
              backgroundColor: AppColors.backgroundCream,
              drawer: const SideDrawer(),
              appBar: AppBar(
                backgroundColor: AppColors.backgroundCream,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(Icons.menu_rounded, color: AppColors.inkBlack),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                ),
                actions: [
                  Builder(
                    builder: (ctx) => IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.inkBlack,
                        size: 20,
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                      tooltip: 'Back',
                    ),
                  ),
                ],
                title: const Text(
                  'Earnings & Balance',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkBlack,
                  ),
                ),
              ),
              body: const SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: EarningsBalanceView(),
                ),
              ),
            ),
          ),
        );

      case AppRoutes.confirmBooking:
        final cbArgs = settings.arguments;
        if (cbArgs is! ConfirmBookingArgs) return _errorRoute();
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: sl<AuthCubit>()),
              BlocProvider.value(value: sl<BookingsCubit>()),
            ],
            child: ConfirmBookingScreen(args: cbArgs),
          ),
        );

      case AppRoutes.notifications:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: sl<HostNotificationCubit>(),
            child: const NotificationsScreen(),
          ),
        );

      case AppRoutes.notificationPreferences:
        return MaterialPageRoute(
          builder: (_) => const NotificationPreferencesScreen(),
        );

      case AppRoutes.magicLink:
        return PageRouteBuilder(
          opaque: false,
          pageBuilder: (_, __, ___) => BlocProvider.value(
            value: sl<AuthCubit>(),
            child: const MagicLinkView(),
          ),
        );

      default:
        return _errorRoute();
    }
  }

  static Route _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Page not found!')),
      ),
    );
  }
}

