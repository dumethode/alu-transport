import 'package:flutter/material.dart';

import '../../core/widgets/app_icon.dart';
import '../../core/widgets/state_views.dart';
import '../../features/profile/presentation/pages/profile_screen.dart';
import 'adaptive_shell.dart';

/// Student tabs (profile version). The bus tabs are added in the last step.
class StudentShell extends StatelessWidget {
  const StudentShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdaptiveShell(
      destinations: <ShellDestination>[
        ShellDestination(
          label: 'Home',
          icon: AppIcons.home,
          page: Scaffold(
            body: Center(
              child: MessageView(
                icon: AppIcons.bus,
                title: 'Live bus status',
                message:
                    'This tab is connected when the rounds feature is merged.',
              ),
            ),
          ),
        ),
        ShellDestination(
          label: 'Profile',
          icon: AppIcons.user,
          page: ProfileScreen(),
        ),
      ],
    );
  }
}
