import '../../../alerts/domain/entities/status_update.dart';
import '../../../rounds/domain/entities/round.dart';

/// What a preset update does to the round. Pure logic, unit tested.
class LiveChange {
  const LiveChange({
    required this.status,
    required this.currentStopIndex,
    required this.seatsLeft,
  });

  final RoundStatus status;
  final int currentStopIndex;
  final int seatsLeft;

  /// Works out the new round values when the driver posts [type].
  static LiveChange forUpdate(Round round, StatusUpdateType type) {
    switch (type) {
      case StatusUpdateType.leavingCampus:
        return LiveChange(
          status: RoundStatus.onTheWay,
          currentStopIndex: -1,
          seatsLeft: round.seatsLeft,
        );
      case StatusUpdateType.atPickup:
        final int last = round.stopIds.length - 1;
        final int next = round.currentStopIndex + 1;
        return LiveChange(
          status: RoundStatus.atStop,
          currentStopIndex: next > last ? last : next,
          seatsLeft: round.seatsLeft,
        );
      case StatusUpdateType.delayed:
        return LiveChange(
          status: RoundStatus.delayed,
          currentStopIndex: round.currentStopIndex,
          seatsLeft: round.seatsLeft,
        );
      case StatusUpdateType.busFull:
        return LiveChange(
          status: RoundStatus.full,
          currentStopIndex: round.currentStopIndex,
          seatsLeft: 0,
        );
      case StatusUpdateType.roundEnded:
      case StatusUpdateType.noMoreRounds:
        return LiveChange(
          status: RoundStatus.ended,
          currentStopIndex: round.stopIds.length - 1,
          seatsLeft: round.seatsLeft,
        );
    }
  }

  /// New seat count after pressing + or -, kept between 0 and the total.
  /// Reaching 0 marks a live round as full; adding a seat back reopens it.
  static LiveChange forSeats(Round round, int delta) {
    int seats = round.seatsLeft + delta;
    if (seats < 0) {
      seats = 0;
    }
    if (seats > round.seatsTotal) {
      seats = round.seatsTotal;
    }
    RoundStatus status = round.status;
    if (seats == 0 && round.isLive) {
      status = RoundStatus.full;
    } else if (seats > 0 && round.status == RoundStatus.full) {
      status = RoundStatus.onTheWay;
    }
    return LiveChange(
      status: status,
      currentStopIndex: round.currentStopIndex,
      seatsLeft: seats,
    );
  }
}
