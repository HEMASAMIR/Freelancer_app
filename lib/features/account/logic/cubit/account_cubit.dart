import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repos/account_repo.dart';
import 'account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  final AccountRepository _repository;

  AccountCubit(this._repository) : super(AccountInitial());

  Future<void> getProfile(String userId) async {
    emit(AccountLoading());
    final result = await _repository.getProfile(userId);
    result.fold(
      (error) => emit(AccountError(error)),
      (profile) => emit(AccountProfileLoaded(profile)),
    );
  }

  Future<void> updateProfile(String userId, Map<String, dynamic> profileData) async {
    emit(AccountLoading());
    final result = await _repository.updateProfile(userId, profileData);
    result.fold(
      (error) => emit(AccountError(error)),
      (_) => emit(const AccountSuccess("تم تحديث الحساب بنجاح")),
    );
  }
}
