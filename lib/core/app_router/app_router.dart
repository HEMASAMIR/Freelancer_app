import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_cubit.dart';
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

// ✅ الشاشتين الجديدتين
// import 'package:freelancer/features/account/presentation/view/personal_info_screen.dart'; // ← عدّل المسار حسب مشروعك

class AppRouter {
  static Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: sl<AuthCubit>(),
            child: const LoginView(),
          ),
        );

      case AppRoutes.signUp:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: sl<AuthCubit>(),
            child: const SignUpView(),
          ),
        );

      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
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
      // ✅ Host Dashboard — صفحة الإيرادات والمعاملات للـ Host/User العادي
      case AppRoutes.hostDashboard:
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
                    icon: const Icon(Icons.menu_rounded, color: AppColors.ink),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                ),
                actions: [
                  Builder(
                    builder: (ctx) => IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.ink,
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                      tooltip: 'Back',
                    ),
                  ),
                ],
                title: const Text(
                  'Overview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
              body: const SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: EarningsBalanceView(),
                ),
              ),
              bottomNavigationBar: _buildGlobalFooter(),
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

  static Widget _buildGlobalFooter() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF6F1E6),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(color: AppColors.dividerGrey, height: 1),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 24,
            runSpacing: 12,
            children: [
              Text(
                '© 2026 QuickIn, Inc.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.ink.withValues(alpha: 0.7),
                ),
              ),
              _footerTextButton('Terms'),
              const Text('·', style: TextStyle(color: AppColors.greyText)),
              _footerTextButton('Sitemap'),
              const Text('·', style: TextStyle(color: AppColors.greyText)),
              _footerTextButton('Privacy'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  'https://flagcdn.com/w40/eg.png',
                  height: 24,
                  width: 24,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.public, size: 24, color: AppColors.greyText),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '\$ EGP',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  static Widget _footerTextButton(String text) {
    return InkWell(
      onTap: () {},
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.ink.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

