import 'package:alu_transport/features/profile/domain/entities/pickup_point.dart';
import 'package:alu_transport/features/rounds/domain/entities/round.dart';

/// Shared sample data for the rounds, map and driver tests.
const PickupPoint remera = PickupPoint(
  id: 'remera',
  name: 'Remera',
  order: 1,
  minutesFromCampus: 10,
);
const PickupPoint kimironko = PickupPoint(
  id: 'kimironko',
  name: 'Kimironko',
  order: 2,
  minutesFromCampus: 22,
);
Round sampleRound({
  String id = 'r2',
  RoundStatus status = RoundStatus.onTheWay,
  int currentStopIndex = -1,
  int seatsLeft = 12,
  DateTime? departure,
  RoundPeriod period = RoundPeriod.morning,
}) {
  return Round(
    id: id,
    label: 'Round 2',
    period: period,
    departureTime: departure ?? DateTime(2026, 11, 12, 7, 40),
    stopIds: const <String>['remera', 'kimironko'],
    status: status,
    currentStopIndex: currentStopIndex,
    seatsTotal: 29,
    seatsLeft: seatsLeft,
    driverId: 'driver-1',
  );
}
