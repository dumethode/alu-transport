import '../../../profile/domain/entities/pickup_point.dart';
import '../entities/round.dart';

/// Pure business rules for timing. No Flutter or Firebase here, so it is
/// easy to unit test.
abstract final class RoundEta {
  /// Extra minutes added to every arrival when the driver posts "Delayed".
  static const int delayMinutes = 10;

  /// The round's stops as [PickupPoint]s, in the order the bus visits them.
  static List<PickupPoint> stopsFor(Round round, List<PickupPoint> all) {
    final Map<String, PickupPoint> byId = <String, PickupPoint>{
      for (final PickupPoint point in all) point.id: point,
    };
    final List<PickupPoint> stops = <PickupPoint>[];
    for (final String id in round.stopIds) {
      final PickupPoint? point = byId[id];
      if (point != null) {
        stops.add(point);
      }
    }
    return stops;
  }

  /// Expected time the bus reaches [stop], or null if it does not stop there.
  static DateTime? arrivalAt({
    required Round round,
    required PickupPoint stop,
  }) {
    if (!round.stopIds.contains(stop.id)) {
      return null;
    }
    final int extra = round.status == RoundStatus.delayed ? delayMinutes : 0;
    return round.departureTime.add(
      Duration(minutes: stop.minutesFromCampus + extra),
    );
  }

  /// Minutes until the bus reaches [stop] (never negative).
  static int? minutesUntil({
    required Round round,
    required PickupPoint stop,
    required DateTime now,
  }) {
    final DateTime? arrival = arrivalAt(round: round, stop: stop);
    if (arrival == null) {
      return null;
    }
    final int minutes = arrival.difference(now).inMinutes;
    return minutes < 0 ? 0 : minutes;
  }

  /// True once the bus has left [stopId] behind.
  static bool hasPassed(Round round, String stopId) {
    final int index = round.stopIds.indexOf(stopId);
    if (index < 0) {
      return false;
    }
    if (round.isFinished) {
      return true;
    }
    return index < round.currentStopIndex;
  }

  /// Index in [Round.stopIds] of the next stop, or -1 if there is none.
  static int nextStopIndex(Round round) {
    if (round.stopIds.isEmpty || round.isFinished) {
      return -1;
    }
    if (round.status == RoundStatus.planned) {
      return 0;
    }
    final int next = round.currentStopIndex + 1;
    return next >= round.stopIds.length ? round.stopIds.length - 1 : next;
  }

  /// The round students care about now: the live one, otherwise the next
  /// planned one, otherwise null.
  static Round? focusRound(List<Round> rounds, DateTime now) {
    for (final Round round in rounds) {
      if (round.isLive) {
        return round;
      }
    }
    final DateTime cutOff = now.subtract(const Duration(minutes: 30));
    for (final Round round in rounds) {
      if (round.status == RoundStatus.planned &&
          round.departureTime.isAfter(cutOff)) {
        return round;
      }
    }
    return null;
  }

  /// The last round of a period (for the "last morning round" warning).
  static Round? lastOfPeriod(List<Round> rounds, RoundPeriod period) {
    Round? last;
    for (final Round round in rounds) {
      if (round.period == period) {
        last = round;
      }
    }
    return last;
  }
}
