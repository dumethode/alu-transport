import 'package:flutter/material.dart';
import '../../../../core/widgets/app_icon.dart';

/// The round bus icon that moves along the route.
class BusMarker extends StatelessWidget {
  const BusMarker({super.key, required this.color, this.size = 34});
  final Color color;
  final double size;
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Bus position',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: <BoxShadow>[
            BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 10),
          ],
        ),
        alignment: Alignment.center,
        child: AppIcon(AppIcons.bus, size: size * 0.5, color: Colors.white),
      ),
    );
  }
}

/// A stop on the map: a ring, with a label next to it.
class StopMarker extends StatelessWidget {
  const StopMarker({super.key, required this.color, this.highlighted = false});
  final Color color;
  final bool highlighted;
  @override
  Widget build(BuildContext context) {
    final double size = highlighted ? 20 : 16;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFFE8B64C) : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: highlighted ? Colors.white : color, width: 3),
      ),
    );
  }
}
