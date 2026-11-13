import 'package:flutter/material.dart';

import '../core/widgets/app_button.dart';
import '../core/widgets/app_icon.dart';
import '../core/widgets/responsive_body.dart';
import '../core/widgets/state_views.dart';
import '../features/settings/presentation/pages/settings_screen.dart';

/// Foundation version of the gate. It is replaced when the auth feature
/// is merged. For now it lets everyone check the theme and settings.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ALU Transport')),
      body: ResponsiveBody(
        children: <Widget>[
          const MessageView(
            icon: AppIcons.bus,
            title: 'Foundation is ready',
            message:
                'Theme, icons, shared widgets and settings are in place. '
                'Each feature plugs in here when it is merged.',
          ),
          AppButton(
            label: 'Open settings',
            icon: AppIcons.settings,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const SettingsScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
