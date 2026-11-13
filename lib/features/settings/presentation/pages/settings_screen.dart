import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/responsive_body.dart';
import '../../domain/entities/app_settings.dart';
import '../cubit/settings_cubit.dart';

/// Lets the user change the four saved preferences.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocBuilder<SettingsCubit, AppSettings>(
        builder: (BuildContext context, AppSettings settings) {
          final SettingsCubit cubit = context.read<SettingsCubit>();
          return ResponsiveBody(
            children: <Widget>[
              const _SectionTitle('Appearance'),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Theme',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<ThemePreference>(
                        showSelectedIcon: false,
                        segments: const <ButtonSegment<ThemePreference>>[
                          ButtonSegment<ThemePreference>(
                            value: ThemePreference.light,
                            label: Text('Light'),
                            icon: AppIcon(AppIcons.sun, size: 18),
                          ),
                          ButtonSegment<ThemePreference>(
                            value: ThemePreference.dark,
                            label: Text('Dark'),
                            icon: AppIcon(AppIcons.moon, size: 18),
                          ),
                          ButtonSegment<ThemePreference>(
                            value: ThemePreference.system,
                            label: Text('System'),
                            icon: AppIcon(AppIcons.settings, size: 18),
                          ),
                        ],
                        selected: <ThemePreference>{settings.theme},
                        onSelectionChanged: (Set<ThemePreference> choice) =>
                            cubit.setTheme(choice.first),
                      ),
                    ),
                  ],
                ),
              ),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: <Widget>[
                    SwitchListTile(
                      secondary: const AppIcon(AppIcons.info),
                      title: const Text('Large text'),
                      subtitle: const Text('Makes all text 15% bigger'),
                      value: settings.largeText,
                      onChanged: cubit.setLargeText,
                    ),
                    const Divider(),
                    SwitchListTile(
                      secondary: const AppIcon(AppIcons.clock),
                      title: const Text('Use 24-hour time'),
                      subtitle: Text(
                        settings.use24HourTime
                            ? 'Shows 17:30'
                            : 'Shows 5:30 PM',
                      ),
                      value: settings.use24HourTime,
                      onChanged: cubit.setUse24HourTime,
                    ),
                    const Divider(),
                    SwitchListTile(
                      secondary: const AppIcon(AppIcons.bell),
                      title: const Text('Show alert banners'),
                      subtitle: const Text(
                        'Pop up a banner when the driver posts an update',
                      ),
                      value: settings.showAlertBanners,
                      onChanged: cubit.setShowAlertBanners,
                    ),
                  ],
                ),
              ),
              Text(
                'These settings are saved on this phone and come back '
                'when you reopen the app.',
                style: TextStyle(color: context.mutedText, fontSize: 12.5),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: context.mutedText,
      ),
    );
  }
}
