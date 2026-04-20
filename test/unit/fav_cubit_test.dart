import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:freelancer/features/favourite/logic/cubit/fav_cubit.dart';
import 'package:freelancer/features/favourite/data/fav_repos/fav_repo.dart';
import 'package:freelancer/features/favourite/data/models/wishlist_model.dart';
import 'package:freelancer/features/search/data/search_model/listing_model.dart';
import 'package:freelancer/core/error/errors.dart';

class FakeFavRepository implements FavoriteRepository {
  bool failMode = false;
  final List<String> stubFavIds = ['1', '2'];
  final List<WishlistModel> stubWishlists = [];

  @override
  bool get hasUser => true;

  @override
  Future<List<String>> getFavorites() async {
    if (failMode) throw Exception('Get Favorites Failed');
    return stubFavIds;
  }

  @override
  Future<List<WishlistModel>> getWishlists() async {
    if (failMode) throw Exception('Get Wishlists Failed');
    return stubWishlists;
  }

  @override
  Future<Either<Failure, WishlistModel>> createWishlist(String name) async {
    if (failMode) return left(const ServerFailure('Create Wishlist Failed'));
    return right(WishlistModel(id: '1', name: name, userId: 'user1', createdAt: DateTime.now()));
  }

  @override
  Future<Either<Failure, Unit>> toggle(String listingId, {String? wishlistId}) async {
    if (failMode) return left(const ServerFailure('Toggle Failed'));
    return right(unit);
  }

  @override
  Future<List<String>> getWishlistItems(String wishlistId) async {
    if (failMode) throw Exception('Failed');
    return [];
  }

  @override
  Future<Either<Failure, Unit>> deleteWishlist(String wishlistId) async {
    if (failMode) return left(const ServerFailure('Delete failed'));
    return right(unit);
  }

  @override
  Future<List<ListingModel>> getListingsByIds(List<String> ids) async {
    if (failMode) throw Exception('Get Listings Failed');
    return [];
  }
}

void main() {
  late FakeFavRepository fakeRepo;
  late FavCubit favCubit;

  setUp(() {
    fakeRepo = FakeFavRepository();
    favCubit = FavCubit(fakeRepo);
  });

  tearDown(() => favCubit.close());

  test('initial state is FavInitial', () {
    expect(favCubit.state, isA<FavInitial>());
  });

  blocTest<FavCubit, FavState>(
    'emits [FavLoading, FavLoaded] when loadFavorites succeeds',
    build: () => favCubit,
    act: (cubit) => cubit.loadFavorites(),
    expect: () => [
      isA<FavLoading>(),
      isA<FavLoaded>().having((s) => s.favoriteIds, 'favoriteIds', ['1', '2']),
    ],
  );

  blocTest<FavCubit, FavState>(
    'emits [FavLoading, FavError] when loadFavorites fails',
    build: () {
      fakeRepo.failMode = true;
      return favCubit;
    },
    act: (cubit) => cubit.loadFavorites(),
    expect: () => [
      isA<FavLoading>(),
      isA<FavError>().having((s) => s.message, 'message', 'Failed to load favorites'),
    ],
  );

  blocTest<FavCubit, FavState>(
    'emits [FavError] when createWishlist fails',
    build: () {
      fakeRepo.failMode = true;
      return favCubit;
    },
    act: (cubit) => cubit.createWishlist('New Wishlist'),
    expect: () => [
      isA<FavError>().having((s) => s.message, 'message', 'Failed to create wishlist'),
    ],
  );
  
  // Test toggleFavorite success re-triggers loadFavorites (FavLoading -> FavLoaded)
  blocTest<FavCubit, FavState>(
    'toggleFavorite success triggers loadFavorites, emitting [FavLoading, FavLoaded]',
    build: () => favCubit,
    act: (cubit) => cubit.toggleFavorite(ListingModel(id: '3')),
    expect: () => [
      isA<FavLoading>(),
      isA<FavLoaded>(),
    ],
  );
}
