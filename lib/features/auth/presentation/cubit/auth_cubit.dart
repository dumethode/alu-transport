import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

/// Listens to Firebase sign-in changes and runs every auth action.
/// Screens call these methods and rebuild from [AuthState].
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState());

  final AuthRepository _repository;
  StreamSubscription<AuthUser?>? _subscription;

  /// Starts listening. Firebase keeps the session, so a user who was
  /// signed in stays signed in after the app restarts.
  void start() {
    _subscription?.cancel();
    _subscription = _repository.userChanges().listen(_onUserChanged);
  }

  void _onUserChanged(AuthUser? user) {
    if (user == null) {
      emit(const AuthState(status: AuthStatus.signedOut));
      return;
    }
    emit(
      state.copyWith(
        status: user.canUseApp
            ? AuthStatus.signedIn
            : AuthStatus.needsVerification,
        user: user,
      ),
    );
  }

  Future<void> signIn({required String email, required String password}) {
    return _run(
      () => _repository.signInWithEmail(email: email, password: password),
    );
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) {
    return _run(
      () => _repository.registerWithEmail(
        fullName: fullName,
        email: email,
        password: password,
      ),
      success: 'Account created. We sent a verification link to $email.',
    );
  }

  Future<void> signInWithGoogle() => _run(_repository.signInWithGoogle);

  Future<void> sendPasswordReset(String email) {
    return _run(
      () => _repository.sendPasswordReset(email),
      success: 'Reset link sent. Check your inbox for $email.',
    );
  }

  Future<void> resendVerification() {
    return _run(
      _repository.sendEmailVerification,
      success: 'We sent a new verification email.',
    );
  }

  /// Called from the "I have verified" button.
  Future<void> checkVerified() async {
    emit(state.copyWith(isSubmitting: true, clearMessages: true));
    try {
      final bool verified = await _repository.reloadAndCheckVerified();
      if (verified) {
        _onUserChanged(_repository.currentUser);
        emit(state.copyWith(isSubmitting: false));
      } else {
        emit(
          state.copyWith(
            isSubmitting: false,
            errorMessage:
                'Your email is not verified yet. Open the link in the email '
                'we sent, then try again.',
          ),
        );
      }
    } catch (_) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'Could not check right now. Please try again.',
        ),
      );
    }
  }

  Future<void> signOut() => _run(_repository.signOut);

  /// Clears a message after it has been shown, so it does not show twice.
  void clearMessages() => emit(state.copyWith(clearMessages: true));

  Future<void> _run(Future<void> Function() action, {String? success}) async {
    emit(state.copyWith(isSubmitting: true, clearMessages: true));
    try {
      await action();
      emit(state.copyWith(isSubmitting: false, infoMessage: success));
    } on AuthFailure catch (failure) {
      emit(state.copyWith(isSubmitting: false, errorMessage: failure.message));
    } catch (_) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
