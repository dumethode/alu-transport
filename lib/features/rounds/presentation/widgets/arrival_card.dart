import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_pill.dart';

/// "At your stop (Kimironko) ~ 07:52, in 10 min".
class ArrivalCard extends StatelessWidget {
  const ArrivalCard({
    super.key,
    required this.stopName,
    required this.arrival,
    required this.minutesAway,
    required this.hasPassed,
    required this.use24Hour,
  });
  final String stopName;
  final DateTime arrival;
  final int minutesAway;
  final bool hasPassed;
  final bool use24Hour;
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'At your stop ($stopName)',
            style: TextStyle(color: context.mutedText, fontSize: 12.5),
          ),
          const SizedBox(height: 4),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  hasPassed
                      ? 'Bus has passed'
                      : '~ ${Formatters.time(arrival, use24Hour: use24Hour)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (!hasPassed)
                StatusPill(
                  label: Formatters.minutesFromNow(minutesAway),
                  foreground: AppColors.primaryDark,
                  background: AppColors.primaryLight,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
