import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../domain/entities/round.dart';
import 'round_status_style.dart';

/// One row on the "Today's rounds" screen.
class RoundTile extends StatelessWidget {
  const RoundTile({
    super.key,
    required this.round,
    required this.use24Hour,
    this.hasReminder = false,
    this.onToggleReminder,
  });
  final Round round;
  final bool use24Hour;
  final bool hasReminder;
  final VoidCallback? onToggleReminder;
  String get _detail {
    switch (round.status) {
      case RoundStatus.ended:
        return 'Finished';
      case RoundStatus.full:
        return 'No seats left';
      case RoundStatus.planned:
        return '${round.seatsTotal} seats · ${round.stopIds.length} stops';
      case RoundStatus.onTheWay:
      case RoundStatus.atStop:
      case RoundStatus.delayed:
        return '${round.seatsLeft} seats left';
    }
  }

  @override
  Widget build(BuildContext context) {
    final RoundStatusStyle style = RoundStatusStyle.of(round.status);
    final bool canRemind =
        onToggleReminder != null && round.status == RoundStatus.planned;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '${round.label} · '
                  '${Formatters.time(round.departureTime, use24Hour: use24Hour)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                round.status.label,
                style: TextStyle(
                  color: context.isDarkMode
                      ? style.background
                      : style.foreground,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  _detail,
                  style: TextStyle(color: context.mutedText, fontSize: 12.5),
                ),
              ),
              if (canRemind)
                FilterChip(
                  selected: hasReminder,
                  showCheckmark: false,
                  avatar: AppIcon(
                    hasReminder ? AppIcons.checkCircle : AppIcons.bell,
                    size: 16,
                    color: context.colors.primary,
                  ),
                  label: Text(hasReminder ? 'Reminder on' : 'Remind me'),
                  onSelected: (_) => onToggleReminder!(),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
