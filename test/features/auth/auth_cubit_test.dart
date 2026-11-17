import 'package:alu_transport/features/auth/domain/failures/auth_failure.dart';
import 'package:alu_transport/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:alu_transport/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_auth_repository.dart';

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  late FakeAuthRepository repository;
  late AuthCubit cubit;

  setUp(() {
    repository = FakeAuthRepository();
    cubit = AuthCubit(repository)..start();
  });

  tearDown(() async {
    await cubit.close();
    await repository.dispose();
  });

  test('is signed out when Firebase has no user', () async {
    repository.emitUser(null);
    await _settle();
    expect(cubit.state.status, AuthStatus.signedOut);
  });

  test('signs in a verified user', () async {
    await cubit.signIn(email: 'jean@alustudent.com', password: 'busride2026');
    await _settle();
    expect(cubit.state.status, AuthStatus.signedIn);
    expect(cubit.state.user?.email, 'jean@alustudent.com');
    expect(cubit.state.isSubmitting, isFalse);
  });

  test('shows a polite message when the password is wrong', () async {
    repository.signInFailure = const AuthFailure(
      'Email or password is incorrect. Please try again.',
    );
    await cubit.signIn(email: 'jean@alustudent.com', password: 'wrong');
    expect(
      cubit.state.errorMessage,
      'Email or password is incorrect. Please try again.',
    );
    expect(cubit.state.isSubmitting, isFalse);
  });

  test('a new email account must verify before using the app', () async {
    await cubit.register(
      fullName: 'Jean Muhire',
      email: 'jean@alustudent.com',
      password: 'busride2026',
    );
    await _settle();
    expect(cubit.state.status, AuthStatus.needsVerification);
    expect(cubit.state.infoMessage, contains('verification link'));

    repository.verifiedOnNextCheck = true;
    await cubit.checkVerified();
    expect(cubit.state.status, AuthStatus.signedIn);
  });

  test('Google accounts skip email verification', () async {
    await cubit.signInWithGoogle();
    await _settle();
    expect(cubit.state.status, AuthStatus.signedIn);
    expect(cubit.state.user?.signedInWithGoogle, isTrue);
  });

  test('sign out clears the user', () async {
    await cubit.signInWithGoogle();
    await _settle();
    await cubit.signOut();
    await _settle();
    expect(cubit.state.status, AuthStatus.signedOut);
    expect(cubit.state.user, isNull);
  });
}
