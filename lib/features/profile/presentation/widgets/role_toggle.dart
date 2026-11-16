import 'package:flutter/material.dart';

import '../../../../core/widgets/app_icon.dart';
import '../../domain/entities/user_profile.dart';

/// "I am a Student / Driver" switch from the Figma setup screen.
class RoleToggle extends StatelessWidget {
  const RoleToggle({super.key, required this.value, required this.onChanged});

  final UserRole value;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<UserRole>(
        showSelectedIcon: false,
        segments: const <ButtonSegment<UserRole>>[
          ButtonSegment<UserRole>(
            value: UserRole.student,
            label: Text('Student'),
            icon: AppIcon(AppIcons.user, size: 18),
          ),
          ButtonSegment<UserRole>(
            value: UserRole.driver,
            label: Text('Driver'),
            icon: AppIcon(AppIcons.bus, size: 18),
          ),
        ],
        selected: <UserRole>{value},
        onSelectionChanged: (Set<UserRole> choice) => onChanged(choice.first),
      ),
    );
  }
}
