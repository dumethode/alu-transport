import 'package:equatable/equatable.dart';

/// The signed-in person as the app needs it, without any Firebase types.
class AuthUser extends Equatable {
  const AuthUser({
    required this.uid,
    required this.email,
    required this.emailVerified,
    required this.signedInWithGoogle,
    this.displayName,
  });

  final String uid;
  final String email;
  final String? displayName;
  final bool emailVerified;
  final bool signedInWithGoogle;

  /// Google accounts are already verified. Email accounts must click the
  /// link in the verification email before they can use the app.
  bool get canUseApp => emailVerified || signedInWithGoogle;

  @override
  List<Object?> get props => <Object?>[
    uid,
    email,
    displayName,
    emailVerified,
    signedInWithGoogle,
  ];
}
