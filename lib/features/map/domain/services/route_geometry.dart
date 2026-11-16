import 'dart:math' as math;
import 'dart:ui';
import '../../../rounds/domain/entities/round.dart';

/// Places campus and the stops on a smooth curve, and works out where the
/// bus marker should be. Pure maths, so it is covered by unit tests.
abstract final class RouteGeometry {
  /// Screen positions for campus (index 0) and each stop after it.
  static List<Offset> points(Size size, int stopCount) {
    final int count = stopCount + 1;
    final List<Offset> result = <Offset>[];
    for (int i = 0; i < count; i++) {
      final double t = count == 1 ? 0 : i / (count - 1);
      final double x =
          size.width * (0.18 + 0.64 * t) +
          size.width * 0.08 * math.sin(t * math.pi * 2);
      final double y = size.height * (0.88 - 0.76 * t);
      result.add(Offset(x, y));
    }
    return result;
  }

  /// The point at a fractional [progress] along the route:
  /// 0 is campus, 1 is the first stop, 1.5 is half way to the second stop.
  static Offset pointAt(List<Offset> points, double progress) {
    if (points.isEmpty) {
      return Offset.zero;
    }
    final double clamped = progress.clamp(0, points.length - 1).toDouble();
    final int index = clamped.floor();
    if (index >= points.length - 1) {
      return points.last;
    }
    return Offset.lerp(points[index], points[index + 1], clamped - index)!;
  }

  /// How far along the route the bus is, from the round's live status.
  static double progressFor(Round round) {
    final int stops = round.stopIds.length;
    final double reached = (round.currentStopIndex + 1).toDouble();
    double progress;
    switch (round.status) {
      case RoundStatus.planned:
        progress = 0;
      case RoundStatus.ended:
        progress = stops.toDouble();
      case RoundStatus.atStop:
        progress = reached;
      case RoundStatus.full:
        progress = round.currentStopIndex >= 0 ? reached : 0.5;
      case RoundStatus.onTheWay:
      case RoundStatus.delayed:
        progress = reached + 0.5;
    }
    return progress.clamp(0, stops.toDouble()).toDouble();
  }
}
