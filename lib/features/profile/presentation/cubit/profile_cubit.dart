import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import 'profile_state.dart';

/// Streams the signed-in user's profile and saves changes to it.
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repository) : super(const ProfileState());

  final ProfileRepository _repository;
  StreamSubscription<UserProfile?>? _subscription;

  void watch(String uid) {
    _subscription?.cancel();
    emit(const ProfileState(status: ProfileStatus.loading));
    _subscription = _repository
        .watchProfile(uid)
        .listen(
          (UserProfile? profile) => emit(
            ProfileState(
              status: profile == null
                  ? ProfileStatus.missing
                  : ProfileStatus.ready,
              profile: profile,
              isSaving: state.isSaving,
              infoMessage: state.infoMessage,
            ),
          ),
          onError: (Object error) => emit(
            state.copyWith(
              status: ProfileStatus.failure,
              errorMessage:
                  'Could not load your profile. Check your connection.',
            ),
          ),
        );
  }

  /// First-time setup. Drivers must be on the transport office list.
  Future<bool> createProfile({
    required String uid,
    required String email,
    required String fullName,
    required UserRole role,
    String? pickupPointId,
  }) async {
    emit(state.copyWith(isSaving: true, clearMessages: true));
    try {
      if (role == UserRole.driver &&
          !await _repository.isApprovedDriver(email)) {
        emit(
          state.copyWith(
            isSaving: false,
            errorMessage:
                'This email is not on the ALU driver list. Choose Student, '
                'or ask the transport office to add you.',
          ),
        );
        return false;
      }
      await _repository.createProfile(
        UserProfile(
          uid: uid,
          fullName: fullName.trim(),
          email: email,
          role: role,
          avatarSeed: uid,
          pickupPointId: role == UserRole.student ? pickupPointId : null,
        ),
      );
      emit(state.copyWith(isSaving: false));
      return true;
    } catch (_) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: 'Could not save your profile. Please try again.',
        ),
      );
      return false;
    }
  }

  Future<void> updateName(String fullName) =>
      _save(fullName: fullName, success: 'Name updated');

  Future<void> updatePickupPoint(String pickupPointId) =>
      _save(pickupPointId: pickupPointId, success: 'Pickup point updated');

  /// Picks a new random avatar by changing the seed.
  Future<void> shuffleAvatar() {
    final String uid = state.profile?.uid ?? 'user';
    return _save(
      avatarSeed: '$uid-${DateTime.now().millisecondsSinceEpoch}',
      success: 'New avatar saved',
    );
  }

  void clearMessages() => emit(state.copyWith(clearMessages: true));

  /// Called on sign out.
  void reset() {
    _subscription?.cancel();
    _subscription = null;
    emit(const ProfileState());
  }

  Future<void> _save({
    String? fullName,
    String? pickupPointId,
    String? avatarSeed,
    required String success,
  }) async {
    final UserProfile? profile = state.profile;
    if (profile == null) {
      return;
    }
    emit(state.copyWith(isSaving: true, clearMessages: true));
    try {
      await _repository.updateProfile(
        profile.uid,
        fullName: fullName,
        pickupPointId: pickupPointId,
        avatarSeed: avatarSeed,
      );
      emit(state.copyWith(isSaving: false, infoMessage: success));
    } catch (_) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: 'Could not save the change. Please try again.',
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
