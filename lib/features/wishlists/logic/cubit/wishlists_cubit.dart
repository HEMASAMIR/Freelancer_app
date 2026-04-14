import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repos/wishlists_repo.dart';
import 'wishlists_state.dart';

class WishlistsCubit extends Cubit<WishlistsState> {
  final WishlistsRepository _repository;

  WishlistsCubit(this._repository) : super(WishlistsInitial());

  Future<void> getWishlists(String userId) async {
    emit(WishlistsLoading());
    final result = await _repository.getWishlists(userId);
    result.fold(
      (error) => emit(WishlistsError(error)),
      (wishlists) => emit(WishlistsLoaded(wishlists)),
    );
  }

  Future<void> createWishlist(String userId, String name) async {
    emit(WishlistsLoading());
    final result = await _repository.createWishlist(userId, name);
    result.fold(
      (error) => emit(WishlistsError(error)),
      (newWishlist) {
        emit(const WishlistsSuccess("تم إنشاء المفضلة بنجاح"));
        getWishlists(userId);
      },
    );
  }

  Future<void> addListingToWishlist(String userId, String wishlistId, String listingId) async {
    emit(WishlistsLoading());
    final result = await _repository.addToListingWishlist(wishlistId, listingId);
    result.fold(
      (error) => emit(WishlistsError(error)),
      (_) {
        emit(const WishlistsSuccess("تمت إضافة العقار للمفضلة بنجاح"));
        getWishlists(userId);
      },
    );
  }

  Future<void> removeFromWishlist(String userId, String wishlistId, String listingId) async {
    emit(WishlistsLoading());
    final result = await _repository.removeFromWishlist(wishlistId, listingId);
    result.fold(
      (error) => emit(WishlistsError(error)),
      (_) {
        emit(const WishlistsSuccess("تم حذف العقار من المفضلة بنجاح"));
        getWishlists(userId);
      },
    );
  }
}
