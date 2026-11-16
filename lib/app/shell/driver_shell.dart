import 'package:flutter/material.dart';

import '../../core/widgets/app_icon.dart';
import '../../core/widgets/state_views.dart';
import '../../features/profile/presentation/pages/profile_screen.dart';
import 'adaptive_shell.dart';

/// Driver tabs (profile version). The driver tabs are added in the last step.
class DriverShell extends StatelessWidget {
  const DriverShell({super.key});

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
                icon: AppIcons.send,
                title: 'Post bus updates',
                message:
                    'This tab is connected when the driver feature is merged.',
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
