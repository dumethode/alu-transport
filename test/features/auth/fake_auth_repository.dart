import 'dart:async';

import 'package:alu_transport/features/auth/domain/entities/auth_user.dart';
import 'package:alu_transport/features/auth/domain/failures/auth_failure.dart';
import 'package:alu_transport/features/auth/domain/repositories/auth_repository.dart';

/// In-memory [AuthRepository] for tests. No Firebase needed.
class FakeAuthRepository implements AuthRepository {
  final StreamController<AuthUser?> _users =
      StreamController<AuthUser?>.broadcast();
  AuthUser? _current;
  String? lastSignInEmail;
  bool verifiedOnNextCheck = false;

  /// When set, sign in throws this failure.
  AuthFailure? signInFailure;

  void emitUser(AuthUser? user) {
    _current = user;
    _users.add(user);
  }

  @override
  Stream<AuthUser?> userChanges() => _users.stream;

  @override
  AuthUser? get currentUser => _current;

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    lastSignInEmail = email;
    final AuthFailure? failure = signInFailure;
    if (failure != null) {
      throw failure;
    }
    emitUser(
      AuthUser(
        uid: 'student-1',
        email: email,
        emailVerified: true,
        signedInWithGoogle: false,
      ),
    );
  }

  @override
  Future<void> registerWithEmail({
    required String fullName,
    required String email,
    required String password,
  }) async {
    emitUser(
      AuthUser(
        uid: 'new-1',
        email: email,
        displayName: fullName,
        emailVerified: false,
        signedInWithGoogle: false,
      ),
    );
  }

  @override
  Future<void> signInWithGoogle() async {
    emitUser(
      const AuthUser(
        uid: 'google-1',
        email: 'g@alustudent.com',
        emailVerified: true,
        signedInWithGoogle: true,
      ),
    );
  }

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> sendEmailVerification() async {}

  @override
  Future<bool> reloadAndCheckVerified() async {
    final AuthUser? user = _current;
    if (verifiedOnNextCheck && user != null) {
      _current = AuthUser(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        emailVerified: true,
        signedInWithGoogle: false,
      );
      return true;
    }
    return false;
  }

  @override
  Future<void> signOut() async => emitUser(null);

  Future<void> dispose() => _users.close();
}
