import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freelancer/core/app_router/routes.dart';
import 'package:freelancer/features/auth/data/auth_repo_impl.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_cubit.dart';
import 'package:freelancer/features/auth/view/presentation/view/login_view.dart';
import 'package:freelancer/features/auth/view/presentation/view/sign_up_view.dart';

class AppRouter {
  static Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.signUp:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => AuthCubit(AuthRepoImpl(Dio())),
            child: const SignUpView(),
          ),
        );

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginView());

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
