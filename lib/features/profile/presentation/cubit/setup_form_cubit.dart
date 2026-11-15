import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_profile.dart';

class SetupFormState extends Equatable {
  const SetupFormState({
    this.role = UserRole.student,
    this.pickupPointId,
    this.showPickupError = false,
  });

  final UserRole role;
  final String? pickupPointId;
  final bool showPickupError;

  /// Students must choose a pickup point. Drivers do not need one.
  bool get isComplete => role == UserRole.driver || pickupPointId != null;

  SetupFormState copyWith({
    UserRole? role,
    String? pickupPointId,
    bool? showPickupError,
  }) {
    return SetupFormState(
      role: role ?? this.role,
      pickupPointId: pickupPointId ?? this.pickupPointId,
      showPickupError: showPickupError ?? this.showPickupError,
    );
  }

  @override
  List<Object?> get props => <Object?>[role, pickupPointId, showPickupError];
}

/// Holds the choices on the first-time setup screen.
class SetupFormCubit extends Cubit<SetupFormState> {
  SetupFormCubit() : super(const SetupFormState());

  void chooseRole(UserRole role) =>
      emit(state.copyWith(role: role, showPickupError: false));

  void choosePickupPoint(String id) =>
      emit(state.copyWith(pickupPointId: id, showPickupError: false));

  /// Returns true when the form can be saved.
  bool validate() {
    if (state.isComplete) {
      return true;
    }
    emit(state.copyWith(showPickupError: true));
    return false;
  }
}
