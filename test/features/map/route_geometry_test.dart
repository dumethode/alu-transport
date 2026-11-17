import 'dart:ui';

import 'package:alu_transport/features/map/domain/services/route_geometry.dart';
import 'package:alu_transport/features/rounds/domain/entities/round.dart';
import 'package:flutter_test/flutter_test.dart';

Round _round(RoundStatus status, int index) => Round(
  id: 'r1',
  label: 'Round 1',
  period: RoundPeriod.morning,
  departureTime: DateTime(2026, 11, 12, 7),
  stopIds: const <String>['remera', 'kimironko', 'kacyiru'],
  status: status,
  currentStopIndex: index,
  seatsTotal: 29,
  seatsLeft: 10,
  driverId: 'driver-1',
);

void main() {
  test('points gives one position for campus and one per stop', () {
    final List<Offset> points = RouteGeometry.points(const Size(300, 500), 3);
    expect(points.length, 4);
    // Campus is at the bottom, the last stop near the top.
    expect(points.first.dy, greaterThan(points.last.dy));
  });

  test('every point stays inside the map', () {
    const Size size = Size(320, 400);
    for (final Offset point in RouteGeometry.points(size, 5)) {
      expect(point.dx, inInclusiveRange(0, size.width));
      expect(point.dy, inInclusiveRange(0, size.height));
    }
  });

  test('pointAt finds the middle between two stops', () {
    const List<Offset> points = <Offset>[Offset(0, 0), Offset(100, 0)];
    expect(RouteGeometry.pointAt(points, 0.5), const Offset(50, 0));
    expect(RouteGeometry.pointAt(points, 9), const Offset(100, 0));
    expect(RouteGeometry.pointAt(<Offset>[], 1), Offset.zero);
  });

  test('progressFor follows the round status', () {
    expect(RouteGeometry.progressFor(_round(RoundStatus.planned, -1)), 0);
    expect(RouteGeometry.progressFor(_round(RoundStatus.onTheWay, -1)), 0.5);
    expect(RouteGeometry.progressFor(_round(RoundStatus.atStop, 1)), 2);
    expect(RouteGeometry.progressFor(_round(RoundStatus.ended, 2)), 3);
  });
}
