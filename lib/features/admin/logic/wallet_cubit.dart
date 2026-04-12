import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repos/wallet_repo.dart';
import 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  final WalletRepository repository;

  WalletCubit(this.repository) : super(WalletInitial());

  Future<void> loadWallet(String hostId) async {
    emit(WalletLoading());
    final balanceResult = await repository.getWalletBalance(hostId);
    final historyResult = await repository.getTransactionHistory(hostId);

    balanceResult.fold(
      (error) => emit(WalletError(error)),
      (balance) => historyResult.fold(
        (error) => emit(WalletError(error)),
        (history) => emit(WalletLoaded(balance, history)),
      ),
    );
  }

  Future<void> requestWithdrawal({
    required String hostId,
    required double amount,
    required String method,
  }) async {
    final result = await repository.requestWithdrawal(
      hostId: hostId,
      amount: amount,
      method: method,
    );
    result.fold(
      (error) => emit(WalletError(error)),
      (_) => emit(WalletWithdrawalSuccess()),
    );
  }
}
