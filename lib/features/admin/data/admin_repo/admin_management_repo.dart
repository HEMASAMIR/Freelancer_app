import 'package:dartz/dartz.dart';

abstract class AdminManagementRepository {
  // 1. Listings Approval
  Future<Either<String, void>> updateListingStatus(String listingId, String status);

  // 2. Payouts Process
  Future<Either<String, void>> processPayout(Map<String, dynamic> payoutData);
}
