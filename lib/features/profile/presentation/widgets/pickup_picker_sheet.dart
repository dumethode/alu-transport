import 'package:flutter/material.dart';

import '../../domain/entities/pickup_point.dart';
import 'pickup_option_tile.dart';

/// Bottom sheet to change the pickup point. Returns the chosen id.
Future<String?> showPickupPickerSheet(
  BuildContext context, {
  required List<PickupPoint> points,
  required String? selectedId,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (BuildContext context) {
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.7,
          ),
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: points.length + 1,
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: 8),
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return const Text(
                  'Choose your pickup point',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                );
              }
              final PickupPoint point = points[index - 1];
              return PickupOptionTile(
                point: point,
                selected: point.id == selectedId,
                onTap: () => Navigator.of(context).pop(point.id),
              );
            },
          ),
        ),
      );
    },
  );
}
