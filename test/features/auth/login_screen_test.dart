import 'package:alu_transport/core/theme/app_theme.dart';
import 'package:alu_transport/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:alu_transport/features/auth/presentation/pages/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repository;

  setUp(() => repository = FakeAuthRepository());
  tearDown(() => repository.dispose());

  Future<void> pumpLogin(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      BlocProvider<AuthCubit>(
        create: (BuildContext context) => AuthCubit(repository),
        child: MaterialApp(theme: AppTheme.light(), home: const LoginScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapLogIn(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Log in'));
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the welcome header and both sign-in options', (
    WidgetTester tester,
  ) async {
    await pumpLogin(tester);
    expect(find.text('ALU Transport'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets('empty form shows polite validation errors', (
    WidgetTester tester,
  ) async {
    await pumpLogin(tester);
    await tapLogIn(tester);
    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
    expect(repository.lastSignInEmail, isNull);
  });

  testWidgets('a wrong email format is caught before Firebase is called', (
    WidgetTester tester,
  ) async {
    await pumpLogin(tester);
    await tester.enterText(find.byType(TextFormField).at(0), 'jean@');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret123');
    await tapLogIn(tester);
    expect(
      find.text('Enter a valid email, like name@alustudent.com'),
      findsOneWidget,
    );
    expect(repository.lastSignInEmail, isNull);
  });

  testWidgets('a valid form signs in through the cubit', (
    WidgetTester tester,
  ) async {
    await pumpLogin(tester);
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'jean@alustudent.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'secret123');
    await tapLogIn(tester);
    expect(repository.lastSignInEmail, 'jean@alustudent.com');
  });
}
