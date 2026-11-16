import 'package:equatable/equatable.dart';

/// Live state of one bus round. [value] is what is stored in Firestore.
enum RoundStatus {
  planned('planned', 'Planned'),
  onTheWay('on_the_way', 'On the way'),
  atStop('at_stop', 'At a stop'),
  delayed('delayed', 'Delayed'),
  full('full', 'Bus full'),
  ended('ended', 'Done');

  const RoundStatus(this.value, this.label);
  final String value;
  final String label;

  /// True while the bus is out on the road.
  bool get isLive =>
      this == RoundStatus.onTheWay ||
      this == RoundStatus.atStop ||
      this == RoundStatus.delayed ||
      this == RoundStatus.full;
  static RoundStatus fromValue(String? value) {
    return RoundStatus.values.firstWhere(
      (RoundStatus status) => status.value == value,
      orElse: () => RoundStatus.planned,
    );
  }
}

enum RoundPeriod {
  morning('Morning'),
  evening('Evening');

  const RoundPeriod(this.label);
  final String label;
}

/// A document in the `rounds` collection: one trip of the bus.
class Round extends Equatable {
  const Round({
    required this.id,
    required this.label,
    required this.period,
    required this.departureTime,
    required this.stopIds,
    required this.status,
    required this.currentStopIndex,
    required this.seatsTotal,
    required this.seatsLeft,
    required this.driverId,
    this.note,
    this.updatedAt,
  });
  final String id;
  final String label;
  final RoundPeriod period;
  final DateTime departureTime;

  /// Foreign keys to `pickup_points`, in the order the bus visits them.
  final List<String> stopIds;
  final RoundStatus status;

  /// Index in [stopIds] of the last stop reached; -1 before the first stop.
  final int currentStopIndex;
  final int seatsTotal;
  final int seatsLeft;

  /// Foreign key to the driver's document in `users`.
  final String driverId;
  final String? note;
  final DateTime? updatedAt;
  bool get isLive => status.isLive;
  bool get isFinished => status == RoundStatus.ended;

  /// Share of seats already taken, from 0.0 (empty) to 1.0 (full).
  double get seatsTakenFraction {
    if (seatsTotal <= 0) {
      return 0;
    }
    return ((seatsTotal - seatsLeft) / seatsTotal).clamp(0, 1).toDouble();
  }

  Round copyWith({
    String? label,
    RoundPeriod? period,
    DateTime? departureTime,
    List<String>? stopIds,
    RoundStatus? status,
    int? currentStopIndex,
    int? seatsTotal,
    int? seatsLeft,
    String? note,
  }) {
    return Round(
      id: id,
      label: label ?? this.label,
      period: period ?? this.period,
      departureTime: departureTime ?? this.departureTime,
      stopIds: stopIds ?? this.stopIds,
      status: status ?? this.status,
      currentStopIndex: currentStopIndex ?? this.currentStopIndex,
      seatsTotal: seatsTotal ?? this.seatsTotal,
      seatsLeft: seatsLeft ?? this.seatsLeft,
      driverId: driverId,
      note: note ?? this.note,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    label,
    period,
    departureTime,
    stopIds,
    status,
    currentStopIndex,
    seatsTotal,
    seatsLeft,
    driverId,
    note,
    updatedAt,
  ];
}
