import 'package:dartz/dartz.dart';
import '../models/account_models.dart';

abstract class AccountRepository {
  // 1. Get Profile
  Future<Either<String, AccountProfileModel>> getProfile(String userId);

  // 2. Update Profile
  Future<Either<String, void>> updateProfile(String userId, Map<String, dynamic> profileData);
}
