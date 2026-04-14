import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/admin_repo/admin_management_repo.dart';
import 'admin_management_state.dart';

class AdminManagementCubit extends Cubit<AdminManagementState> {
  final AdminManagementRepository _repository;

  AdminManagementCubit(this._repository) : super(AdminManagementInitial());

  Future<void> updateListingStatus(String listingId, String status) async {
    emit(AdminManagementLoading());
    final result = await _repository.updateListingStatus(listingId, status);
    result.fold(
      (error) => emit(AdminManagementError(error)),
      (_) => emit(const AdminManagementSuccess("تم تحديث حالة العقار بنجاح")),
    );
  }

  Future<void> processPayout(Map<String, dynamic> payoutData) async {
    emit(AdminManagementLoading());
    final result = await _repository.processPayout(payoutData);
    result.fold(
      (error) => emit(AdminManagementError(error)),
      (_) => emit(const AdminManagementSuccess("تمت معالجة المدفوعات بنجاح")),
    );
  }
}
