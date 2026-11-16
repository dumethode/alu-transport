import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../alerts/domain/entities/status_update.dart';
import '../../../alerts/presentation/widgets/alert_tile.dart';

/// The six "Tap one update" buttons from the Figma driver screen.
/// Each colour keeps at least 4.5:1 contrast with its text.
class StatusPresetGrid extends StatelessWidget {
  const StatusPresetGrid({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final StatusUpdateType selected;
  final ValueChanged<StatusUpdateType> onSelected;

  static Color _fill(StatusUpdateType type) {
    switch (type) {
      case StatusUpdateType.leavingCampus:
        return AppColors.primary;
      case StatusUpdateType.atPickup:
        return AppColors.info;
      case StatusUpdateType.delayed:
        return AppColors.warning;
      case StatusUpdateType.busFull:
        return AppColors.danger;
      case StatusUpdateType.roundEnded:
        return AppColors.neutral;
      case StatusUpdateType.noMoreRounds:
        return AppColors.ink;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Two columns on phones, three when there is more room.
        final int columns = constraints.maxWidth > 520 ? 3 : 2;
        final double width =
            (constraints.maxWidth - (columns - 1) * 8) / columns;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final StatusUpdateType type in StatusUpdateType.values)
              SizedBox(
                width: width,
                child: _PresetButton(
                  type: type,
                  fill: _fill(type),
                  selected: type == selected,
                  onTap: () => onSelected(type),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PresetButton extends StatelessWidget {
  const _PresetButton({
    required this.type,
    required this.fill,
    required this.selected,
    required this.onTap,
  });

  final StatusUpdateType type;
  final Color fill;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color text = type == StatusUpdateType.delayed
        ? AppColors.ink
        : Colors.white;
    return Semantics(
      button: true,
      selected: selected,
      child: AnimatedScale(
        scale: selected ? 1.0 : 0.96,
        duration: const Duration(milliseconds: 150),
        child: Material(
          color: fill,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: selected ? const Color(0xFF9FE0C6) : Colors.transparent,
              width: 3,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 52),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    AppIcon(AlertStyle.of(type).icon, size: 18, color: text),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        type.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: text,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
