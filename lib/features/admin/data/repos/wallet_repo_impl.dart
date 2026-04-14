import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'wallet_repo.dart';

class WalletRepositoryImpl implements WalletRepository {
  final Dio dio;

  WalletRepositoryImpl({required this.dio});

  @override
  Future<Either<String, Map<String, dynamic>>> getWalletBalance(String hostId) async {
    // Mock response for now
    return const Right({
      'available_balance': 0.0,
      'on_hold': 0.0,
      'total_inflows': 0.0,
    });
  }

  @override
  Future<Either<String, List<Map<String, dynamic>>>> getTransactionHistory(String hostId) async {
    return const Right([]);
  }

  @override
  Future<Either<String, void>> requestWithdrawal({
    required String hostId,
    required double amount,
    required String method,
  }) async {
    return const Right(null);
  }
}
