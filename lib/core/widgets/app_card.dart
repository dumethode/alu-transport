import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// White card with a thin border, or a filled card when [color] is given.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.color,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      clipBehavior: Clip.antiAlias,
      shape: color == null
          ? null
          : RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radius),
            ),
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
