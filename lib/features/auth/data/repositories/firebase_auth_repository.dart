import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../mappers/auth_error_mapper.dart';

/// [AuthRepository] built on Firebase Authentication.
/// Supports email/password (with email verification) and Google sign-in.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
    : _auth = auth ?? FirebaseAuth.instance,
      _google = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _auth;
  final GoogleSignIn _google;
  bool _googleReady = false;

  AuthUser? _toAuthUser(User? user) {
    if (user == null) {
      return null;
    }
    return AuthUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      emailVerified: user.emailVerified,
      signedInWithGoogle: user.providerData.any(
        (UserInfo info) => info.providerId == 'google.com',
      ),
    );
  }

  @override
  Stream<AuthUser?> userChanges() => _auth.userChanges().map(_toAuthUser);

  @override
  AuthUser? get currentUser => _toAuthUser(_auth.currentUser);

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(authMessageForCode(error.code));
    }
  }

  @override
  Future<void> registerWithEmail({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );
      final User? user = credential.user;
      await user?.updateDisplayName(fullName.trim());
      await user?.sendEmailVerification();
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(authMessageForCode(error.code));
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      await _prepareGoogle();
      // Sign out of Google first so the account picker always shows.
      await _google.signOut();
      final GoogleSignInAccount account = await _google.authenticate();
      final GoogleSignInAuthentication tokens = account.authentication;
      final authorization = await account.authorizationClient.authorizeScopes(
        <String>['email', 'profile'],
      );
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: tokens.idToken,
        accessToken: authorization.accessToken,
      );
      await _auth.signInWithCredential(credential);
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthFailure('Google sign-in was cancelled.');
      }
      throw const AuthFailure(
        'Google sign-in failed. Check your connection and try again.',
      );
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(authMessageForCode(error.code));
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(authMessageForCode(error.code));
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(authMessageForCode(error.code));
    }
  }

  @override
  Future<bool> reloadAndCheckVerified() async {
    await _auth.currentUser?.reload();
    final User? user = _auth.currentUser;
    final bool verified = user?.emailVerified ?? false;
    if (verified) {
      // Refresh the ID token so Firestore rules see email_verified = true.
      await user?.getIdToken(true);
    }
    return verified;
  }

  @override
  Future<void> signOut() async {
    try {
      await _prepareGoogle();
      await _google.signOut();
    } catch (_) {
      // The user may never have used Google sign-in; that is fine.
    }
    await _auth.signOut();
  }

  Future<void> _prepareGoogle() async {
    if (_googleReady) {
      return;
    }
    await _google.initialize();
    _googleReady = true;
  }
}
