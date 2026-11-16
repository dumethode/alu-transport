import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_icon.dart';

/// "− 12 +" counter. Each button is 48dp, the Material tap size.
class SeatsStepper extends StatelessWidget {
  const SeatsStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 60,
  });

  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _RoundButton(
          icon: AppIcons.minus,
          tooltip: 'One seat less',
          onPressed: value > min ? () => onChanged(-1) : null,
        ),
        SizedBox(
          width: 72,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              '$value',
              key: ValueKey<int>(value),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        _RoundButton(
          icon: AppIcons.plus,
          tooltip: 'One seat more',
          onPressed: value < max ? () => onChanged(1) : null,
        ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final AppIcons icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: tooltip,
      constraints: const BoxConstraints.tightFor(width: 48, height: 48),
      onPressed: onPressed,
      icon: AppIcon(
        icon,
        size: 22,
        color: onPressed == null ? context.mutedText : context.colors.primary,
      ),
    );
  }
}
