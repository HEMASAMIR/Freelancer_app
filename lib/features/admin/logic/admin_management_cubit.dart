import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/admin_repo/admin_management_repo.dart';
import 'admin_management_state.dart';

class AdminManagementCubit extends Cubit<AdminManagementState> {
  final AdminManagementRepository _repository;
  final SupabaseClient _supabase;

  AdminManagementCubit(this._repository, this._supabase)
      : super(AdminManagementInitial());

  // ─── Dashboard Stats ───────────────────────────────────────────────────────
  /// Fetches all 4 overview stats shown on the admin dashboard.
  Future<void> loadDashboardStats() async {
    emit(AdminManagementLoading());
    try {
      // Fetch each count sequentially to avoid Future<dynamic> type issues
      final totalListings = await _countAll('listings');
      final totalUsers = await _countAll('profiles');
      final bookingsThisMonth = await _bookingsThisMonth();
      final pendingApprovals = await _pendingApprovals();

      emit(AdminDashboardStatsLoaded(
        totalListings: totalListings,
        totalUsers: totalUsers,
        bookingsThisMonth: bookingsThisMonth,
        pendingApprovals: pendingApprovals,
      ));
    } catch (e) {
      log('❌ loadDashboardStats error: $e', name: 'AdminManagementCubit');
      emit(AdminManagementError(e.toString()));
    }
  }

  Future<int> _countAll(String table) async {
    final res = await _supabase
        .from(table)
        .select()
        .count(CountOption.exact);
    return res.count;
  }

  Future<int> _bookingsThisMonth() async {
    final now = DateTime.now();
    final firstOfMonth = DateTime(now.year, now.month, 1).toIso8601String();
    final res = await _supabase
        .from('bookings')
        .select()
        .gte('created_at', firstOfMonth)
        .count(CountOption.exact);
    return res.count;
  }

  Future<int> _pendingApprovals() async {
    final res = await _supabase
        .from('listings')
        .select()
        .eq('is_published', false)
        .count(CountOption.exact);
    return res.count;
  }

  // ─── Listing Status ────────────────────────────────────────────────────────
  Future<void> updateListingStatus(String listingId, String status) async {
    emit(AdminManagementLoading());
    final result = await _repository.updateListingStatus(listingId, status);
    result.fold(
      (error) => emit(AdminManagementError(error)),
      (_) => emit(const AdminManagementSuccess("تم تحديث حالة العقار بنجاح")),
    );
  }

  // ─── Payout ────────────────────────────────────────────────────────────────
  Future<void> processPayout(Map<String, dynamic> payoutData) async {
    emit(AdminManagementLoading());
    final result = await _repository.processPayout(payoutData);
    result.fold(
      (error) => emit(AdminManagementError(error)),
      (_) => emit(const AdminManagementSuccess("تمت معالجة المدفوعات بنجاح")),
    );
  }

  @override
  void emit(AdminManagementState state) {
    if (!isClosed) super.emit(state);
  }
}
