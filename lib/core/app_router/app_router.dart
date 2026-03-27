import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freelancer/core/app_router/routes.dart';
import 'package:freelancer/core/di/service_locator.dart';
import 'package:freelancer/features/admin/admin/presentaion/view/admin_dashboard.dart';
import 'package:freelancer/features/admin/admin/presentaion/view/admin_staff.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_cubit.dart';
import 'package:freelancer/features/auth/view/presentation/view/login_view.dart';
import 'package:freelancer/features/auth/view/presentation/view/sign_up_view.dart';
import 'package:freelancer/features/favourite/presentation/view/favourite.dart';
import 'package:freelancer/features/home/presentation/view/home.dart';
import 'package:freelancer/features/search/logic/search_cubit/cubit/search_cubit.dart';
import 'package:freelancer/features/splash/presentation/view/splash.dart';
import 'package:freelancer/features/search/presentation/view/search_result_screen.dart';
import 'package:freelancer/features/search/data/search_model/search_params_model.dart';
import 'package:freelancer/features/favourite/logic/cubit/fav_cubit.dart';

class AppRouter {
  static Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<AuthCubit>(),
            child: const LoginView(),
          ),
        );

      case AppRoutes.signUp:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<AuthCubit>(),
            child: const SignUpView(),
          ),
        );

      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: sl<FavCubit>()..loadFavorites(),
            child: const HomeScreen(),
          ),
        );

      case AppRoutes.searchResult:
        final args = settings.arguments;
        return MaterialPageRoute(
          builder: (context) => MultiBlocProvider(
            providers: [
              // 1. وفر الـ FavCubit الأول فوق الـ SearchCubit
              BlocProvider.value(value: sl<FavCubit>()..loadFavorites()),
              // 2. بعد كده وفر الـ SearchCubit
              BlocProvider(create: (context) => sl<SearchCubit>()),
            ],
            child: SearchResultScreen(
              params: args is SearchParamsModel ? args : SearchParamsModel(),
            ),
          ),
        );
      case AppRoutes.favourites:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: sl<FavCubit>()..loadFavorites(),
            child: const FavoritesScreen(),
          ),
        );

      case AppRoutes.admin:
        return MaterialPageRoute(builder: (_) => const StaffManagementScreen());

      case AppRoutes.adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminOverviewScreen());

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
