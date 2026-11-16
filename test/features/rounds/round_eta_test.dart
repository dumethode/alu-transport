import 'package:alu_transport/features/profile/domain/entities/pickup_point.dart';
import 'package:alu_transport/features/rounds/domain/entities/round.dart';
import 'package:alu_transport/features/rounds/domain/services/round_eta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'round_test_data.dart';

void main() {
  group('RoundEta.arrivalAt', () {
    test('adds the stop travel time to the departure time', () {
      final DateTime? arrival = RoundEta.arrivalAt(
        round: sampleRound(),
        stop: kimironko,
      );
      expect(arrival, DateTime(2026, 11, 12, 8, 2));
    });
    test('adds 10 minutes when the driver says the bus is delayed', () {
      final DateTime? arrival = RoundEta.arrivalAt(
        round: sampleRound(status: RoundStatus.delayed),
        stop: kimironko,
      );
      expect(arrival, DateTime(2026, 11, 12, 8, 12));
    });
    test('is null for a stop the round does not visit', () {
      final Round round = sampleRound().copyWith(stopIds: <String>['remera']);
      expect(RoundEta.arrivalAt(round: round, stop: kimironko), isNull);
    });
  });
  test('minutesUntil is never negative', () {
    final int? minutes = RoundEta.minutesUntil(
      round: sampleRound(),
      stop: remera,
      now: DateTime(2026, 11, 12, 9),
    );
    expect(minutes, 0);
  });
  test('hasPassed is true only for stops behind the bus', () {
    final Round round = sampleRound(
      status: RoundStatus.atStop,
      currentStopIndex: 1,
    );
    expect(RoundEta.hasPassed(round, 'remera'), isTrue);
    expect(RoundEta.hasPassed(round, 'kimironko'), isFalse);
  });
  test('nextStopIndex moves forward and stops at the last stop', () {
    expect(RoundEta.nextStopIndex(sampleRound(status: RoundStatus.planned)), 0);
    expect(RoundEta.nextStopIndex(sampleRound(currentStopIndex: 0)), 1);
    expect(RoundEta.nextStopIndex(sampleRound(currentStopIndex: 1)), 1);
    expect(RoundEta.nextStopIndex(sampleRound(status: RoundStatus.ended)), -1);
  });
  group('RoundEta.focusRound', () {
    final DateTime now = DateTime(2026, 11, 12, 7, 30);
    test('prefers the round that is on the road', () {
      final List<Round> rounds = <Round>[
        sampleRound(id: 'r1', status: RoundStatus.ended),
        sampleRound(id: 'r2'),
        sampleRound(id: 'r3', status: RoundStatus.planned),
      ];
      expect(RoundEta.focusRound(rounds, now)?.id, 'r2');
    });
    test('otherwise shows the next planned round', () {
      final List<Round> rounds = <Round>[
        sampleRound(id: 'r1', status: RoundStatus.ended),
        sampleRound(id: 'r3', status: RoundStatus.planned),
      ];
      expect(RoundEta.focusRound(rounds, now)?.id, 'r3');
    });
    test('is null when every round has finished', () {
      final List<Round> rounds = <Round>[
        sampleRound(id: 'r1', status: RoundStatus.ended),
      ];
      expect(RoundEta.focusRound(rounds, now), isNull);
    });
  });
  test('stopsFor keeps route order and skips missing stops', () {
    final Round round = sampleRound().copyWith(
      stopIds: <String>['kimironko', 'deleted-stop', 'remera'],
    );
    expect(
      RoundEta.stopsFor(round, const <PickupPoint>[remera, kimironko]),
      const <PickupPoint>[kimironko, remera],
    );
  });
  test('seatsTakenFraction is between 0 and 1', () {
    expect(sampleRound(seatsLeft: 29).seatsTakenFraction, 0);
    expect(sampleRound(seatsLeft: 0).seatsTakenFraction, 1);
  });
}
