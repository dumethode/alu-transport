import '../entities/auth_user.dart';

/// Everything the app can do with authentication.
/// The presentation layer only talks to this contract, never to Firebase.
abstract class AuthRepository {
  /// Emits the current user, then a new value on sign in, sign out and
  /// profile changes.
  Stream<AuthUser?> userChanges();

  AuthUser? get currentUser;

  Future<void> signInWithEmail({
    required String email,
    required String password,
  });

  /// Creates the account and sends the verification email.
  Future<void> registerWithEmail({
    required String fullName,
    required String email,
    required String password,
  });

  Future<void> signInWithGoogle();

  Future<void> sendPasswordReset(String email);

  Future<void> sendEmailVerification();

  /// Reloads the user from Firebase and returns true when the email
  /// address has been verified.
  Future<bool> reloadAndCheckVerified();

  Future<void> signOut();
}
