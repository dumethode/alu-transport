import 'package:equatable/equatable.dart';

import '../../domain/entities/auth_user.dart';

/// Where the user is in the sign-in journey.
enum AuthStatus { unknown, signedOut, needsVerification, signedIn }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.isSubmitting = false,
    this.errorMessage,
    this.infoMessage,
  });

  final AuthStatus status;
  final AuthUser? user;

  /// True while a sign-in, register or reset request is running.
  final bool isSubmitting;

  /// Polite error to show in a snack bar, for example a wrong password.
  final String? errorMessage;

  /// Success message to show in a snack bar, for example "Reset link sent".
  final String? infoMessage;

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    bool? isSubmitting,
    String? errorMessage,
    String? infoMessage,
    bool clearMessages = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearMessages ? null : (infoMessage ?? this.infoMessage),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    user,
    isSubmitting,
    errorMessage,
    infoMessage,
  ];
}
