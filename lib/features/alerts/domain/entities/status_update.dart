import 'package:equatable/equatable.dart';

/// The six preset updates a driver can post. [value] is stored in Firestore.
enum StatusUpdateType {
  leavingCampus('leaving_campus', 'Leaving campus'),
  atPickup('at_pickup', 'At pickup point'),
  delayed('delayed', 'Delayed'),
  busFull('bus_full', 'Bus full'),
  roundEnded('round_ended', 'Round ended'),
  noMoreRounds('no_more_rounds', 'No more rounds');

  const StatusUpdateType(this.value, this.label);

  final String value;
  final String label;

  static StatusUpdateType fromValue(String? value) {
    return StatusUpdateType.values.firstWhere(
      (StatusUpdateType type) => type.value == value,
      orElse: () => StatusUpdateType.leavingCampus,
    );
  }
}

/// A document in `status_updates`: one message from the driver, with time.
class StatusUpdate extends Equatable {
  const StatusUpdate({
    required this.id,
    required this.roundId,
    required this.driverId,
    required this.type,
    required this.createdAt,
    this.stopId,
    this.note,
  });

  final String id;

  /// Foreign keys to `rounds` and `users`.
  final String roundId;
  final String driverId;

  final StatusUpdateType type;

  /// Foreign key to `pickup_points`, set for "At pickup point" updates.
  /// Names are looked up when shown, so no data is copied.
  final String? stopId;
  final String? note;
  final DateTime createdAt;

  @override
  List<Object?> get props => <Object?>[
    id,
    roundId,
    driverId,
    type,
    stopId,
    note,
    createdAt,
  ];
}
