import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freelancer/features/account/logic/security_cubit.dart';
import 'package:freelancer/features/account/presentation/security_screen.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MockSecurityCubit extends MockCubit<SecurityState> implements SecurityCubit {}

void main() {
  late MockSecurityCubit mockSecurityCubit;

  setUp(() {
    mockSecurityCubit = MockSecurityCubit();
  });

  Widget buildTestableWidget() {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, __) => MaterialApp(
        home: BlocProvider<SecurityCubit>.value(
          value: mockSecurityCubit,
          child: const Scaffold(body: SecurityScreen()), // Ensure it's in Scaffold if needed, but it has its own Scaffold. Wait.
        ),
      ),
    );
  }

  group('SecurityScreen Widget Tests', () {
    testWidgets('Displays SecurityScreen components properly in initial state', (WidgetTester tester) async {
      whenListen(
        mockSecurityCubit,
        Stream.fromIterable([SecurityInitial()]),
        initialState: SecurityInitial(),
      );

      await tester.pumpWidget(buildTestableWidget());

      // Verify Screen Titles
      expect(find.text('Login & Security'), findsOneWidget);
      expect(find.text('Manage your password and secure your account'), findsOneWidget);

      // Verify Cards
      expect(find.text('Update Password'), findsWidgets);
      expect(find.text('Two-Factor Authentication (2FA)'), findsWidgets); // Found in both card title and subtitle occasionally
    });

    testWidgets('Displays MFA setup instructions when MFASetupInitiated state is emitted', (WidgetTester tester) async {
      whenListen(
        mockSecurityCubit,
        Stream.fromIterable([
          const MFASetupInitiated(
            qrCodeUri: 'otpauth://totp/Test?secret=SECRET',
            secret: 'SECRET',
            factorId: 'factor_123',
          )
        ]),
        initialState: const MFASetupInitiated(
            qrCodeUri: 'otpauth://totp/Test?secret=SECRET',
            secret: 'SECRET',
            factorId: 'factor_123',
        ),
      );

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle(); // Allow UI to finish animations

      expect(find.text('Set up Two-Factor Authentication'), findsOneWidget);
      expect(find.text('Verify'), findsOneWidget); // Verify Button
      expect(find.text('Verify Code'), findsOneWidget); // Verify Input
    });
  });
}
