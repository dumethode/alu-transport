import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../../rounds/domain/entities/round.dart';

/// Chips to choose which of today's rounds the driver is updating.
class RoundPicker extends StatelessWidget {
  const RoundPicker({
    super.key,
    required this.rounds,
    required this.selectedId,
    required this.onSelected,
    required this.use24Hour,
  });

  final List<Round> rounds;
  final String? selectedId;
  final ValueChanged<String> onSelected;
  final bool use24Hour;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (final Round round in rounds)
          ChoiceChip(
            label: Text(
              '${round.label} · '
              '${Formatters.time(round.departureTime, use24Hour: use24Hour)}',
            ),
            selected: round.id == selectedId,
            onSelected: (_) => onSelected(round.id),
          ),
      ],
    );
  }
}
