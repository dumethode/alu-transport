import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/round.dart';

/// Colours for each round status. Text colours pass 4.5:1 on their
/// background, and the label is always shown next to the colour.
class RoundStatusStyle {
  const RoundStatusStyle(this.foreground, this.background);
  final Color foreground;
  final Color background;
  static RoundStatusStyle of(RoundStatus status) {
    switch (status) {
      case RoundStatus.planned:
        return const RoundStatusStyle(AppColors.info, AppColors.infoSurface);
      case RoundStatus.onTheWay:
      case RoundStatus.atStop:
        return const RoundStatusStyle(
          AppColors.primaryDark,
          AppColors.primaryLight,
        );
      case RoundStatus.delayed:
        return const RoundStatusStyle(
          AppColors.warningText,
          AppColors.warningSurface,
        );
      case RoundStatus.full:
        return const RoundStatusStyle(
          AppColors.danger,
          AppColors.dangerSurface,
        );
      case RoundStatus.ended:
        return const RoundStatusStyle(
          AppColors.neutral,
          AppColors.neutralSurface,
        );
    }
  }
}
