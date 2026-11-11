import 'package:flutter/material.dart';

/// Scrollable, centred page body.
///
/// The content scrolls and is limited to [maxWidth], so screens never
/// overflow in landscape or on small (5.5 inch) phones, and do not
/// stretch too wide on large (6.7 inch and above) phones or tablets.
class ResponsiveBody extends StatelessWidget {
  const ResponsiveBody({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 24),
    this.maxWidth = 560,
    this.spacing = 12,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final double maxWidth;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: padding,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: spacing,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}
