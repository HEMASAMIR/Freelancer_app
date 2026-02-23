import 'package:dio/dio.dart';
import 'package:freelancer/features/auth/data/repos/auth_repo.dart';
import 'package:get_it/get_it.dart';

// تعريف الـ instance العالمي لـ GetIt
final getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerSingleton<Dio>(Dio());

  getIt.registerSingleton<AuthRepo>(getIt.get<AuthRepo>());
}
