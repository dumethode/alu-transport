import 'package:equatable/equatable.dart';

import '../../../alerts/domain/entities/status_update.dart';

class DriverRoundState extends Equatable {
  const DriverRoundState({
    this.driverId,
    this.selectedRoundId,
    this.selectedType = StatusUpdateType.leavingCampus,
    this.isBusy = false,
    this.message,
    this.isError = false,
  });

  final String? driverId;

  /// The round the driver is posting updates for.
  final String? selectedRoundId;

  /// The preset button the driver tapped.
  final StatusUpdateType selectedType;

  final bool isBusy;
  final String? message;
  final bool isError;

  DriverRoundState copyWith({
    String? selectedRoundId,
    StatusUpdateType? selectedType,
    bool? isBusy,
    String? message,
    bool? isError,
    bool clearMessage = false,
  }) {
    return DriverRoundState(
      driverId: driverId,
      selectedRoundId: selectedRoundId ?? this.selectedRoundId,
      selectedType: selectedType ?? this.selectedType,
      isBusy: isBusy ?? this.isBusy,
      message: clearMessage ? null : (message ?? this.message),
      isError: clearMessage ? false : (isError ?? this.isError),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    driverId,
    selectedRoundId,
    selectedType,
    isBusy,
    message,
    isError,
  ];
}
