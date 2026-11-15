import 'package:equatable/equatable.dart';

import '../../domain/entities/user_profile.dart';

/// [missing] means the user signed in but has not done first-time setup.
enum ProfileStatus { initial, loading, missing, ready, failure }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.isSaving = false,
    this.errorMessage,
    this.infoMessage,
  });

  final ProfileStatus status;
  final UserProfile? profile;
  final bool isSaving;
  final String? errorMessage;
  final String? infoMessage;

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfile? profile,
    bool? isSaving,
    String? errorMessage,
    String? infoMessage,
    bool clearMessages = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearMessages ? null : (infoMessage ?? this.infoMessage),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    profile,
    isSaving,
    errorMessage,
    infoMessage,
  ];
}
