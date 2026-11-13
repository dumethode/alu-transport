import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/navigation/shell_tab_cubit.dart';
import '../core/theme/app_theme.dart';
import '../features/settings/data/repositories/shared_prefs_settings_repository.dart';
import '../features/settings/domain/entities/app_settings.dart';
import '../features/settings/domain/repositories/settings_repository.dart';
import '../features/settings/presentation/cubit/settings_cubit.dart';
import 'auth_gate.dart';

/// Lets the session listener close pushed screens on sign in and out.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

/// Root widget (foundation version). Feature repositories and cubits are
/// added here as each feature is merged.
class AluTransportApp extends StatelessWidget {
  const AluTransportApp({super.key, required this.preferences});

  final SharedPreferences preferences;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SettingsRepository>(
          create: (BuildContext context) =>
              SharedPrefsSettingsRepository(preferences),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<SettingsCubit>(
            create: (BuildContext context) =>
                SettingsCubit(context.read<SettingsRepository>())..load(),
          ),
          BlocProvider<ShellTabCubit>(
            create: (BuildContext context) => ShellTabCubit(),
          ),
        ],
        child: BlocBuilder<SettingsCubit, AppSettings>(
          builder: (BuildContext context, AppSettings settings) {
            return MaterialApp(
              title: 'ALU Transport',
              debugShowCheckedModeBanner: false,
              navigatorKey: appNavigatorKey,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: settings.theme.themeMode,
              builder: (BuildContext context, Widget? child) {
                final MediaQueryData media = MediaQuery.of(context);
                return MediaQuery(
                  data: settings.largeText
                      ? media.copyWith(
                          textScaler: const TextScaler.linear(1.15),
                        )
                      : media,
                  child: child ?? const SizedBox.shrink(),
                );
              },
              home: const AuthGate(),
            );
          },
        ),
      ),
    );
  }
}
