import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:freelancer/features/search/logic/search_cubit/cubit/search_cubit.dart';
import 'package:freelancer/features/search/logic/search_cubit/cubit/search_state.dart';
import 'package:freelancer/features/search/data/repos/search_repo.dart';
import 'package:freelancer/features/search/data/search_model/search_params_model.dart';
import 'package:freelancer/features/search/data/search_model/listing_model.dart';

class FakeSearchRepository implements SearchRepository {
  bool failMode = false;
  final List<ListingModel> stubListings = [ListingModel(id: '1', title: 'Test House')];
  final ListingModel stubDetails = ListingModel(id: '1', title: 'Test House');

  @override
  Future<Either<String, List<ListingModel>>> searchListings(SearchParamsModel params) async {
    if (failMode) return left('Search Failed');
    return right(stubListings);
  }

  @override
  Future<Either<String, ListingModel>> getListingDetails(String id) async {
    if (failMode) return left('Details Failed');
    return right(stubDetails);
  }
}

void main() {
  late FakeSearchRepository fakeRepo;
  late SearchCubit searchCubit;

  setUp(() {
    fakeRepo = FakeSearchRepository();
    searchCubit = SearchCubit(fakeRepo);
  });

  tearDown(() => searchCubit.close());

  test('initial state is SearchInitial', () {
    expect(searchCubit.state, isA<SearchInitial>());
  });

  blocTest<SearchCubit, SearchState>(
    'emits [SearchLoading, SearchSuccess] when searchListings succeeds',
    build: () => searchCubit,
    act: (cubit) => cubit.getListings(params: SearchParamsModel()),
    expect: () => [
      isA<SearchLoading>(),
      isA<SearchSuccess>(),
    ],
  );

  blocTest<SearchCubit, SearchState>(
    'emits [SearchLoading, SearchError] when searchListings fails',
    build: () {
      fakeRepo.failMode = true;
      return searchCubit;
    },
    act: (cubit) => cubit.getListings(params: SearchParamsModel()),
    expect: () => [
      isA<SearchLoading>(),
      isA<SearchError>().having((s) => s.message, 'message', 'Search Failed'),
    ],
  );

  blocTest<SearchCubit, SearchState>(
    'emits [ListingDetailsLoading, ListingDetailsSuccess] when getListingDetails succeeds',
    build: () => searchCubit,
    act: (cubit) => cubit.getListingDetails(id: '1'),
    expect: () => [
      isA<ListingDetailsLoading>(),
      isA<ListingDetailsSuccess>(),
    ],
  );

  blocTest<SearchCubit, SearchState>(
    'emits [ListingDetailsLoading, ListingDetailsError] when getListingDetails fails',
    build: () {
      fakeRepo.failMode = true;
      return searchCubit;
    },
    act: (cubit) => cubit.getListingDetails(id: '1'),
    expect: () => [
      isA<ListingDetailsLoading>(),
      isA<ListingDetailsError>().having((s) => s.message, 'message', 'Details Failed'),
    ],
  );
}
