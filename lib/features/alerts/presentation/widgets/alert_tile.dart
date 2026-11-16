import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../domain/entities/status_update.dart';

/// Colour and icon for each kind of update.
class AlertStyle {
  const AlertStyle(this.color, this.icon);

  final Color color;
  final AppIcons icon;

  static AlertStyle of(StatusUpdateType type) {
    switch (type) {
      case StatusUpdateType.leavingCampus:
        return const AlertStyle(AppColors.primary, AppIcons.bus);
      case StatusUpdateType.atPickup:
        return const AlertStyle(AppColors.info, AppIcons.mapPin);
      case StatusUpdateType.delayed:
        return const AlertStyle(AppColors.warningText, AppIcons.clock);
      case StatusUpdateType.busFull:
        return const AlertStyle(AppColors.danger, AppIcons.users);
      case StatusUpdateType.roundEnded:
        return const AlertStyle(AppColors.neutral, AppIcons.checkCircle);
      case StatusUpdateType.noMoreRounds:
        return const AlertStyle(AppColors.danger, AppIcons.x);
    }
  }
}

/// One alert: icon, title, round, optional driver note and time.
class AlertTile extends StatelessWidget {
  const AlertTile({
    super.key,
    required this.update,
    this.roundLabel,
    this.stopName,
    this.now,
  });

  final StatusUpdate update;
  final String? roundLabel;
  final String? stopName;

  /// Used by tests to get a fixed time text.
  final DateTime? now;

  String get _title {
    if (update.type == StatusUpdateType.atPickup && stopName != null) {
      return '${update.type.label}: $stopName';
    }
    return update.type.label;
  }

  @override
  Widget build(BuildContext context) {
    final AlertStyle style = AlertStyle.of(update.type);
    final String? note = update.note;
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: style.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: AppIcon(
              style.icon,
              size: 18,
              color: context.isDarkMode ? context.colors.primary : style.color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: <Widget>[
                Text(
                  _title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (roundLabel != null)
                  Text(
                    roundLabel!,
                    style: TextStyle(color: context.mutedText, fontSize: 12),
                  ),
                if (note != null && note.isNotEmpty)
                  Text(
                    'Driver note: $note',
                    style: TextStyle(color: context.mutedText, fontSize: 12),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            Formatters.timeAgo(update.createdAt, now: now),
            style: TextStyle(color: context.mutedText, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
