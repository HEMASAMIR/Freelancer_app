import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/core/app_router/app_router.dart';
import 'package:freelancer/core/app_router/routes.dart';
import 'package:freelancer/core/cache_helper/shared_pref.dart';
import 'package:freelancer/core/constant/constant.dart' as constants;
import 'package:freelancer/core/di/service_locator.dart';
import 'package:freelancer/core/bloc_observer.dart';
import 'package:freelancer/features/auth/logic/cubit/auth_cubit.dart';
import 'package:freelancer/features/auth/logic/cubit/auth_state.dart';
import 'package:freelancer/features/favourite/logic/cubit/fav_cubit.dart';
import 'package:freelancer/features/notifications/data/services/local_notification_service.dart';
import 'package:freelancer/features/notifications/data/services/host_foreground_service.dart';
import 'package:freelancer/features/notifications/presentation/auth_aware_notification_wrapper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:freelancer/core/logic/connectivity_cubit.dart';
import 'package:freelancer/core/widgets/no_internet_screen.dart';
import 'package:freelancer/core/shared_helper/app_color.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final supabase = Supabase.instance.client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Supabase.initialize(
    url: constants.SupabaseKeys.supabaseUrl,
    anonKey: constants.SupabaseKeys.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce, // ✅ أضف ده
    ),
  );
  await CacheHelper.init();
  await setupServiceLocator();

  Bloc.observer = AppBlocObserver();

  // ── Foreground Service (init config before runApp) ────────────────
  HostForegroundService.initForegroundTask();

  // ── Local Notifications (OS-level banners) ──────────────────────────────
  await LocalNotificationService.instance.init();

  runApp(const FreelancerApp());
}

class FreelancerApp extends StatelessWidget {
  const FreelancerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => sl<AuthCubit>()),
        BlocProvider<FavCubit>(create: (_) => sl<FavCubit>()..loadFavorites()),
        BlocProvider<ConnectivityCubit>(create: (_) => ConnectivityCubit()),
      ],
      child: AuthAwareNotificationWrapper(
        child: ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return BlocBuilder<ConnectivityCubit, ConnectivityStatus>(
              builder: (context, connectivityStatus) {
                return MaterialApp(
                  navigatorKey: navigatorKey,
                  debugShowCheckedModeBanner: false,
                  color: constants
                      .AppColors
                      .backgroundCream, // ← منع الـ black frame عند الـ startup
                  theme: ThemeData(
                    fontFamily: 'Cairo',
                    scaffoldBackgroundColor:
                        constants.AppColors.backgroundCream,
                    primaryColor: constants.AppColors.primaryBurgundy,
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: constants.AppColors.primaryBurgundy,
                      primary: constants.AppColors.primaryBurgundy,
                    ),
                    appBarTheme: const AppBarTheme(
                      backgroundColor: constants.AppColors.cardWhite,
                      elevation: 0,
                    ),
                  ),
                  onGenerateRoute: AppRouter.generateRoute,
                  initialRoute: AppRoutes.splash,
                  builder: (context, child) {
                    if (connectivityStatus == ConnectivityStatus.disconnected) {
                      return const NoInternetScreen();
                    }
                    return BlocListener<AuthCubit, AuthCubitState>(
                      listener: (context, state) {
                        if (state is AuthPasswordRecovery) {
                          navigatorKey.currentState?.pushNamedAndRemoveUntil(
                            AppRoutes.security,
                            (route) => false,
                          );
                        }
                      },
                      child: child!,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
