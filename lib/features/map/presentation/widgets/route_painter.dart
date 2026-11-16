import 'package:flutter/material.dart';

/// Draws the simple map background and the bus route line, as in the
/// Figma map screen. Stops and the bus are separate widgets on top.
class RoutePainter extends CustomPainter {
  RoutePainter({
    required this.points,
    required this.progress,
    required this.routeColor,
    required this.roadColor,
    required this.blockColor,
  });
  final List<Offset> points;
  final double progress;
  final Color routeColor;
  final Color roadColor;
  final Color blockColor;
  @override
  void paint(Canvas canvas, Size size) {
    _paintBackground(canvas, size);
    if (points.length < 2) {
      return;
    }
    final Paint ahead = Paint()
      ..color = routeColor.withValues(alpha: 0.35)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final Paint travelled = Paint()
      ..color = routeColor
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(_smoothPath(points), ahead);
    // The part already driven is drawn solid.
    final int whole = progress.floor().clamp(0, points.length - 1).toInt();
    final List<Offset> done = points.sublist(0, whole + 1);
    if (whole < points.length - 1) {
      done.add(
        Offset.lerp(points[whole], points[whole + 1], progress - whole)!,
      );
    }
    if (done.length >= 2) {
      canvas.drawPath(_straightPath(done), travelled);
    }
  }

  void _paintBackground(Canvas canvas, Size size) {
    final Paint road = Paint()
      ..color = roadColor
      ..strokeWidth = 12;
    canvas.drawLine(
      Offset(0, size.height * 0.2),
      Offset(size.width, size.height * 0.27),
      road,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.6),
      Offset(size.width, size.height * 0.52),
      road,
    );
    canvas.drawLine(
      Offset(size.width * 0.25, 0),
      Offset(size.width * 0.36, size.height),
      road,
    );
    canvas.drawLine(
      Offset(size.width * 0.72, 0),
      Offset(size.width * 0.67, size.height),
      road,
    );
    final Paint block = Paint()..color = blockColor;
    final RRect blockA = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.42, size.height * 0.31, 64, 48),
      const Radius.circular(6),
    );
    final RRect blockB = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.06, size.height * 0.66, 52, 52),
      const Radius.circular(6),
    );
    canvas.drawRRect(blockA, block);
    canvas.drawRRect(blockB, block);
  }

  Path _smoothPath(List<Offset> pts) {
    final Path path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 0; i < pts.length - 1; i++) {
      final Offset mid = Offset.lerp(pts[i], pts[i + 1], 0.5)!;
      path.quadraticBezierTo(pts[i].dx, pts[i].dy, mid.dx, mid.dy);
    }
    path.lineTo(pts.last.dx, pts.last.dy);
    return path;
  }

  Path _straightPath(List<Offset> pts) {
    final Path path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final Offset point in pts.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    return path;
  }

  @override
  bool shouldRepaint(RoutePainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.progress != progress ||
        oldDelegate.routeColor != routeColor;
  }
}
