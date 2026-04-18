import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'wallet_repo.dart';

class WalletRepositoryImpl implements WalletRepository {
  final Dio dio;

  WalletRepositoryImpl({required this.dio});

  /// Returns available_balance (sum of confirmed bookings revenue),
  /// on_hold (pending bookings), total_inflows (all-time)
  @override
  Future<Either<String, Map<String, dynamic>>> getWalletBalance(
      String hostId) async {
    try {
      // Get all confirmed bookings subtotal for this host
      final confirmedRes = await dio.get(
        SupabaseKeys.bookingsRest,
        queryParameters: {
          'select': 'subtotal,status,listing:listings!inner(user_id)',
          'listing.user_id': 'eq.$hostId',
          'or': '(status.eq.confirmed,status.eq.completed)',
        },
      );

      // Get pending (on_hold)
      final pendingRes = await dio.get(
        SupabaseKeys.bookingsRest,
        queryParameters: {
          'select': 'subtotal,status,listing:listings!inner(user_id)',
          'listing.user_id': 'eq.$hostId',
          'status': 'eq.pending',
        },
      );

      double available = 0;
      double onHold = 0;

      if (confirmedRes.statusCode == 200) {
        final List data = confirmedRes.data;
        for (final b in data) {
          available += ((b['subtotal'] as num?) ?? 0).toDouble();
        }
      }
      if (pendingRes.statusCode == 200) {
        final List data = pendingRes.data;
        for (final b in data) {
          onHold += ((b['subtotal'] as num?) ?? 0).toDouble();
        }
      }

      return Right({
        'available_balance': available,
        'on_hold': onHold,
        'total_inflows': available + onHold,
      });
    } on DioException catch (e) {
      debugPrint('❌ getWalletBalance: ${e.message}');
      return Left(e.message ?? 'Network error');
    } catch (e) {
      return Left(e.toString());
    }
  }

  /// Returns list of booking transactions for this host
  @override
  Future<Either<String, List<Map<String, dynamic>>>> getTransactionHistory(
      String hostId) async {
    try {
      final res = await dio.get(
        SupabaseKeys.bookingsRest,
        queryParameters: {
          'select':
              'id,subtotal,status,created_at,listing:listings!inner(title,user_id)',
          'listing.user_id': 'eq.$hostId',
          'order': 'created_at.desc',
          'limit': '20',
        },
      );
      if (res.statusCode == 200) {
        final List data = res.data;
        return Right(data.cast<Map<String, dynamic>>());
      }
      return const Left('Failed to fetch transactions.');
    } on DioException catch (e) {
      return Left(e.message ?? 'Network error');
    } catch (e) {
      return Left(e.toString());
    }
  }

  /// Inserts a withdrawal request into `withdrawal_requests` table
  @override
  Future<Either<String, void>> requestWithdrawal({
    required String hostId,
    required double amount,
    required String method,
  }) async {
    try {
      final res = await dio.post(
        'withdrawal_requests',
        data: {
          'host_id': hostId,
          'amount': amount,
          'method': method,
          'status': 'pending',
        },
      );
      if (res.statusCode == 200 ||
          res.statusCode == 201 ||
          res.statusCode == 204) {
        return const Right(null);
      }
      return const Left('Failed to submit withdrawal request.');
    } on DioException catch (e) {
      return Left(e.message ?? 'Network error');
    } catch (e) {
      return Left(e.toString());
    }
  }
}
