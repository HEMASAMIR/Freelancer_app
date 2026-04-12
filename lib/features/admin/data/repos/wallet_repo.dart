import 'package:dartz/dartz.dart';

abstract class WalletRepository {
  Future<Either<String, Map<String, dynamic>>> getWalletBalance(String hostId);
  Future<Either<String, List<Map<String, dynamic>>>> getTransactionHistory(String hostId);
  Future<Either<String, void>> requestWithdrawal({
    required String hostId,
    required double amount,
    required String method,
  });
}
