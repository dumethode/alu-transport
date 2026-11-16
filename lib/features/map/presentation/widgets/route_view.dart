import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/services/route_geometry.dart';
import 'bus_marker.dart';
import 'route_painter.dart';

/// The drawn map: route line, stop markers with names, and the bus,
/// which slides smoothly to its new position after each driver update.
class RouteView extends StatelessWidget {
  const RouteView({
    super.key,
    required this.stopNames,
    required this.progress,
    this.highlightedStop,
  });

  /// Campus first, then each stop in order.
  final List<String> stopNames;
  final double progress;

  /// Index in [stopNames] of the student's own stop.
  final int? highlightedStop;
  @override
  Widget build(BuildContext context) {
    final Color route = context.colors.primary;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Size size = Size(constraints.maxWidth, constraints.maxHeight);
        final List<Offset> points = RouteGeometry.points(
          size,
          stopNames.length - 1,
        );
        return ClipRect(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(end: progress),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeInOut,
            builder: (BuildContext context, double value, Widget? child) {
              final Offset bus = RouteGeometry.pointAt(points, value);
              return Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: CustomPaint(
                      painter: RoutePainter(
                        points: points,
                        progress: value,
                        routeColor: route,
                        roadColor: context.isDarkMode
                            ? const Color(0xFF26332E)
                            : Colors.white,
                        blockColor: context.isDarkMode
                            ? const Color(0xFF1E2925)
                            : const Color(0xFFDFE8D8),
                      ),
                    ),
                  ),
                  for (int i = 0; i < points.length; i++)
                    ..._stop(context, points[i], stopNames[i], i, size),
                  Positioned(
                    left: bus.dx - 17,
                    top: bus.dy - 17,
                    child: BusMarker(color: route),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  List<Widget> _stop(
    BuildContext context,
    Offset point,
    String name,
    int index,
    Size size,
  ) {
    final bool mine = index == highlightedStop;
    final bool labelOnLeft = point.dx > size.width * 0.62;
    final Widget label = Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: context.colors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        mine ? '$name (you)' : name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: mine ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
    return <Widget>[
      Positioned(
        left: point.dx - (mine ? 10 : 8),
        top: point.dy - (mine ? 10 : 8),
        child: StopMarker(color: AppColors.primary, highlighted: mine),
      ),
      Positioned(
        top: point.dy - 11,
        left: labelOnLeft ? null : point.dx + 14,
        right: labelOnLeft ? size.width - point.dx + 14 : null,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: size.width * 0.42),
          child: label,
        ),
      ),
    ];
  }
}
