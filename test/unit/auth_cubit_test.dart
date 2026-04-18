// Unit test for AuthCubit
import 'package:flutter_test/flutter_test.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_state.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_cubit.dart';
import 'package:freelancer/features/auth/data/repos/auth_repo.dart';
import 'package:freelancer/core/services/admin_email_service.dart';

class MockAuthRepo extends Mock implements AuthRepo {}
class FakeAdminEmailService implements AdminEmailService {
  @override
  bool isAdmin(String email) => false;
  
  @override
  Future<void> load() async {}
}

void main() {
  late MockAuthRepo mockAuthRepo;
  late FakeAdminEmailService mockAdminService;
  late AuthCubit authCubit;

  setUp(() {
    mockAuthRepo = MockAuthRepo();
    mockAdminService = FakeAdminEmailService();
    authCubit = AuthCubit(authRepo: mockAuthRepo, adminService: mockAdminService);
  });

  tearDown(() => authCubit.close());

  test('initial state is unauthenticated and not admin', () {
    expect(authCubit.state, isA<AuthInitial>());
    expect(authCubit.isAuthenticated, false);
    expect(authCubit.isAdmin, false);
  });

  // Additional tests for login, admin detection, navigation can be added here.
}
