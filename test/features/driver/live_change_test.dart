import 'package:alu_transport/features/alerts/domain/entities/status_update.dart';
import 'package:alu_transport/features/driver/domain/services/live_change.dart';
import 'package:alu_transport/features/rounds/domain/entities/round.dart';
import 'package:flutter_test/flutter_test.dart';

Round _round({
  RoundStatus status = RoundStatus.onTheWay,
  int index = -1,
  int seatsLeft = 12,
}) => Round(
  id: 'r2',
  label: 'Round 2',
  period: RoundPeriod.morning,
  departureTime: DateTime(2026, 11, 12, 7, 40),
  stopIds: const <String>['remera', 'kimironko'],
  status: status,
  currentStopIndex: index,
  seatsTotal: 29,
  seatsLeft: seatsLeft,
  driverId: 'driver-1',
);

void main() {
  group('LiveChange.forUpdate', () {
    test('leaving campus puts the bus on the road before the first stop', () {
      final LiveChange change = LiveChange.forUpdate(
        _round(status: RoundStatus.planned),
        StatusUpdateType.leavingCampus,
      );
      expect(change.status, RoundStatus.onTheWay);
      expect(change.currentStopIndex, -1);
    });

    test('at pickup point moves to the next stop but not past the last', () {
      final LiveChange first = LiveChange.forUpdate(
        _round(),
        StatusUpdateType.atPickup,
      );
      expect(first.status, RoundStatus.atStop);
      expect(first.currentStopIndex, 0);

      final LiveChange last = LiveChange.forUpdate(
        _round(index: 1),
        StatusUpdateType.atPickup,
      );
      expect(last.currentStopIndex, 1);
    });

    test('bus full sets the seats to zero', () {
      final LiveChange change = LiveChange.forUpdate(
        _round(),
        StatusUpdateType.busFull,
      );
      expect(change.status, RoundStatus.full);
      expect(change.seatsLeft, 0);
    });

    test('round ended and no more rounds both end the round', () {
      for (final StatusUpdateType type in <StatusUpdateType>[
        StatusUpdateType.roundEnded,
        StatusUpdateType.noMoreRounds,
      ]) {
        expect(LiveChange.forUpdate(_round(), type).status, RoundStatus.ended);
      }
    });
  });

  group('LiveChange.forSeats', () {
    test('never goes below zero or above the total', () {
      expect(LiveChange.forSeats(_round(seatsLeft: 0), -1).seatsLeft, 0);
      expect(LiveChange.forSeats(_round(seatsLeft: 29), 1).seatsLeft, 29);
    });

    test('the last seat taken marks a live bus full', () {
      final LiveChange change = LiveChange.forSeats(_round(seatsLeft: 1), -1);
      expect(change.seatsLeft, 0);
      expect(change.status, RoundStatus.full);
    });

    test('freeing a seat on a full bus puts it back on the way', () {
      final LiveChange change = LiveChange.forSeats(
        _round(status: RoundStatus.full, seatsLeft: 0),
        1,
      );
      expect(change.status, RoundStatus.onTheWay);
    });
  });
}
