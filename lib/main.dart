import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/app_router/app_router.dart';
import 'package:freelancer/core/app_router/routes.dart';
import 'package:freelancer/core/costant/constant.dart';
import 'package:freelancer/core/di/service_locator.dart';
import 'package:freelancer/core/netwrok/bloc_observer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final supabase = Supabase.instance.client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  setupServiceLocator();

  Bloc.observer = AppBlocObserver();

  runApp(const FreelancerApp());
}

class FreelancerApp extends StatelessWidget {
  const FreelancerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'Cairo',
            scaffoldBackgroundColor: Colors.white,
          ),
          onGenerateRoute: AppRouter.generateRoute,
          initialRoute: AppRoutes.splash,
        );
      },
    );
  }
}
