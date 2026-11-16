import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_pill.dart';

/// One line of the panel under the map, e.g. "Next stop  Remera  2 min".
class StopEta {
  const StopEta({required this.caption, required this.name, required this.eta});
  final String caption;
  final String name;
  final String eta;
}

/// The "Next stop / Your stop" card under the map.
class StopEtaPanel extends StatelessWidget {
  const StopEtaPanel({super.key, required this.rows});
  final List<StopEta> rows;
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        spacing: 12,
        children: <Widget>[
          for (final StopEta row in rows)
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        row.caption,
                        style: TextStyle(
                          color: context.mutedText,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        row.name,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusPill(
                  label: row.eta,
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
