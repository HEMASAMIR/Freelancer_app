abstract class WalletState {}

class WalletInitial extends WalletState {}
class WalletLoading extends WalletState {}
class WalletLoaded extends WalletState {
  final Map<String, dynamic> balance;
  final List<Map<String, dynamic>> history;
  WalletLoaded(this.balance, this.history);
}
class WalletError extends WalletState {
  final String message;
  WalletError(this.message);
}
class WalletWithdrawalSuccess extends WalletState {}
